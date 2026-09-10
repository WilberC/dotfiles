# Herdr: configuración entre macOS, WSL2 y Forge

Esta guía explica qué configuración usa cada entorno y qué comandos ejecutar
después de instalar o actualizar los dotfiles de Herdr.

## Conexiones disponibles

Hay tres aliases para conectarse a Forge:

| Alias | Keybindings | Uso |
| --- | --- | --- |
| `hf` | Locales, predeterminados | Conexión normal |
| `hfk` | Del servidor | Conexión como la anterior `hfk` |
| `hfp` | Locales, predeterminados | Flujo del puente de puertos mediante `forge-ports` |

`hf` usa la opción predeterminada de Herdr:

```fish
herdr --remote forge
```

`hfk` conserva el comportamiento anterior:

```fish
herdr --remote forge --remote-keybindings server
```

`hfp` mantiene la variante separada para el flujo del puente de puertos:

```fish
herdr --remote forge-ports
```

## Dónde vive cada configuración

| Entorno | Configuración relevante | Propósito |
| --- | --- | --- |
| Repositorio | `shared/.config/herdr/config.toml` | Fuente versionada de los keybindings y apariencia compartida |
| WSL2 | `~/.config/herdr/config.toml` | Configuración local de Herdr en WSL2 |
| macOS | `~/.config/herdr/config.toml` | Configuración local de Herdr en macOS |
| Forge | `~/.config/herdr/config.toml` | Configuración del servidor Herdr remoto |

Stow no sincroniza automáticamente tres máquinas. Crea enlaces simbólicos en
la máquina donde se ejecuta, apuntando al checkout local del repositorio.
Para que macOS, WSL2 y Forge tengan la misma configuración, el repositorio
debe estar actualizado en cada máquina y hay que ejecutar Stow allí.

## Instalación o actualización en WSL2/macOS

Desde el checkout de `dotfiles`:

```bash
bash scripts/stow-shared.sh
```

Esto enlaza los archivos compartidos, incluyendo:

- `~/.config/herdr/config.toml`
- los aliases de Fish, incluyendo `hf` y `hfp`
- `~/scripts/herdr-agent-usage`

Después, abre una nueva shell de Fish o recarga sus aliases:

```fish
source ~/.config/fish/conf.d/98-aliases.fish
```

## Actualizar Forge

Si el checkout de Forge está en `~/dotfiles`, actualízalo y vuelve a ejecutar
Stow en Forge:

```bash
cd ~/dotfiles
git pull --ff-only
bash scripts/stow-shared.sh
```

El servidor Herdr persistente no relee automáticamente los cambios del
archivo. Recarga solamente su configuración con:

```bash
ssh -o ClearAllForwardings=yes forge 'herdr server reload-config'
```

Este comando no reinicia Herdr ni cierra panes, agentes o sesiones. Solo hace
falta una vez después de cambiar la configuración en Forge. Las conexiones
posteriores no requieren repetirlo.

## Plugin Agent Usage

El plugin `usagebar` debe estar instalado en Forge, porque `hf` usa los
keybindings del servidor:

```bash
ssh -o ClearAllForwardings=yes forge 'herdr plugin list'
```

Debe aparecer `usagebar` como plugin habilitado. Los shortcuts compartidos
son:

- `Ctrl+Shift+U`: abre el panel de límites mediante
  `~/scripts/herdr-agent-usage`.
- `Ctrl+Shift+M`: actualiza los medidores mediante `usagebar.refresh`.

Si el plugin no está instalado en Forge:

```bash
ssh -o ClearAllForwardings=yes forge \
  'herdr plugin install senna-lang/herdr-agent-usage'
ssh -o ClearAllForwardings=yes forge 'herdr plugin action invoke usagebar.setup'
ssh -o ClearAllForwardings=yes forge 'herdr server reload-config'
```

## Flujo recomendado

Después de modificar esta configuración:

1. Haz `git pull` en la máquina que vas a actualizar.
2. Ejecuta `bash scripts/stow-shared.sh` en esa máquina.
3. Si cambió `shared/.config/herdr/config.toml`, ejecuta el `reload-config`
   remoto una vez.
4. Conéctate normalmente con `hf`.
5. Usa `hfk` si necesitas los keybindings del servidor.
6. Usa `hfp` únicamente cuando necesites el flujo del puente de puertos.

El target SSH `forge` no debe contener `LocalForward`. Los forwards deben
vivir solamente en el target `forge-ports`, que es el que utiliza `hfp`.

## Actualizar Herdr sin cerrar sesiones

Para actualizar Herdr en el entorno actual y Forge con un solo comando:

```bash
bash scripts/update-herdr.sh
```

El helper ejecuta primero `herdr update --handoff` en el entorno local, usando
`mise` tanto en WSL2 como en Linux o macOS. Luego compara esa versión con la de
Forge y solo actualiza Forge si son diferentes. El handoff intenta mover el
servidor a la versión nueva manteniendo panes y sesiones activos. El script
nunca ejecuta `herdr server stop` automáticamente; si el handoff no es posible,
la sesión antigua queda intacta y se informa para decidir después.

Variantes útiles:

```bash
bash scripts/update-herdr.sh --local-only
bash scripts/update-herdr.sh --remote-only
bash scripts/update-herdr.sh --no-handoff
```

Después, comprueba que ambos binarios usan la misma versión:

```bash
herdr --version
ssh -o ClearAllForwardings=yes forge 'mise exec -- herdr --version'
```

macOS y WSL2 pueden conectarse al mismo servidor Herdr de Forge. La
configuración del servidor y sus plugins permanecen en Forge; los keybindings
locales de cada cliente siguen siendo independientes cuando se usa el modo
`local`.

## Diagnóstico rápido

Comprueba que WSL2 esté usando el archivo enlazado:

```bash
readlink -f ~/.config/herdr/config.toml
herdr config check
```

El primer comando debe apuntar a:

```text
~/dotfiles/shared/.config/herdr/config.toml
```

Comprueba que Forge tenga los shortcuts:

```bash
ssh -o ClearAllForwardings=yes forge \
  'rg -n "usagebar|ctrl\\+shift|herdr-agent-usage" ~/.config/herdr/config.toml'
```

Si los puertos aparecen ocupados al usar `ssh forge`, utiliza siempre
`-o ClearAllForwardings=yes` para comandos administrativos que no necesiten
abrir el puente.
