#!/usr/bin/env bash
# ╭──────────────────────────────────────────────────────────╮
# │  wakaze/dotfiles — ติดตั้ง kitty + neovim ในคำสั่งเดียว    │
# │  ใช้ได้กับ Fedora / Ubuntu-Debian / Arch                   │
# ╰──────────────────────────────────────────────────────────╯
set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"

c_ok=$'\033[1;32m'; c_warn=$'\033[1;33m'; c_err=$'\033[1;31m'
c_hi=$'\033[1;35m'; c_dim=$'\033[2m';    c_off=$'\033[0m'

say()  { printf '%s==>%s %s\n' "$c_hi"  "$c_off" "$*"; }
ok()   { printf '  %s✓%s %s\n'  "$c_ok"   "$c_off" "$*"; }
warn() { printf '  %s!%s %s\n'  "$c_warn" "$c_off" "$*"; }
die()  { printf '  %s✗%s %s\n'  "$c_err"  "$c_off" "$*"; exit 1; }

cat <<'BANNER'

  ██     ██  █████  ██   ██  █████  ███████ ███████
  ██     ██ ██   ██ ██  ██  ██   ██    ███  ██
  ██  █  ██ ███████ █████   ███████   ███   █████
  ██ ███ ██ ██   ██ ██  ██  ██   ██  ███    ██
   ███ ███  ██   ██ ██   ██ ██   ██ ███████ ███████

     kitty + neovim  ·  catppuccin mocha  ·  ♡

BANNER

# ─── 1. หา package manager ─────────────────────────────────
say "ตรวจระบบ"
if   command -v dnf     >/dev/null 2>&1; then PM=dnf
elif command -v apt-get >/dev/null 2>&1; then PM=apt
elif command -v pacman  >/dev/null 2>&1; then PM=pacman
else PM=none; fi

if [ "$PM" = none ]; then
  warn "ไม่รู้จัก package manager — จะข้ามขั้นตอนติดตั้ง แล้วทำแค่ symlink"
else
  ok "package manager: $PM"
fi

# ─── 2. ติดตั้ง dependency ──────────────────────────────────
if [ "$PM" != none ]; then
  say "ติดตั้ง dependency (ต้องใส่รหัส sudo)"
  case "$PM" in
    dnf)    sudo dnf install -y neovim kitty git curl wget2-wget unzip tar \
                gcc gcc-c++ make ripgrep fd-find jq nodejs npm python3-pip \
                google-noto-sans-thai-fonts ;;
    apt)    sudo apt-get update && sudo apt-get install -y \
                neovim kitty git curl wget unzip tar \
                gcc g++ make ripgrep fd-find jq nodejs npm python3-pip \
                fonts-noto-core ;;
    pacman) sudo pacman -Sy --needed --noconfirm \
                neovim kitty git curl wget unzip tar \
                gcc make ripgrep fd jq nodejs npm python-pip noto-fonts ;;
  esac
  [ $? -eq 0 ] && ok "dependency พร้อม" || warn "บางแพ็กเกจติดตั้งไม่สำเร็จ — ดูข้อความด้านบน"
fi

# nvim ต้อง >= 0.10 (config นี้ใช้ vim.uv / vim.lsp.config)
if command -v nvim >/dev/null 2>&1; then
  NVER="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
  NMAJ="${NVER%%.*}"; NMIN="${NVER##*.}"
  if [ "$NMAJ" -eq 0 ] && [ "$NMIN" -lt 10 ]; then
    warn "neovim $NVER เก่าเกินไป — config นี้ต้องการ 0.10 ขึ้นไป"
    warn "ลองใช้ appimage: https://github.com/neovim/neovim/releases"
  else
    ok "neovim $NVER"
  fi
else
  die "ไม่พบ neovim"
fi

# ─── 3. ฟอนต์ Nerd Font ─────────────────────────────────────
say "ตรวจฟอนต์"
FONTDIR="$HOME/.local/share/fonts"
if fc-list 2>/dev/null | grep -qi 'Cascadia Code NF'; then
  ok "Cascadia Code NF มีแล้ว"
else
  warn "ไม่พบ Cascadia Code NF — กำลังดาวน์โหลด"
  mkdir -p "$FONTDIR"
  TMP="$(mktemp -d)"
  URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
  if curl -fL# -o "$TMP/cc.zip" "$URL" && unzip -qo "$TMP/cc.zip" -d "$FONTDIR/CascadiaCodeNF"; then
    fc-cache -f "$FONTDIR" >/dev/null 2>&1
    ok "ติดตั้ง Cascadia Code NF แล้ว"
  else
    warn "ดาวน์โหลดฟอนต์ไม่สำเร็จ — โหลดเองที่ nerdfonts.com แล้วรัน fc-cache -f"
  fi
  rm -rf "$TMP"
fi

fc-list 2>/dev/null | grep -qi 'Noto Sans Thai' \
  && ok "Noto Sans Thai มีแล้ว (ภาษาไทยในเทอร์มินัลจะไม่เป็นกล่อง)" \
  || warn "ไม่พบ Noto Sans Thai — ภาษาไทยอาจแสดงเป็นกล่อง"

# ─── 4. symlink config ──────────────────────────────────────
link() {
  local src="$1" dst="$2" name="$3"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    [ "$(readlink -f "$dst")" = "$src" ] && { ok "$name เชื่อมไว้อยู่แล้ว"; return; }
    rm -f "$dst"
  elif [ -e "$dst" ]; then
    mv "$dst" "$dst.backup-$STAMP"
    warn "ของเดิมย้ายไปเป็น $(basename "$dst").backup-$STAMP"
  fi
  ln -s "$src" "$dst"
  ok "$name  ->  $dst"
}

say "เชื่อม config"
link "$DOTFILES/kitty" "$CONFIG/kitty" "kitty"
link "$DOTFILES/nvim"  "$CONFIG/nvim"  "nvim"

# ─── 5. ให้ lazy.nvim โหลดปลั๊กอิน ───────────────────────────
say "ติดตั้งปลั๊กอิน neovim (รอสักครู่ ~1-3 นาที)"
nvim --headless "+Lazy! install" +qa 2>&1 | tail -3
nvim --headless "+Lazy! restore" +qa 2>&1 | tail -3
PLUGINS="$(ls -1 "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy" 2>/dev/null | wc -l)"
ok "ปลั๊กอิน $PLUGINS ตัว (ล็อกเวอร์ชันตาม lazy-lock.json)"

# ─── 6. treesitter parser ───────────────────────────────────
say "ติดตั้ง treesitter parser (คอมไพล์ — อาจนานหน่อย)"
nvim --headless "+Lazy! load nvim-treesitter" "+TSUpdateSync" +qa 2>&1 | tail -3
PARSERS="$(ls -1 "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/nvim-treesitter/parser" 2>/dev/null | wc -l)"
ok "parser $PARSERS ภาษา"

# ─── 7. LSP + formatter ผ่าน mason ──────────────────────────
# หมายเหตุ: mason-lspconfig ตั้งใจข้าม ensure_installed ตอน headless
# เลยต้องสั่ง MasonInstall ตรง ๆ (ซึ่งใน headless มันจะรอจนเสร็จให้เอง)
say "ติดตั้ง LSP / formatter ผ่าน mason (~2-5 นาที)"
MASON_PKGS="lua-language-server typescript-language-server html-lsp css-lsp \
json-lsp yaml-language-server eslint-lsp tailwindcss-language-server \
emmet-language-server bash-language-server dockerfile-language-server pyright \
stylua prettierd black isort shfmt eslint_d"
# shellcheck disable=SC2086
nvim --headless -c "MasonInstall $MASON_PKGS" -c "qa" 2>&1 | tail -5
TOOLS="$(ls -1 "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/packages" 2>/dev/null | wc -l)"
if [ "$TOOLS" -ge 15 ]; then
  ok "mason $TOOLS ตัว"
else
  warn "mason ลงได้ $TOOLS ตัว (คาดว่า 18) — เปิด nvim แล้วสั่ง :Mason ดูตัวที่ตกหล่นได้"
fi

# ─── statusline ของ claude code (ถ้ามีติดตั้งไว้) ───────────
if [ -d "$HOME/.claude" ]; then
  say "ตั้งค่า statusline ของ claude code"
  SL="$DOTFILES/claude/statusline.sh"
  chmod +x "$SL" 2>/dev/null
  CS="$HOME/.claude/settings.json"
  if command -v jq >/dev/null 2>&1; then
    [ -f "$CS" ] || echo '{}' > "$CS"
    if jq --arg cmd "$SL" \
         '.statusLine = {type:"command", command:$cmd, padding:0}' \
         "$CS" > "$CS.tmp" 2>/dev/null; then
      mv "$CS.tmp" "$CS"
      ok "statusline พร้อมใช้ (เปิด claude ใหม่เพื่อเห็นผล)"
    else
      rm -f "$CS.tmp"
      warn "แก้ $CS ไม่สำเร็จ — เพิ่ม statusLine เองได้จาก README"
    fi
  else
    warn "ไม่มี jq — ข้าม statusline (ดูวิธีตั้งเองใน README)"
  fi
fi

# ─── เสร็จ ──────────────────────────────────────────────────
cat <<FINISH

${c_ok}เสร็จแล้ว!${c_off}

  ${c_dim}เปิดใช้งาน${c_off}
    kitty          เปิดเทอร์มินัล (ปิด-เปิดใหม่ถ้าเปิดอยู่)
    nvim           เปิด editor

  ${c_dim}3 ปุ่มที่ต้องจำ${c_off}
    Space Space    หาไฟล์
    Ctrl + n       เปิด/ปิดต้นไม้ไฟล์
    Space (ค้าง)   เมนูช่วยจำโผล่มาเอง

FINISH
