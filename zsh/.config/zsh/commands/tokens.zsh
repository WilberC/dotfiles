function tokens {
  python3 - "$@" << 'PYEOF'
import sys, re

# Formula: 2 * layers * kv_heads * head_dim * bytes_per_element
# Labels describe architecture shape, not a specific model.
ARCHETYPES = [
    ("~7B  GQA fp16",  131072),   # 2*32*8*128*2
    ("~7B  GQA  q4",    65536),
    ("~13B MHA fp16",  327680),   # 2*40*40*128*2  (full MHA, no GQA)
    ("~32B GQA fp16",  262144),   # 2*64*8*128*2
    ("~70B GQA fp16",  327680),   # 2*80*8*128*2
    ("~70B GQA  q4",   163840),
]

# Common real models mapped to the table + notes
GUIDE = [
    ("3B",      "use calc",        "too small/varied — e.g. Llama 3.2 3B: layers=28, kv=8"),
    ("7–9B",    "~7B  GQA fp16",   "Llama 3 8B, Mistral 7B, Qwen2.5 7B, Qwen3 9B(*)"),
    ("13B old", "~13B MHA fp16",   "Llama 2 13B — full MHA (40 heads, no GQA)"),
    ("14B",     "use calc",        "Qwen2.5 14B: layers=40 kv=8 → closer to ~13B GQA"),
    ("27B",     "use calc",        "Gemma 2 27B: head_dim=256, very different KV size"),
    ("32–35B",  "~32B GQA fp16",   "Qwen2.5 32B, Mistral-Small 3.1, Phi-4"),
    ("70–72B",  "~70B GQA fp16",   "Llama 3.1 70B, Qwen2.5 72B, DeepSeek 67B"),
]

GUIDE_NOTE = "(*) Qwen3 9B: 36 layers — slightly above ~7B row. Use: tokens calc 36 8 128 fp16"

PREC_BYTES = {"fp32": 4, "fp16": 2, "bf16": 2, "q8": 1, "q4": 0.5, "q2": 0.25}
GiB  = 1073741824
BOLD = "\033[1m"; CYAN = "\033[36m"; YEL = "\033[33m"; DIM = "\033[2m"; RST = "\033[0m"

COUNTS = [4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576]

def fmt_tok(n):
    if n >= 1_000_000: return f"{n/1_000_000:.1f}M"
    if n >= 1000:      return f"{n/1000:.0f}K"
    return str(int(n))

def fmt_gb(g):
    return f"{g:.2f} GB"

def make_table(models, counts):
    max_lbl  = max(len(lb) for lb, _ in models)
    max_data = len("320.00 GB")
    cw       = max(max_lbl, max_data) + 2   # uniform col width, padded

    tok_col = 8
    header  = (f"{BOLD}{CYAN}{'Tokens':^{tok_col}}{RST} │ "
               + " │ ".join(f"{BOLD}{CYAN}{lb:^{cw}}{RST}" for lb, _ in models))
    div     = "─" * tok_col + "─┼─" + "─┼─".join("─" * cw for _ in models)

    print(header)
    print(div)
    for t in counts:
        cells = [f"{fmt_gb(t * bpt / GiB):^{cw}}" for _, bpt in models]
        print(f"{fmt_tok(t):>{tok_col}} │ " + " │ ".join(cells))
    print(f"\n{DIM}KV cache VRAM only — model weights not included.{RST}")

def show_guide():
    w_size  = max(len(r[0]) for r in GUIDE)
    w_arch  = max(len(r[1]) for r in GUIDE)
    print(f"\n{BOLD}{YEL}How to pick an archetype{RST}")
    print(f"{DIM}Most models ≥2023 use GQA (8 KV heads, head_dim 128). Older 13B use full MHA.{RST}\n")
    hdr = f"  {'Size':<{w_size}}  {'→ Use archetype':<{w_arch}}  Notes"
    print(hdr)
    print("  " + "─" * (len(hdr) - 2))
    for size, arch, note in GUIDE:
        print(f"  {size:<{w_size}}  {arch:<{w_arch}}  {DIM}{note}{RST}")
    print(f"\n{DIM}{GUIDE_NOTE}{RST}")
    print(f"\n{DIM}Exact match: tokens calc <layers> <kv_heads> [head_dim=128] [prec=fp16]{RST}")
    print(f"{DIM}Find params in model's config.json on HuggingFace (num_hidden_layers, num_key_value_heads).{RST}\n")

def show_ref_table():
    print(f"\n{BOLD}Reference table — common architecture archetypes{RST}\n")
    make_table(ARCHETYPES, COUNTS)
    show_guide()

def calc_model(layers, kv_heads, head_dim, prec, target=None):
    if prec not in PREC_BYTES:
        print(f"Unknown precision '{prec}'. Use: {', '.join(PREC_BYTES)}", file=sys.stderr)
        sys.exit(1)
    bpt   = int(2 * layers * kv_heads * head_dim * PREC_BYTES[prec])
    label = f"L{layers} KV{kv_heads} D{head_dim} {prec}"

    print(f"\n{BOLD}Custom model: {label}{RST}")
    print(f"{DIM}bytes/token = {bpt:,}  ({bpt/1024:.1f} KB){RST}\n")

    if target is None:
        make_table([(label, bpt)], COUNTS)
    else:
        val, is_gb = target
        if is_gb:
            t = val * GiB / bpt
            print(f"  {fmt_gb(val)} VRAM  →  {fmt_tok(t)} tokens in KV cache")
        else:
            g = val * bpt / GiB
            print(f"  {fmt_tok(val)} tokens  →  {fmt_gb(g)} KV cache VRAM")
        print(f"\n{DIM}(model weights not included){RST}")
    print()

def convert(val, is_gb):
    w = max(len(lb) for lb, _ in ARCHETYPES)
    print(f"\n{BOLD}{CYAN}{'Archetype':<{w}}  {'Value':>12}{RST}")
    print("─" * (w + 14))
    for label, bpt in ARCHETYPES:
        if is_gb:
            t = val * GiB / bpt
            print(f"{label:<{w}}  {fmt_tok(t):>12} tokens")
        else:
            g = val * bpt / GiB
            print(f"{label:<{w}}  {fmt_gb(g):>12}")
    note = "VRAM → max tokens in KV cache" if is_gb else "tokens → VRAM for KV cache"
    print(f"\n{DIM}{fmt_gb(val) if is_gb else fmt_tok(val)} → {note} (weights extra){RST}\n")

def parse_val(s):
    s = s.strip().lower()
    if s.endswith("gb"): return float(s[:-2].strip()), True
    if s.endswith("g"):  return float(s[:-1].strip()), True
    return float(s), False

# ── Dispatch ─────────────────────────────────────────────────────────────────
args = sys.argv[1:]

if not args:
    show_ref_table()
    sys.exit(0)

if args[0] == "calc":
    rest = args[1:]
    if len(rest) < 2:
        print("Usage: tokens calc <layers> <kv_heads> [head_dim=128] [prec=fp16] [<N>|<N>gb]", file=sys.stderr)
        sys.exit(1)
    layers   = int(rest[0])
    kv_heads = int(rest[1])
    head_dim = 128
    prec     = "fp16"
    target   = None
    for tok in rest[2:]:
        t = tok.lower()
        if t in PREC_BYTES:          prec     = t
        elif t.isdigit():            head_dim = int(t)
        else:
            try:    target = parse_val(t)
            except: print(f"Cannot parse: {tok}", file=sys.stderr); sys.exit(1)
    calc_model(layers, kv_heads, head_dim, prec, target)
    sys.exit(0)

joined = " ".join(args)
parts  = re.split(r'\s*\+\s*', joined)
if len(parts) > 1:
    parsed = []
    for p in parts:
        try:   parsed.append(parse_val(p))
        except: print(f"Cannot parse: {p}", file=sys.stderr); sys.exit(1)
    all_gb  = all(ig for _, ig in parsed)
    all_tok = all(not ig for _, ig in parsed)
    if not all_gb and not all_tok:
        print("Mix of GB and token values not supported — use same unit.", file=sys.stderr)
        sys.exit(1)
    total     = sum(v for v, _ in parsed)
    unit      = "GB" if all_gb else "tokens"
    parts_str = " + ".join(f"{v:.0f}{unit}" for v, _ in parsed)
    print(f"\n{BOLD}{parts_str} = {total:.0f} {unit}{RST}")
    convert(total, all_gb)
    sys.exit(0)

try:
    convert(*parse_val(args[0]))
except ValueError:
    print("Usage: tokens [<N>|<N>gb] [+ ...] | tokens calc <layers> <kv_heads> [head_dim] [prec] [<N>|<N>gb]", file=sys.stderr)
    sys.exit(1)
PYEOF
}
