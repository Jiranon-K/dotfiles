#!/usr/bin/env bash
# ─── claude code statusline ─── catppuccin mocha / minimal ───
# stdin: JSON จาก claude code   stdout: 1 บรรทัด

input=$(cat)

# ไม่มี jq ก็ยังโชว์โฟลเดอร์ได้ ไม่ต้องพัง
if ! command -v jq >/dev/null 2>&1; then
  printf '\033[38;2;203;166;247m✿ \033[38;2;137;180;250m%s\033[0m\n' "${PWD/#$HOME/\~}"
  exit 0
fi

# ── palette (catppuccin mocha, ตรงกับ kitty + nvim) ──
c()  { printf '\033[38;2;%s;%s;%sm' "$1" "$2" "$3"; }
R=$'\033[0m'; DIM=$(c 69 71 90)      # surface1  — เส้นคั่น
MAUVE=$(c 203 166 247); BLUE=$(c 137 180 250); GREEN=$(c 166 227 161)
YELLOW=$(c 249 226 175); PEACH=$(c 250 179 135); RED=$(c 243 139 168)
TEAL=$(c 148 226 213); GREY=$(c 127 132 156); PINK=$(c 245 194 231)

# ── อ่านค่าจาก JSON ครั้งเดียว ──
eval "$(jq -r '
  @sh "DIR=\(.workspace.current_dir // .cwd // "")",
  @sh "MODEL=\(.model.display_name // "claude")",
  @sh "MODEL_ID=\(.model.id // "")",
  @sh "TRANSCRIPT=\(.transcript_path // "")",
  @sh "COST=\(.cost.total_cost_usd // 0)"
' <<<"$input")"

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

# ── 3. context ── รวม token ล่าสุดจาก transcript
CTX=""
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  used=$(tac "$TRANSCRIPT" 2>/dev/null | grep -m1 '"usage"' | jq -r '
    (.message.usage // {}) |
    ((.input_tokens // 0) + (.cache_read_input_tokens // 0)
     + (.cache_creation_input_tokens // 0))' 2>/dev/null)
  if [ -n "$used" ] && [ "$used" -gt 0 ] 2>/dev/null; then
    case "$MODEL_ID" in *1m*) limit=1000000 ;; *) limit=200000 ;; esac
    pct=$(( used * 100 / limit ))
    if   [ "$pct" -ge 90 ]; then col="$RED"
    elif [ "$pct" -ge 70 ]; then col="$PEACH"
    else                        col="$TEAL"; fi
    # แถบ 5 ช่อง
    filled=$(( pct * 5 / 100 )); bar=""
    for i in 1 2 3 4 5; do
      [ "$i" -le "$filled" ] && bar+="█" || bar+="░"
    done
    CTX="${col}${bar} ${pct}%"
  fi
fi

# ── 4. cost ── โชว์เมื่อเกิน 1 เซนต์
CST=""
if awk "BEGIN{exit !($COST > 0.01)}" 2>/dev/null; then
  CST=$(printf '%s$%.2f' "$GREY" "$COST")
fi

# ── ประกอบ ──
sep="${DIM} · "
out="${MAUVE}✿ ${BLUE}${short}"
[ -n "$GIT" ] && out+="${sep}${GIT}"
out+="${sep}${GREY}${MODEL,,}"
[ -n "$CTX" ] && out+="${sep}${CTX}"
[ -n "$CST" ] && out+="${sep}${CST}"
printf '%s%s\n' "$out" "$R"
