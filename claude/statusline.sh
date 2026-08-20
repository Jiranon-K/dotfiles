#!/usr/bin/env bash
# ─── claude code statusline ─── catppuccin mocha / 2 บรรทัด ───
# stdin: JSON จาก claude code   stdout: 1-2 บรรทัด

# ── ปรับแต่งได้ตรงนี้ ──────────────────────────────────────
BAR_ON="▰"; BAR_OFF="▱"   # ตัวอักษรแท่งวัด (มีครบใน Cascadia Code NF)
CTX_W=20                  # ความยาวแท่ง context
USE_W=18                  # ความยาวแท่ง usage limit
SHOW_5H=1                 # 1 = โชว์ลิมิต 5 ชม. ด้วย, 0 = เอาแค่รายสัปดาห์
# ───────────────────────────────────────────────────────────

input=$(cat)

# ไม่มี jq ก็ยังโชว์โฟลเดอร์ได้ ไม่ต้องพัง
if ! command -v jq >/dev/null 2>&1; then
  printf '\033[38;2;203;166;247m✿ \033[38;2;137;180;250m%s\033[0m\n' "${PWD/#$HOME/\~}"
  exit 0
fi

# ── palette (catppuccin mocha, ตรงกับ kitty + nvim) ──
c() { printf '\033[38;2;%s;%s;%sm' "$1" "$2" "$3"; }
R=$'\033[0m'; DIM=$(c 69 71 90)      # surface1 — เส้นคั่น / แท่งที่ยังว่าง
MAUVE=$(c 203 166 247); BLUE=$(c 137 180 250); GREEN=$(c 166 227 161)
YELLOW=$(c 249 226 175); PEACH=$(c 250 179 135); RED=$(c 243 139 168)
TEAL=$(c 148 226 213); GREY=$(c 127 132 156)

# ── อ่านค่าจาก JSON ครั้งเดียว ──
eval "$(jq -r '
  @sh "DIR=\(.workspace.current_dir // .cwd // "")",
  @sh "MODEL=\(.model.display_name // "claude")",
  @sh "MODEL_ID=\(.model.id // "")",
  @sh "EFFORT=\(.effort.level // "")",
  @sh "TRANSCRIPT=\(.transcript_path // "")",
  @sh "COST=\(.cost.total_cost_usd // 0)",
  @sh "CTX_USED=\(.context_window.total_input_tokens // "")",
  @sh "CTX_SIZE=\(.context_window.context_window_size // "")",
  @sh "CTX_PCT=\(.context_window.used_percentage // "")",
  @sh "W_PCT=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "W_RESET=\(.rate_limits.seven_day.resets_at // "")",
  @sh "H_PCT=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "H_RESET=\(.rate_limits.five_hour.resets_at // "")"
' <<<"$input")"

# ไล่สีตามเปอร์เซ็นต์ที่ใช้ไป
heat() {
  if   [ "$1" -ge 90 ]; then printf '%s' "$RED"
  elif [ "$1" -ge 70 ]; then printf '%s' "$PEACH"
  elif [ "$1" -ge 50 ]; then printf '%s' "$YELLOW"
  else                       printf '%s' "$TEAL"; fi
}

# แท่งวัด: $1=เปอร์เซ็นต์ $2=ความยาว
bar() {
  local p=$1 w=$2 f i on="" off=""
  f=$(( p * w / 100 )); [ "$f" -gt "$w" ] && f=$w; [ "$f" -lt 0 ] && f=0
  for ((i = 0; i < f; i++));   do on+="$BAR_ON"; done
  for ((i = f; i < w; i++));   do off+="$BAR_OFF"; done
  printf '%s%s%s%s' "$(heat "$p")" "$on" "$DIM" "$off"
}

# 94400 → 94.4k, 1000000 → 1M
kfmt() {
  awk -v n="$1" 'BEGIN{
    if (n >= 1000000) { v = n/1000000; printf (v==int(v) ? "%.0fM" : "%.1fM"), v }
    else if (n >= 1000) { v = n/1000; printf (v==int(v) ? "%.0fk" : "%.1fk"), v }
    else printf "%d", n }'
}

# epoch → 3d / 5h / 42m
countdown() {
  local s=$(( $1 - $(date +%s) ))
  [ "$s" -le 0 ] && { printf 'now'; return; }
  if   [ "$s" -ge 86400 ]; then printf '%dd' $(( s / 86400 ))
  elif [ "$s" -ge 3600 ];  then printf '%dh' $(( s / 3600 ))
  else                          printf '%dm' $(( s / 60 )); fi
}

SEP="${DIM} │ "

# ═══ บรรทัดที่ 1 ═══════════════════════════════════════════

# โฟลเดอร์ — ย่อ $HOME เป็น ~ แล้วเหลือ 2 ชั้นสุดท้าย
[ -z "$DIR" ] && DIR="$PWD"
short="${DIR/#$HOME/\~}"
case "$short" in
  */*/*) short=".../${short#"${short%/*/*}/"}" ;;
esac
L1="${MAUVE}✿ ${BLUE}${short}"

# git — สาขา + จำนวนไฟล์ที่แก้
if branch=$(git -C "$DIR" symbolic-ref --short -q HEAD 2>/dev/null ||
            git -C "$DIR" rev-parse --short HEAD 2>/dev/null); then
  dirty=$(git -C "$DIR" status --porcelain 2>/dev/null | grep -c .)
  if [ "$dirty" -gt 0 ]; then
    L1+="  ${YELLOW} ${branch}${PEACH}●${dirty}"
  else
    L1+="  ${GREEN} ${branch}"
  fi
fi

# โมเดล + effort
L1+="${SEP}${GREY}${MODEL,,}"
[ -n "$EFFORT" ] && L1+="${DIM} · ${GREY}${EFFORT}"

# context — ใช้ค่าที่ claude ส่งมา ถ้าไม่มีค่อยคำนวณจาก transcript
pct=""; used="$CTX_USED"; size="$CTX_SIZE"
if [ -n "$CTX_PCT" ]; then
  pct=${CTX_PCT%.*}
elif [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  used=$(tac "$TRANSCRIPT" 2>/dev/null | grep -m1 '"usage"' | jq -r '
    (.message.usage // {}) |
    ((.input_tokens // 0) + (.cache_read_input_tokens // 0)
     + (.cache_creation_input_tokens // 0))' 2>/dev/null)
  if [ "${used:-0}" -gt 0 ] 2>/dev/null; then
    case "$MODEL_ID" in *1m*) size=1000000 ;; *) size=200000 ;; esac
    pct=$(( used * 100 / size ))
  fi
fi
if [ -n "$pct" ]; then
  L1+="${SEP}${GREY}tok "
  [ -n "$used" ] && [ -n "$size" ] &&
    L1+="$(kfmt "$used")${DIM}/${GREY}$(kfmt "$size") "
  L1+="$(heat "$pct")${pct}%  $(bar "$pct" "$CTX_W")"
fi

# ค่าใช้จ่าย — โชว์เมื่อเกิน 1 เซนต์
awk "BEGIN{exit !($COST > 0.01)}" 2>/dev/null &&
  L1+="$(printf '%s%s$%.2f' "$SEP" "$GREY" "$COST")"

printf '%s%s\n' "$L1" "$R"

# ═══ บรรทัดที่ 2 ═══ usage limit (ข้ามไปถ้า claude ไม่ส่งมา) ═══

gauge() {   # $1=ป้าย  $2=เปอร์เซ็นต์  $3=resets_at
  local p=${2%.*}
  [ -z "$p" ] && return 1
  printf '%s%s %s %s%d%%' "$GREY" "$1" "$(bar "$p" "$USE_W")" "$(heat "$p")" "$p"
  [ -n "$3" ] && printf '%s  %s' "$DIM" "$(countdown "$3")"
}

L2=""
[ "$SHOW_5H" = 1 ] && L2=$(gauge 5h "$H_PCT" "$H_RESET")
W=$(gauge 7d "$W_PCT" "$W_RESET") && { [ -n "$L2" ] && L2+="$SEP"; L2+="$W"; }
[ -n "$L2" ] && printf '%susage  %s%s\n' "$DIM" "$L2" "$R"

exit 0
