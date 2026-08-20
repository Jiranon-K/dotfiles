#!/usr/bin/env bash
# ─── claude code statusline ─── catppuccin mocha / minimal ───
# stdin: JSON จาก claude code   stdout: 1 บรรทัด

# โชว์ลิมิต 5 ชั่วโมงด้วยไหม (0 = ไม่, 1 = โชว์ตลอด, 2 = โชว์เมื่อเกิน 50%)
SHOW_5H=2

input=$(cat)

# ไม่มี jq ก็ยังโชว์โฟลเดอร์ได้ ไม่ต้องพัง
if ! command -v jq >/dev/null 2>&1; then
  printf '\033[38;2;203;166;247m✿ \033[38;2;137;180;250m%s\033[0m\n' "${PWD/#$HOME/\~}"
  exit 0
fi

# ── palette (catppuccin mocha, ตรงกับ kitty + nvim) ──
c()  { printf '\033[38;2;%s;%s;%sm' "$1" "$2" "$3"; }
R=$'\033[0m'; DIM=$(c 69 71 90)      # surface1 — เส้นคั่น
MAUVE=$(c 203 166 247); BLUE=$(c 137 180 250); GREEN=$(c 166 227 161)
YELLOW=$(c 249 226 175); PEACH=$(c 250 179 135); RED=$(c 243 139 168)
TEAL=$(c 148 226 213); GREY=$(c 127 132 156)

# ── อ่านค่าจาก JSON ครั้งเดียว ──
eval "$(jq -r '
  @sh "DIR=\(.workspace.current_dir // .cwd // "")",
  @sh "MODEL=\(.model.display_name // "claude")",
  @sh "MODEL_ID=\(.model.id // "")",
  @sh "TRANSCRIPT=\(.transcript_path // "")",
  @sh "COST=\(.cost.total_cost_usd // 0)",
  @sh "CTXPCT=\(.context_window.used_percentage // "")",
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

# วินาที → 3d / 5h / 42m
countdown() {
  local s=$(( $1 - $(date +%s) ))
  [ "$s" -le 0 ] && { printf 'now'; return; }
  if   [ "$s" -ge 86400 ]; then printf '%dd' $(( s / 86400 ))
  elif [ "$s" -ge 3600 ];  then printf '%dh' $(( s / 3600 ))
  else                          printf '%dm' $(( s / 60 )); fi
}

# ── 1. โฟลเดอร์ ── ย่อ $HOME เป็น ~ แล้วเหลือ 2 ชั้นสุดท้าย
short="${DIR/#$HOME/\~}"
case "$short" in
  */*/*) short=".../${short#"${short%/*/*}/"}" ;;
esac

# ── 2. git ── สาขา + จำนวนไฟล์ที่แก้
GIT=""
if branch=$(git -C "$DIR" symbolic-ref --short -q HEAD 2>/dev/null ||
            git -C "$DIR" rev-parse --short HEAD 2>/dev/null); then
  dirty=$(git -C "$DIR" status --porcelain 2>/dev/null | grep -c .)
  if [ "$dirty" -gt 0 ]; then
    GIT="${YELLOW} ${branch}${PEACH}●${dirty}"
  else
    GIT="${GREEN} ${branch}"
  fi
fi

# ── 3. context ── ใช้ค่าที่ claude ส่งมา ถ้าไม่มีค่อยคำนวณจาก transcript
pct=""
if [ -n "$CTXPCT" ]; then
  pct=${CTXPCT%.*}
elif [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  used=$(tac "$TRANSCRIPT" 2>/dev/null | grep -m1 '"usage"' | jq -r '
    (.message.usage // {}) |
    ((.input_tokens // 0) + (.cache_read_input_tokens // 0)
     + (.cache_creation_input_tokens // 0))' 2>/dev/null)
  if [ "${used:-0}" -gt 0 ] 2>/dev/null; then
    case "$MODEL_ID" in *1m*) limit=1000000 ;; *) limit=200000 ;; esac
    pct=$(( used * 100 / limit ))
  fi
fi
CTX=""
if [ -n "$pct" ]; then
  filled=$(( pct * 5 / 100 )); bar=""
  for i in 1 2 3 4 5; do
    [ "$i" -le "$filled" ] && bar+="█" || bar+="░"
  done
  CTX="$(heat "$pct")${bar} ${pct}%"
fi

# ── 4. usage limit ── รายสัปดาห์ (+ 5 ชั่วโมง ตาม SHOW_5H)
limit_seg() {   # $1=label  $2=percent  $3=resets_at
  local p=${2%.*}
  [ -z "$p" ] && return
  printf '%s%s %d%%' "$(heat "$p")" "$1" "$p"
  [ -n "$3" ] && printf '%s ↻%s' "$DIM" "$(countdown "$3")"
}
WEEK=$(limit_seg week "$W_PCT" "$W_RESET")
HOUR=""
case "$SHOW_5H" in
  1) HOUR=$(limit_seg 5h "$H_PCT" "$H_RESET") ;;
  2) [ -n "$H_PCT" ] && [ "${H_PCT%.*}" -ge 50 ] 2>/dev/null &&
       HOUR=$(limit_seg 5h "$H_PCT" "$H_RESET") ;;
esac

# ── 5. cost ── โชว์เมื่อเกิน 1 เซนต์
CST=""
if awk "BEGIN{exit !($COST > 0.01)}" 2>/dev/null; then
  CST=$(printf '%s$%.2f' "$GREY" "$COST")
fi

# ── ประกอบ ──
sep="${DIM} · "
out="${MAUVE}✿ ${BLUE}${short}"
for seg in "$GIT" "${GREY}${MODEL,,}" "$CTX" "$HOUR" "$WEEK" "$CST"; do
  [ -n "$seg" ] && out+="${sep}${seg}"
done
printf '%s%s\n' "$out" "$R"
