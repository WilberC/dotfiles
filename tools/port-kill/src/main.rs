#[cfg(not(unix))]
compile_error!("port-kill supports Unix platforms: Linux (including WSL2 Ubuntu) and macOS");

use std::{
    fs,
    io::{self, IsTerminal},
    path::PathBuf,
    process::{Command, ExitCode, Stdio},
    sync::mpsc::{self, Receiver, TryRecvError},
    thread,
    time::Duration,
};

use crossterm::event::{self, Event, KeyCode, KeyEvent, KeyEventKind, KeyModifiers};
use ratatui::{
    Frame,
    layout::{Constraint, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, Clear, Paragraph, Wrap},
};
use serde_json::Value;

const WINDOWS_LISTENERS_SCRIPT: &str = r#"
$ErrorActionPreference = 'Stop'
$proxies = @{}
& netsh interface portproxy show v4tov4 | ForEach-Object {
    if ($_ -match '^\s*(\S+)\s+(\d+)\s+(\S+)\s+(\d+)\s*$') {
        $proxies[($matches[1] + ':' + $matches[2])] = ($matches[3] + ':' + $matches[4])
    }
}
$items = @(Get-NetTCPConnection -State Listen | ForEach-Object {
    $process = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
    $key = ($_.LocalAddress + ':' + $_.LocalPort)
    $target = $proxies[$key]
    if ($null -ne $target) {
        [pscustomobject]@{ Kind = 'portproxy'; Port = [int]$_.LocalPort; Address = $_.LocalAddress; Pid = [int]$_.OwningProcess; Process = 'portproxy (IP Helper)'; User = 'SYSTEM'; Target = $target }
    } else {
        [pscustomobject]@{ Kind = 'listener'; Port = [int]$_.LocalPort; Address = $_.LocalAddress; Pid = [int]$_.OwningProcess; Process = if ($process) { $process.ProcessName } else { '<unknown>' }; User = '-'; Target = '' }
    }
})
$items | ConvertTo-Json -Compress
"#;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
enum Origin {
    Local,
    Windows,
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
enum ListenerKind {
    Process,
    WindowsPortProxy { target: String },
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct Listener {
    origin: Origin,
    kind: ListenerKind,
    port: u16,
    pid: i32,
    user: String,
    process: String,
    address: String,
}

#[derive(Debug, Clone)]
enum Row {
    Heading(String),
    Empty(String),
    Service(usize),
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Mode {
    Listing,
    Confirm(usize),
    WindowsInfo(usize),
}

#[derive(Debug, Clone)]
struct App {
    show_windows: bool,
    local_label: &'static str,
    listeners: Vec<Listener>,
    rows: Vec<Row>,
    selected_row: Option<usize>,
    mode: Mode,
    loading: bool,
    error: Option<String>,
}

impl App {
    fn loading(show_windows: bool) -> Self {
        Self {
            show_windows,
            local_label: local_section_label(),
            listeners: Vec::new(),
            rows: Vec::new(),
            selected_row: None,
            mode: Mode::Listing,
            loading: true,
            error: None,
        }
    }

    fn set_discovery(&mut self, result: Result<Vec<Listener>, String>) {
        self.loading = false;
        match result {
            Ok(listeners) => self.listeners = listeners,
            Err(error) => self.error = Some(error),
        }
        self.rebuild_rows();
    }

    fn rebuild_rows(&mut self) {
        self.rows.clear();
        self.rows.push(Row::Heading(self.local_label.to_owned()));
        self.rows.push(Row::Empty(
            "  PORT   PID     USER         PROCESS              ADDRESS".into(),
        ));
        let local: Vec<_> = self
            .listeners
            .iter()
            .enumerate()
            .filter_map(|(index, item)| (item.origin == Origin::Local).then_some(index))
            .collect();
        if local.is_empty() {
            self.rows
                .push(Row::Empty("  No local listening TCP services.".into()));
        } else {
            self.rows.extend(local.into_iter().map(Row::Service));
        }
        if self.show_windows {
            self.rows.push(Row::Heading(
                "Windows host (informational; never killed)".into(),
            ));
            self.rows.push(Row::Empty(
                "  PORT   PID     USER         PROCESS              ADDRESS".into(),
            ));
            let windows: Vec<_> = self
                .listeners
                .iter()
                .enumerate()
                .filter_map(|(index, item)| (item.origin == Origin::Windows).then_some(index))
                .collect();
            if windows.is_empty() {
                self.rows.push(Row::Empty(
                    "  No Windows listening TCP services discovered.".into(),
                ));
            } else {
                self.rows.extend(windows.into_iter().map(Row::Service));
            }
        }
        self.selected_row = self
            .rows
            .iter()
            .position(|row| matches!(row, Row::Service(_)));
    }

    fn selected_listener_index(&self) -> Option<usize> {
        self.selected_row
            .and_then(|index| match self.rows.get(index) {
                Some(Row::Service(listener)) => Some(*listener),
                _ => None,
            })
    }

    fn move_selection(&mut self, direction: i32) {
        let selectable: Vec<_> = self
            .rows
            .iter()
            .enumerate()
            .filter_map(|(index, row)| matches!(row, Row::Service(_)).then_some(index))
            .collect();
        let Some(current) = self.selected_row else {
            self.selected_row = selectable.first().copied();
            return;
        };
        let Some(position) = selectable.iter().position(|index| *index == current) else {
            self.selected_row = selectable.first().copied();
            return;
        };
        let next = if direction < 0 {
            position.saturating_sub(1)
        } else {
            (position + 1).min(selectable.len().saturating_sub(1))
        };
        self.selected_row = selectable.get(next).copied();
    }

    fn handle_key(&mut self, key: KeyEvent) -> Action {
        if !matches!(key.kind, KeyEventKind::Press | KeyEventKind::Repeat) {
            return Action::Continue;
        }
        if key.modifiers.contains(KeyModifiers::CONTROL) && key.code == KeyCode::Char('c') {
            return Action::Quit;
        }
        match self.mode {
            Mode::Listing => match key.code {
                KeyCode::Char('q') | KeyCode::Esc => Action::Quit,
                KeyCode::Up | KeyCode::Char('k') => {
                    self.move_selection(-1);
                    Action::Continue
                }
                KeyCode::Down | KeyCode::Char('j') => {
                    self.move_selection(1);
                    Action::Continue
                }
                KeyCode::Enter => match self.selected_listener_index() {
                    Some(index) if self.listeners[index].origin == Origin::Local => {
                        self.mode = Mode::Confirm(index);
                        Action::Continue
                    }
                    Some(index) => {
                        self.mode = Mode::WindowsInfo(index);
                        Action::Continue
                    }
                    None => Action::Continue,
                },
                _ => Action::Continue,
            },
            Mode::Confirm(index) => match key.code {
                KeyCode::Char('y') | KeyCode::Enter => Action::Terminate(index),
                KeyCode::Char('n') | KeyCode::Esc | KeyCode::Char('q') => {
                    self.mode = Mode::Listing;
                    Action::Continue
                }
                _ => Action::Continue,
            },
            Mode::WindowsInfo(_) => match key.code {
                KeyCode::Esc | KeyCode::Enter => {
                    self.mode = Mode::Listing;
                    Action::Continue
                }
                KeyCode::Char('q') => Action::Quit,
                _ => Action::Continue,
            },
        }
    }
}

enum Action {
    Continue,
    Quit,
    Terminate(usize),
}

fn main() -> ExitCode {
    match run() {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("port-kill: {error}");
            ExitCode::FAILURE
        }
    }
}

fn run() -> Result<(), String> {
    if matches!(
        std::env::args().nth(1).as_deref(),
        Some("help" | "--help" | "-h")
    ) {
        print_usage();
        return Ok(());
    }
    if !io::stdin().is_terminal() || !io::stdout().is_terminal() {
        return Err("interactive selection requires a terminal; no process was stopped".into());
    }

    let show_windows = is_wsl2() && powershell_exe_available();
    let (sender, receiver) = mpsc::channel();
    let worker = thread::spawn(move || {
        let _ = sender.send(discover_listeners(show_windows));
    });
    let mut app = App::loading(show_windows);
    let result = ratatui::run(|terminal| run_tui(terminal, &mut app, &receiver));
    worker
        .join()
        .map_err(|_| "listener discovery worker panicked")?;
    if let Some(listener) = result? {
        println!(
            "Sent SIGTERM to PID {} ({} listening on {}).",
            listener.pid, listener.process, listener.address
        );
    }
    Ok(())
}

fn run_tui(
    terminal: &mut ratatui::DefaultTerminal,
    app: &mut App,
    receiver: &Receiver<Result<Vec<Listener>, String>>,
) -> Result<Option<Listener>, String> {
    loop {
        terminal
            .draw(|frame| render(frame, app))
            .map_err(|error| format!("could not render terminal UI: {error}"))?;
        if app.loading {
            match receiver.try_recv() {
                Ok(result) => app.set_discovery(result),
                Err(TryRecvError::Disconnected) => {
                    app.set_discovery(Err("listener discovery stopped unexpectedly".into()))
                }
                Err(TryRecvError::Empty) => {}
            }
        }
        if event::poll(Duration::from_millis(80))
            .map_err(|error| format!("could not read terminal input: {error}"))?
            && let Event::Key(key) =
                event::read().map_err(|error| format!("could not read terminal input: {error}"))?
        {
            match app.handle_key(key) {
                Action::Continue => {}
                Action::Quit => return Ok(None),
                Action::Terminate(index) => {
                    let listener = app.listeners[index].clone();
                    send_sigterm(listener.pid)?;
                    return Ok(Some(listener));
                }
            }
        }
    }
}

fn render(frame: &mut Frame, app: &App) {
    let area = frame.area();
    if area.width < 34 || area.height < 7 {
        render_tiny(frame, app, area);
        return;
    }
    let sections = Layout::vertical([
        Constraint::Length(3),
        Constraint::Min(2),
        Constraint::Length(2),
    ])
    .split(area);
    frame.render_widget(
        Paragraph::new("port-kill  •  Listening TCP services")
            .block(Block::default().borders(Borders::BOTTOM))
            .style(themed(Color::Cyan, Modifier::BOLD | Modifier::UNDERLINED)),
        sections[0],
    );
    let body = if app.loading {
        vec![Line::from(Span::styled(
            "[SCANNING] Looking for listening TCP services…",
            themed(Color::Cyan, Modifier::BOLD),
        ))]
    } else if let Some(error) = &app.error {
        vec![Line::from(vec![
            Span::styled("[ERROR] ", themed(Color::Red, Modifier::BOLD)),
            Span::raw(format!("Discovery failed: {error}")),
        ])]
    } else {
        app_rows(app)
    };
    frame.render_widget(Paragraph::new(body).wrap(Wrap { trim: false }), sections[1]);
    let footer = match app.mode {
        Mode::Listing => "[KEYS] ↑/k ↓/j move  Enter select  q/Esc/Ctrl-C quit",
        Mode::Confirm(_) => "[CONFIRM] Enter/y send SIGTERM  n/Esc/q cancel",
        Mode::WindowsInfo(_) => "[INFO] Enter/Esc back  q quit",
    };
    frame.render_widget(
        Paragraph::new(footer)
            .block(Block::default().borders(Borders::TOP))
            .style(themed(Color::Cyan, Modifier::BOLD)),
        sections[2],
    );
    match app.mode {
        Mode::Confirm(index) => render_confirmation(frame, &app.listeners[index], area),
        Mode::WindowsInfo(index) => render_windows_info(frame, &app.listeners[index], area),
        Mode::Listing => {}
    }
}

fn render_tiny(frame: &mut Frame, app: &App, area: Rect) {
    let text = if app.loading {
        "port-kill\n[SCANNING] Looking for services…\n[KEYS] q/Esc quits"
    } else {
        "port-kill\n[LAYOUT] Terminal too small\nResize to at least 34×7\n[KEYS] q/Esc quits"
    };
    frame.render_widget(
        Paragraph::new(text)
            .style(themed(Color::Yellow, Modifier::BOLD))
            .wrap(Wrap { trim: true }),
        area,
    );
}

fn app_rows(app: &App) -> Vec<Line<'static>> {
    app.rows
        .iter()
        .enumerate()
        .map(|(row_index, row)| match row {
            Row::Heading(label) => {
                let (color, prefix) = if label.starts_with("Windows") {
                    (Color::Yellow, "[WINDOWS HOST • INFO ONLY]")
                } else {
                    (Color::Cyan, "[LOCAL]")
                };
                Line::from(Span::styled(
                    format!("\n{prefix} {label}"),
                    themed(color, Modifier::BOLD | Modifier::UNDERLINED),
                ))
            }
            Row::Empty(text) if text.contains("PORT   PID") => Line::from(Span::styled(
                text.clone(),
                themed(Color::Green, Modifier::BOLD | Modifier::UNDERLINED),
            )),
            Row::Empty(text) => Line::from(Span::styled(
                text.clone(),
                themed(Color::Yellow, Modifier::DIM),
            )),
            Row::Service(listener_index) => {
                let listener = &app.listeners[*listener_index];
                let marker = if app.selected_row == Some(row_index) {
                    "> "
                } else {
                    "  "
                };
                let text = format!(
                    "{marker}{:<6} {:<7} {:<12} {:<20} {}",
                    listener.port,
                    listener.pid,
                    truncate(&listener.user, 12),
                    truncate(&listener.process, 20),
                    listener.address
                );
                let style = if app.selected_row == Some(row_index) {
                    themed(Color::Yellow, Modifier::BOLD | Modifier::REVERSED)
                } else {
                    Style::default()
                };
                Line::from(Span::styled(text, style))
            }
        })
        .collect()
}

/// Avoid background colors: terminal themes disagree on their contrast. The labels and modifiers
/// keep hierarchy and selection visible when `NO_COLOR` disables the foreground palette.
fn themed(color: Color, modifiers: Modifier) -> Style {
    let style = Style::default().add_modifier(modifiers);
    if std::env::var_os("NO_COLOR").is_some_and(|value| !value.is_empty()) {
        style
    } else {
        style.fg(color)
    }
}

fn popup_area(area: Rect) -> Rect {
    Rect::new(
        area.x + area.width / 10,
        area.y + area.height / 4,
        area.width.saturating_mul(8) / 10,
        (area.height / 2).max(3),
    )
}

fn render_confirmation(frame: &mut Frame, listener: &Listener, area: Rect) {
    let popup = popup_area(area);
    frame.render_widget(Clear, popup);
    let text = vec![
        Line::from(Span::styled(
            format!(
                "[CAUTION] Send SIGTERM to PID {} ({}) on port {}?",
                listener.pid, listener.process, listener.port
            ),
            themed(Color::Red, Modifier::BOLD),
        )),
        Line::from(""),
        Line::from("This stops only the selected local process."),
        Line::from(""),
        Line::from(Span::styled(
            "[Enter/y] confirm   [n/Esc/q] cancel",
            themed(Color::Yellow, Modifier::BOLD),
        )),
    ];
    frame.render_widget(
        Paragraph::new(text).wrap(Wrap { trim: true }).block(
            Block::default()
                .title(Span::styled(
                    " [CONFIRM] Terminate local process ",
                    themed(Color::Red, Modifier::BOLD),
                ))
                .borders(Borders::ALL)
                .border_style(themed(Color::Red, Modifier::BOLD)),
        ),
        popup,
    );
}

fn render_windows_info(frame: &mut Frame, listener: &Listener, area: Rect) {
    let popup = popup_area(area);
    frame.render_widget(Clear, popup);
    let text = match &listener.kind {
        ListenerKind::WindowsPortProxy { target } => format!(
            "Windows portproxy: {} forwards to {}.\nNo Windows process will be killed.\n\nIn elevated Windows PowerShell:\nnetsh interface portproxy delete v4tov4 listenport={} listenaddress={}\n\n[Enter/Esc] back",
            listener.address,
            target,
            listener.port,
            listener
                .address
                .rsplit_once(':')
                .map_or("0.0.0.0", |(address, _)| address)
        ),
        ListenerKind::Process => format!(
            "Windows listener: PID {} ({}) on {}.\nNo Windows process will be killed.\n\nInspect in Windows PowerShell:\nGet-Process -Id {}\n\n[Enter/Esc] back",
            listener.pid, listener.process, listener.address, listener.pid
        ),
    };
    frame.render_widget(
        Paragraph::new(vec![
            Line::from(Span::styled(
                "[WINDOWS HOST] Information only — no process will be killed.",
                themed(Color::Yellow, Modifier::BOLD),
            )),
            Line::from(""),
            Line::from(text),
        ])
        .wrap(Wrap { trim: true })
        .block(
            Block::default()
                .title(Span::styled(
                    " [WINDOWS HOST • INFO ONLY] ",
                    themed(Color::Yellow, Modifier::BOLD),
                ))
                .borders(Borders::ALL)
                .border_style(themed(Color::Yellow, Modifier::BOLD)),
        ),
        popup,
    );
}

fn local_section_label() -> &'static str {
    #[cfg(target_os = "macos")]
    {
        "macOS / local"
    }
    #[cfg(not(target_os = "macos"))]
    {
        "Linux / local"
    }
}

fn discover_listeners(include_windows: bool) -> Result<Vec<Listener>, String> {
    let output = Command::new("lsof").args(["-nP", "-iTCP", "-sTCP:LISTEN"]).output().map_err(|error| if error.kind() == io::ErrorKind::NotFound { format!("`lsof` is required to find listening services but was not found. {} No process was stopped.", lsof_install_hint()) } else { format!("could not run lsof: {error}") })?;
    let stdout = String::from_utf8_lossy(&output.stdout);
    let mut listeners: Vec<_> = stdout.lines().filter_map(parse_lsof_line).collect();
    if !output.status.success() && listeners.is_empty() && !output.stderr.is_empty() {
        let detail = String::from_utf8_lossy(&output.stderr);
        if !detail.trim().is_empty() {
            return Err(format!("lsof failed: {}", detail.trim()));
        }
    }
    if include_windows {
        match discover_windows_listeners() {
            Ok(windows) => listeners.extend(windows),
            Err(error) => eprintln!("port-kill: Windows listener discovery unavailable: {error}"),
        }
    }
    sort_and_dedup(&mut listeners);
    Ok(listeners)
}

fn is_wsl2() -> bool {
    fs::read_to_string("/proc/version").is_ok_and(|version| is_wsl_kernel_version(&version))
}
fn is_wsl_kernel_version(version: &str) -> bool {
    version.to_ascii_lowercase().contains("microsoft")
}
fn powershell_exe_available() -> bool {
    std::env::var_os("PATH")
        .is_some_and(|paths| powershell_exe_available_in(std::env::split_paths(&paths)))
}
fn powershell_exe_available_in(paths: impl IntoIterator<Item = PathBuf>) -> bool {
    paths
        .into_iter()
        .any(|directory| directory.join("powershell.exe").is_file())
}

fn discover_windows_listeners() -> Result<Vec<Listener>, String> {
    let output = Command::new("powershell.exe")
        .args([
            "-NoProfile",
            "-NonInteractive",
            "-Command",
            WINDOWS_LISTENERS_SCRIPT,
        ])
        .stdin(Stdio::null())
        .output()
        .map_err(|error| {
            if error.kind() == io::ErrorKind::NotFound {
                "powershell.exe was not found".to_owned()
            } else {
                format!("could not run powershell.exe: {error}")
            }
        })?;
    if !output.status.success() {
        let detail = String::from_utf8_lossy(&output.stderr).trim().to_owned();
        return Err(if detail.is_empty() {
            format!("powershell.exe exited with {}", output.status)
        } else {
            detail
        });
    }
    parse_windows_listeners(&String::from_utf8_lossy(&output.stdout))
}

fn parse_windows_listeners(output: &str) -> Result<Vec<Listener>, String> {
    let trimmed = output.trim();
    if trimmed.is_empty() || trimmed == "null" {
        return Ok(Vec::new());
    }
    let value: Value = serde_json::from_str(trimmed)
        .map_err(|error| format!("could not parse Windows listener data: {error}"))?;
    let records: Vec<&Value> = match &value {
        Value::Array(records) => records.iter().collect(),
        Value::Object(_) => vec![&value],
        _ => return Err("Windows listener data was not an object or array".into()),
    };
    Ok(records
        .into_iter()
        .filter_map(parse_windows_listener)
        .collect())
}

fn parse_windows_listener(record: &Value) -> Option<Listener> {
    let object = record.as_object()?;
    let port = object.get("Port")?.as_u64()?.try_into().ok()?;
    let pid = object.get("Pid")?.as_i64()?.try_into().ok()?;
    let address = object.get("Address")?.as_str()?.to_owned();
    let process = object.get("Process")?.as_str()?.to_owned();
    let user = object
        .get("User")
        .and_then(Value::as_str)
        .unwrap_or("-")
        .to_owned();
    let kind = match object.get("Kind").and_then(Value::as_str) {
        Some("portproxy") => ListenerKind::WindowsPortProxy {
            target: object
                .get("Target")
                .and_then(Value::as_str)
                .unwrap_or("unknown target")
                .to_owned(),
        },
        _ => ListenerKind::Process,
    };
    Some(Listener {
        origin: Origin::Windows,
        kind,
        port,
        pid,
        user,
        process,
        address: format!("{address}:{port}"),
    })
}

fn sort_and_dedup(listeners: &mut Vec<Listener>) {
    listeners.sort_by(|left, right| {
        left.port
            .cmp(&right.port)
            .then(left.origin.cmp(&right.origin))
            .then(left.pid.cmp(&right.pid))
            .then(left.address.cmp(&right.address))
    });
    listeners.dedup();
}
fn print_usage() {
    println!(
        "Usage: port-kill\n\nInteractively list listening TCP services in separate local and Windows-host sections.\nA selected local Linux/macOS process requires explicit confirmation before SIGTERM.\nOn WSL2, Windows-host entries are informational and are never stopped."
    );
}
fn lsof_install_hint() -> &'static str {
    #[cfg(target_os = "macos")]
    {
        "macOS normally includes it at /usr/sbin/lsof; install it with your system package manager if it is missing."
    }
    #[cfg(not(target_os = "macos"))]
    {
        "On Ubuntu (including WSL2 Ubuntu), run `sudo apt update && sudo apt install lsof`."
    }
}

fn parse_lsof_line(line: &str) -> Option<Listener> {
    if line.starts_with("COMMAND") {
        return None;
    }
    let fields: Vec<_> = line.split_whitespace().collect();
    if fields.len() < 4 {
        return None;
    }
    let tcp_index = fields.iter().position(|field| *field == "TCP")?;
    let address = fields.get(tcp_index + 1)?.trim_end_matches("(LISTEN)");
    let port = address.rsplit_once(':')?.1.parse().ok()?;
    Some(Listener {
        origin: Origin::Local,
        kind: ListenerKind::Process,
        process: fields[0].to_owned(),
        pid: fields[1].parse().ok()?,
        user: fields[2].to_owned(),
        port,
        address: address.to_owned(),
    })
}
fn send_sigterm(pid: i32) -> Result<(), String> {
    let result = unsafe { libc::kill(pid, libc::SIGTERM) };
    if result == 0 {
        Ok(())
    } else {
        Err(format!(
            "could not send SIGTERM to PID {pid}: {}",
            io::Error::last_os_error()
        ))
    }
}
fn truncate(value: &str, width: usize) -> String {
    if value.chars().count() <= width {
        return value.to_owned();
    }
    if width == 0 {
        return String::new();
    }
    let prefix: String = value.chars().take(width.saturating_sub(1)).collect();
    format!("{prefix}…")
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::{Terminal, backend::TestBackend, buffer::Buffer};

    fn listener(origin: Origin, port: u16, name: &str) -> Listener {
        Listener {
            origin,
            kind: ListenerKind::Process,
            port,
            pid: i32::from(port),
            user: "me".into(),
            process: name.into(),
            address: format!("127.0.0.1:{port}"),
        }
    }
    fn buffer_text(app: &App, width: u16, height: u16) -> String {
        rendered_buffer(app, width, height)
            .content
            .iter()
            .map(|cell| cell.symbol())
            .collect()
    }
    fn rendered_buffer(app: &App, width: u16, height: u16) -> Buffer {
        let backend = TestBackend::new(width, height);
        let mut terminal = Terminal::new(backend).unwrap();
        terminal.draw(|frame| render(frame, app)).unwrap();
        terminal.backend().buffer().clone()
    }
    #[test]
    fn parses_ipv4_and_ipv6_listeners() {
        assert_eq!(
            parse_lsof_line("node 1234 wilber 21u IPv4 0xabc 0t0 TCP 127.0.0.1:3000 (LISTEN)")
                .unwrap()
                .port,
            3000
        );
        assert_eq!(
            parse_lsof_line("python3 987 root 5u IPv6 0xdef 0t0 TCP [::1]:8080 (LISTEN)")
                .unwrap()
                .address,
            "[::1]:8080"
        );
    }
    #[test]
    fn detects_wsl_from_microsoft_kernel_version() {
        assert!(is_wsl_kernel_version(
            "Linux version 5.15.90.1-microsoft-standard-WSL2"
        ));
        assert!(!is_wsl_kernel_version("Linux version 6.8.0-generic"));
    }
    #[test]
    fn parses_windows_listener_and_portproxy_json() {
        let listeners = parse_windows_listeners(r#"[{"Kind":"listener","Port":3000,"Address":"127.0.0.1","Pid":42,"Process":"node","User":"-","Target":""},{"Kind":"portproxy","Port":8000,"Address":"0.0.0.0","Pid":4324,"Process":"portproxy (IP Helper)","User":"SYSTEM","Target":"172.28.25.34:8000"}]"#).unwrap();
        assert_eq!(listeners[0].origin, Origin::Windows);
        assert!(matches!(
            listeners[1].kind,
            ListenerKind::WindowsPortProxy { .. }
        ));
    }
    #[test]
    fn renders_both_section_headings_in_one_view() {
        let mut app = App::loading(true);
        app.set_discovery(Ok(vec![
            listener(Origin::Local, 3000, "node"),
            listener(Origin::Windows, 8000, "portproxy"),
        ]));
        let text = buffer_text(&app, 100, 24);
        assert!(text.contains("Linux / local"));
        assert!(text.contains("Windows host"));
        assert!(text.contains("3000"));
        assert!(text.contains("8000"));
    }
    #[test]
    fn renders_distinct_labels_and_emphasis_for_listing() {
        let mut app = App::loading(true);
        app.set_discovery(Ok(vec![
            listener(Origin::Local, 3000, "node"),
            listener(Origin::Windows, 8000, "portproxy"),
        ]));
        let buffer = rendered_buffer(&app, 100, 24);
        let text: String = buffer.content.iter().map(|cell| cell.symbol()).collect();
        assert!(text.contains("[LOCAL]"));
        assert!(text.contains("[WINDOWS HOST • INFO ONLY]"));
        assert!(text.contains("[KEYS]"));
        assert!(buffer.content.iter().any(|cell| {
            cell.modifier
                .contains(Modifier::BOLD | Modifier::UNDERLINED)
        }));
        assert!(
            buffer
                .content
                .iter()
                .any(|cell| cell.modifier.contains(Modifier::REVERSED))
        );
    }
    #[test]
    fn renders_cautious_and_informational_popups() {
        let local = listener(Origin::Local, 3000, "node");
        let mut confirm = App::loading(false);
        confirm.set_discovery(Ok(vec![local]));
        confirm.mode = Mode::Confirm(0);
        let confirm_text = buffer_text(&confirm, 100, 24);
        assert!(confirm_text.contains("[CONFIRM] Terminate local process"));
        assert!(confirm_text.contains("[CAUTION] Send SIGTERM"));

        let windows = listener(Origin::Windows, 8000, "portproxy");
        let mut info = App::loading(true);
        info.set_discovery(Ok(vec![windows]));
        info.mode = Mode::WindowsInfo(0);
        let info_text = buffer_text(&info, 100, 24);
        assert!(info_text.contains("[WINDOWS HOST] Information only"));
        assert!(info_text.contains("[WINDOWS HOST • INFO ONLY]"));
    }
    #[test]
    fn navigation_skips_non_selectable_section_rows() {
        let mut app = App::loading(true);
        app.set_discovery(Ok(vec![
            listener(Origin::Local, 3000, "node"),
            listener(Origin::Windows, 8000, "proxy"),
        ]));
        let first = app.selected_row.unwrap();
        assert!(matches!(app.rows[first], Row::Service(0)));
        app.move_selection(1);
        let second = app.selected_row.unwrap();
        assert!(matches!(app.rows[second], Row::Service(1)));
        assert!(
            second > first + 1,
            "the Windows heading and column label were skipped"
        );
        app.move_selection(-1);
        assert_eq!(app.selected_row, Some(first));
    }
    #[test]
    fn tiny_layout_has_a_safe_fallback() {
        let app = App::loading(true);
        assert!(
            buffer_text(&app, 20, 5).contains("Terminal too small")
                || buffer_text(&app, 20, 5).contains("[SCANNING]")
        );
    }
    #[test]
    fn truncates_only_overlong_values() {
        assert_eq!(truncate("node", 4), "node");
        assert_eq!(truncate("very-long-process", 8), "very-lo…");
        assert_eq!(truncate("node", 0), "");
    }
}
