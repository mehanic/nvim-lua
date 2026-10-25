local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
	s({ trig = "arith", name = "Bash Arithmetic", dscr = "Змінні + математичний вираз" }, {
		i(1, "x"), t('='), t('"'), i(2, "3"), t('"\n'),
		i(3, "y"), t('='), t('"'), i(4, "2"), t('"\n'),
		t('echo "$(( $'), rep(1), t(' * ( $'), rep(3), t(' + '), i(5, "1"), t(' ))"')
	}),

	-- 🔹 1. if [ ]  (POSIX-тест: рядки/цілі)
	s("ifb", {
		t("if [ "), i(1, "$VAR1"), t(" "),
		c(2, { t("-lt"), t("-gt"), t("-le"), t("-ge"), t("-eq"), t("-ne"), t("=") }),
		t(" "), i(3, "$VAR2"), t(" ]; then"),
		t({ "", "\techo \"" }), i(4, "message"), t({ "\"" }),
		t({ "", "else" }),
		t({ "", "\techo \"" }), i(5, "else message"), t({ "\"" }),
		t({ "", "fi" }),
	}),

	-- 🔹 2. if (( ))  (Bash-арифметика)
	s("ifa", {
		t("if (( "), i(1, "$VAR1"), t(" "),
		c(2, { t("<"), t(">"), t("<="), t(">="), t("=="), t("!=") }),
		t(" "), i(3, "$VAR2"), t(" )); then"),
		t({ "", "\techo \"" }), i(4, "message"), t({ "\"" }),
		t({ "", "else" }),
		t({ "", "\techo \"" }), i(5, "else message"), t({ "\"" }),
		t({ "", "fi" }),
	}),

	-- 🔹 3. for range  {1..5}
	s("forr", {
		t("for "), i(1, "i"), t(" in {"), i(2, "1"), t(".."), i(3, "5"), t("}; do"),
		t({ "", "\techo $" }), rep(1),
		t({ "", "done" }),
	}),

	-- 🔹 4. for find  (сучасний $() замість ``)
	s("forfind", {
		t("for "), i(1, "file"), t(" in $(find "), i(2, "."), t(" -name \"*."), i(3, "JPG"), t("\"); do"),
		t({ "", "\techo $" }), rep(1),
		t({ "", "done" }),
	}),

	-- 🔹 5. for glob + basename
	s("forglob", {
		t("for "), i(1, "f"), t(" in "), i(2, "~/Downloads/*.JPG"), t("; do"),
		t({ "", "\techo \"Full path: $" }), rep(1), t({ "\"" }),
		t({ "", "\techo \"Just name: $(basename $" }), rep(1), t({ "\")" }),
		t({ "", "done" }),
	}),

	-- 🔹 6. while arithmetic
	s("whilea", {
		t("while (( "), i(1, "$counter"), t(" < "), i(2, "10"), t(" )); do"),
		t({ "", "\techo $" }), rep(1),
		t({ "", "\t" }), rep(1), t("=$(( "), rep(1), t(" + "), i(3, "1"), t(" ))"),
		t({ "", "done" }),
	}),

	-- 🔄 Safe rename lowercase
	s("blower-safe", {
		t("for file in *; do"), t({ "", "\t" }),
		t('lower=$(echo "$file" | tr \'[A-Z]\' \'[a-z]\')'), t({ "", "\t" }),
		t('[[ "$file" != "$lower" ]] && mv -v "$file" "$lower"'), t({ "", "" }),
		t("done"),
	}),

	-- 📊 Benchmark command
	s("bbench", {
		t("{ time "), i(1, "your-command"), t("; } 2>&1 | grep -E 'real|user|sys'"),
	}),

	-- 🌳 Tree-like listing
	s("btree", {
		t("find "), i(1, "."), t(" -maxdepth 3 -print | sed -e 's;[^/]*/;|____;g' -e 's;____|; |;g' -e 's;^;  ;'"),
	}),

	-- 🔗 Join array elements with separator
	s("bjoin", fmt([[
function join() {{
  local sep="$1"
  shift
  builtin echo "$1$(shift; for x; do builtin echo -n "$sep$x"; done)"
}}

# Usage: join "," "a" "b" "c"  →  a,b,c
  ]], {})),

	-- ✂️ Split string by delimiter
	s("bsplit", fmt([[
function split() {{
  local IFS="$1"
  builtin echo $(for x in $2; do builtin echo -n "$x "; done)
}}

# Usage: split "," "a,b,c"  →  a b c
  ]], {})),

	-- 🔤 Rename files to lowercase
	s("blower", {
		t("for i in *; do"), t({ "", "\t" }),
		t('mv "$i" "$(echo "$i" | tr \'[A-Z]\' \'[a-z]\')"'), t({ "", "" }),
		t("done"),
	}),

	-- 🔹 Timer: вимір часу виконання
	s("btimer", fmt([[
START=$(date +%s)

{}

END=$(date +%s)
DIFF_SECOND=$(( $END - $START ))
DIFF_MINUTE=$(( $DIFF_SECOND / 60 ))

echo "⏱ Runtime: {} seconds ({} minutes)"
]], {
		i(1, "# your code here"),
		rep(1),
		rep(1)
	}), {
		descr = "Bash: timer block",
		docstring = [[
      Вимірює час виконання скрипта.
      ${1}: код для виконання
    ]]
	}),

	-- 🔹 Argparse: парсинг аргументів
	s("bargs", fmt([[
while [ "$#" -gt 0 ]; do
  case $1 in
    -s|--server)  shift; SERVER="${{1}}";;
    -d|--date)    shift; DATE="${{2}}";;
    -h|--help)
      echo "Usage: $0 [-s server] [-d date]"
      exit 0;;
    *)
      echo "Unknown option: $1" >&2
      exit 1;;
  esac
  shift
done

echo "Server: $SERVER, Date: $DATE"
]], {}), {
		descr = "Bash: argument parser",
		docstring = [[
      Парсить аргументи командного рядка.
      Підтримує короткі (-s) та довгі (--server) опції.
    ]]
	}),


	-- 🔹 Trap: обробка сигналів
	s("btrap", fmt([[
count=0
cleanup() {{
  echo
  echo "⚠️  Interrupted! Count: $count"
  exit 130
}}
trap cleanup INT TERM

while :; do
  {}
  count=$((count + 1))
  sleep 1
done
]], {
		i(1, "# your loop code")
	}), {
		descr = "Bash: trap signal handler",
		docstring = [[
      Обробляє SIGINT/SIGTERM для коректного завершення.
      ${1}: код у циклі
    ]]
	}),


	-- 🔹 Read password: прихований ввід пароля
	s("bpass", fmt([[
echo -n "Password: "
stty -echo
read {}
stty echo
echo

# Використання: ${{{}}}
]], {
		i(1, "PASSWORD"),
		rep(1)
	}), {
		descr = "Bash: read password (hidden)",
		docstring = [[
      Зчитує пароль без відображення символів.
      ${1}: ім'я змінної для пароля
    ]]
	}),


	-- 🔹 Read single char: один символ без Enter
	s("bchar", fmt([[
echo -n "{} [y/n]: "
tty_state=$(stty -g)
stty raw -echo
char=$(dd bs=1 count=1 2>/dev/null)
stty "$tty_state"
echo

case "$char" in
  [yY]) {} ;;
  [nN]) {} ;;
  *) echo "Invalid input" ;;
esac
]], {
		i(1, "Continue?"),
		i(2, "# yes action"),
		i(3, "# no action")
	}), {
		descr = "Bash: read single character",
		docstring = [[
      Зчитує один символ без натискання Enter.
      Відновлює налаштування терміналу після зчитування.
    ]]
	}),

	-- 🔹 Array iteration — FIXED
	s("bfor_array", fmt([[
{1}=( {2} )

for item in "${{{1}[@]}}"; do
  echo "Processing: $item"
  {3}
done
]], {
		i(1, "ARRAY"),
		i(2, "val1 val2 val3"),
		i(3, "# your code")
	}), {
		descr = "Bash: iterate over array",
		docstring = [[
      Безпечний перебір масиву з цитуванням.
      ${1}: ім'я масиву, ${2}: елементи, ${3}: код циклу
    ]]
	}),


	-- 🔹 Read input: зчитування вводу — FIXED
	s("bread", fmt([[
echo -n "Enter {1}: "
read {1}
echo "✓ {1} = ${{{1}}}"
]], {
		i(1, "variable name")
	}), {
		descr = "Bash: read user input",
		docstring = [[
      Зчитує ввід користувача у змінну.
      ${1}: ім'я змінної
    ]]
	}),

	-- 🔹 Check command exists
	s("bcheck_cmd", fmt([[
check_cmd() {{
  if ! command -v {} &>/dev/null; then
    echo "❌ '{}' not found. Please install it." >&2
    exit 127
  fi
}}

check_cmd
]], {
		i(1, "command_name"),
		rep(1)
	}), {
		descr = "Bash: check if command exists",
		docstring = [[
      Перевіряє наявність команди в PATH.
      ${1}: назва команди
    ]]
	}),



	-- 🔹 Curl retry with progress
	s("bcurl_retry", fmt([[
max_attempts={}
attempt=1

while [ $attempt -le $max_attempts ]; do
  echo "🔄 Attempt $attempt/$max_attempts..."
  if curl -fsSL -o {} {}; then
    echo "✅ Success!"
    break
  fi
  echo "⚠️  Failed, retrying in 2s..."
  sleep 2
  attempt=$((attempt + 1))
done

[ $attempt -gt $max_attempts ] && {{
  echo "❌ Failed after $max_attempts attempts" >&2
  exit 1
}}
]], {
		i(1, "3"),
		i(2, "output_file"),
		i(3, "https://example.com/file")
	}), {
		descr = "Bash: curl with retry logic",
		docstring = [[
      Завантажує файл з автоматичними повторними спробами.
      ${1}: макс. спроб, ${2}: файл виводу, ${3}: URL
    ]]
	}),

	s("bashmenu", {
		t({
			'#!/bin/bash',
			'',
			'while :',
			'do',
			'  echo "Menu :"',
			'  echo "1) list file"',
			'  echo "2) current directory"',
			'  echo "3) exit"',
			'',
			'  read number',
			'  case $number in',
			'    1)',
			'      echo "you pick 1, ls"',
			'      ls',
			'      ;;',
			'    2)',
			'      echo "you pick 2, pwd"',
			'      pwd',
			'      ;;',
			'    3)',
			'      echo "you pick 3, bye~"',
			'      exit',
			'      ;;',
			'    *)',
			'      echo "Error, Unknown Command"',
			'      ;;',
			'  esac',
			'',
			'  echo',
			'',
			'done',
		}),
	}),

	-- 🔹 3. Function with local variable (повторення змінної через rep)
	s("bash-local", {
		i(1, "function_name"), t("() {"), t({ "", "  local " }), i(2, "VAR"), t({ "", "" }),
		rep(2), t('=${3:-"default_value"}'), t({ "", "" }),
		t('  echo "Value: $'), rep(2), t({ '"', '  # your code here', "}" }),
	}),

	-- 🔹 4. Integer argument check
	s("int-check", {
		t({
			'if test "${',
		}), i(1, "1:-}"), t({ ' -eq 0 2>/dev/null; then', '' }),
		t('  echo "✓ Argument is Integer: $1"'), t({ '', '  expr 10 + "$1"' }), t({ '', 'else' }), t({ '', '' }),
		t("  echo \"✗ Argument is not Integer: '${1:-}'\" >&2"), t({ '', '  exit 1' }), t({ '', 'fi' }),
	}),

	-- 🔹 1. tar + pv + gzip (архівація з прогрес-баром)
	s("tar-pv-gzip", {
		t('DATA_DIR="'), i(1, "/path/to/data"), t('"'), t({ '', 'FILE="' }), i(2, "archive"), t({ '"', '', '' }),
		t('cd "$DATA_DIR" || exit 1'), t({ '', '' }),
		t('tar cf - "$FILE" | pv -s "$(du -sb "$FILE" | cut -f1)" | gzip > "${FILE}.tar.gz"'),
	}),

	-- 🔹 2. Bash parameter expansion cheat sheet
	s("var-expand", {
		t({
			'# ${VAR:=default}  : присвоїти default, якщо VAR не встановлено або пусте',
			'# ${VAR:-default}  : використати default, але не змінювати VAR',
			'# ${VAR:?message}  : вивести message і завершити, якщо VAR пустий',
			'# ${VAR:+value}    : використати value, тільки якщо VAR встановлено',
			'',
			'# Приклад безпечного TMPDIR:',
			'TMPDIR="${TMPDIR:=/tmp}"  # := змінює змінну',
			': "${TMPDIR:=/tmp}"       # : + := — безпечний патерн (не змінює, якщо вже є)',
			'',
			'# Перевірка:',
			'if [ -z "${'
		}), i(1, "VAR"), t({ ':?' }), i(2, "VAR must be set"), t({
			'}" ]; then',
			'  exit 1',
			'fi'
		}),
	}),

	-- 🔹 5. Безпечна робота з set -u (уникнення unbound variable)
	s("set_u_safe", {
		t({ '# set -u: ламає скрипт, якщо використати незмінну змінну',
			'set -u',
			'',
			'# ✅ Безпечний доступ до аргументів та змінних:',
			'echo "Arg 1: ${1:-}"',
			'echo "Config: ${CONFIG_FILE:-/etc/app.conf}"',
			'' }),
	}),

	-- 🔹 6. Дата + підрахунок рядків у лозі (wc -l)
	s("date_wc", {
		t('today=$('), i(1, 'date +"%Y%m%d"'), t(')'),
		t({ '', 'wc -l "${', rep(1), '}_log"' }),
	}),

	-- 🔹 7. Загальний шаблон Command Substitution ($() проти ` `)
	s("cmd_subst", {
		t('# ✅ Рекомендовано: $() (зручніше вкладати, не треба екранувати)'),
		t({ '', 'output=$(', i(1, "command arg"), ')' }),
		t({ '', '# ❌ Застаріле: `command` (складно вкладати, треба \\`)', '' }),
	}),

	-- 🔹 3. Перевірка значення + вивід помилки в stderr + exit
	s("bcheck_err", {
		t('if [ "$'), i(1, "result"), t('" = "'), i(2, "invalid value"), t('" ]; then'),
		t({ '', '  echo "ERROR: $', rep(1), '" 1>&2' }),
		t({ '', '  exit ', i(3, "1"), '' }),
		t({ '', 'fi' }),
	}),

	-- 🔹 4. Підрахунок входжень (Command Substitution)
	s("grep_cnt", {
		t(''), i(1, "err_count"), t('=$(grep -c "'), i(2, "ERROR"), t('" '), i(3, "file.log"), t(')'),
		t({ '', 'echo "Count: $', rep(1), '"' }),
	}),

	-- 🔹 1. Витяг даних з HTML/тексту через sed + eval
	s("eval_sed", {
		t('eval $("'), i(1, 'sed -n "s/<code>\\(.*\\)<\\/code>/\\1/p"'), t('" "'), i(2, "file.htm"), t('")'),
	}),

	-- 🔹 2. Масиви в Bash (з акцентом на ${} синтаксис)
	s("barray", {
		t('declare -a '), i(1, "arr"), t('=("'), i(2, "val1"), t('" "'), i(3, "val2"), t('")'),
		t({ '', '# ⚠️ У Bash для індексів ОБОВ\'ЯЗКОВО використовуйте ${}' }),
		t({ '', 'echo "${', rep(1), '[', i(4, "0"), ']}"  # Правильно' }),
		t({ '', 'echo $', rep(1), '[', rep(4), ']      # Неправильно (виведе тільки перший елемент)' }),
	}),


-- 🔹 ЄДИНИЙ ОБ'ЄДНАНИЙ СНІППЕТ: SSH Backup + Return/Exit
s("bssh", {
  -- 📜 Shebang та налаштування
  t({ "#!/usr/bin/env bash", "set -euo pipefail", "", "# 📦 Змінні бекапу" }),
  t({ "", 'USER="' }), i(1, "backup"), t('"'),
  t({ "", 'HOST="' }), i(2, "192.168.1.100"), t('"'),
  t({ "", 'SRC="' }), i(3, "/data"), t('"'),
  t({ "", 'DST="' }), i(4, "/remote/backup"), t({ '"', "", "" }),

  -- 🔍 Перевірка з'єднання
  t({ "# 🔍 Перевірка SSH-з'єднання", "" }),
  t({ 'if ! ssh -o ConnectTimeout=10 "${USER}@${HOST}" exit 2>/dev/null; then' }),
  t({ '  echo "❌ Не вдалося підключитися до ${HOST}" >&2' }),
  t({ "  exit 1", "fi", "", "# 📤 Виконання бекапу" }),

  -- 📦 Команда бекапу
  t({ 'tar -czf - "$SRC" 2>/dev/null | \\' }),
  t({ '  ssh "${USER}@${HOST}" "cat > \'${DST}/backup_$(date +%Y%m%d).tar.gz\'" && \\' }),
  t({ '  echo "✅ Бекап успішно створено" || \\' }),
  t({ '  echo "❌ Помилка під час бекапу" >&2', "", "# 🔚 Завершення" }),

  -- 🎛️ Вибір: exit (для скрипта) або return (для функції)
  c(5, { t("exit $?"), t("return $?") }),
}),

-- ========================================================================
-- 🔹 BACKUP WITH ROTATION (keep last N backups)
-- ========================================================================
 s("bkprot", {
  t("src=\""), i(1, "/path/to/data"), t("\"\n"),
  t("dest=\""), i(2, "/backup"), t("\"\n"),
  t("prefix=\""), i(3, "myapp"), t("\"\n"),
  t("keep=\""), i(4, "7"), t("\"  # кількість збережених бекапів\n\n"),
  t("timestamp=$(date '+%Y%m%d_%H%M%S')\n"),
  t("backup_file=\"${dest}/${prefix}_${timestamp}.tar.gz\"\n\n"),
  t("# Створення архіву\n"),
  t("tar -czf \"$backup_file\" -C \"$(dirname \"$src\")\" \"$(basename \"$src\")\"\n\n"),
  t("# Ротація: видалення старих бекапів (> $keep)\n"),
  t("ls -t ${dest}/${prefix}_*.tar.gz | tail -n +$((keep + 1)) | xargs -r rm -v"),
}),

-- ========================================================================
-- 🔹 ADVANCED: RSYNC WITH EXCLUDE & DRY-RUN
-- ========================================================================
 s("rsyncadv", {
  t("# Rsync з виключеннями та тестовим запуском (--dry-run)\n"),
  t("rsync -av --dry-run \\\n"),
  t("  --exclude='*.tmp' \\\n"),
  t("  --exclude='.git/' \\\n"),
  t("  --exclude='node_modules/' \\\n"),
  t("  "), i(1, "/source/path/"), t(" \\\n"),
  t("  "), i(2, "user@remote:/dest/path/"),
}),

-- ========================================================================
-- 🔹 TAR+SSH REMOTE BACKUP PIPELINE (ВИПРАВЛЕНО)
-- ========================================================================
s("tarssh", {
  t("username=\""), i(1, "user1"),       t("\"\n"),
  t("server=\""),   i(2, "192.168.1.5"), t("\"\n"),
  t("remote_path=\""), i(3, "/backup"),  t("\"\n\n"),
  t("# Створення tar-архіву та відправка на віддалений сервер\n"),
  t("tar cvf - "), i(4, "myapp/log"), t(" | ssh $"),
  rep(1), t("@$"), rep(2), t(" \"cat > $"),
  rep(3), t("/myapplog.tar\""),
}),

-- ========================================================================
-- 🔹 RSYNC LOGS TO BACKUP DIR
-- ========================================================================
s("rsynclog", {
  t("log_dir=\""), i(1, "/home/user1/myapp/log"), t("\"\n"),
  t("backup_dir=\""), i(2, "/backup/myapp"), t("\"\n\n"),
  t("# Копіювання логів з rsync (зберігає права, час, symlink)\n"),
  t("rsync -av \"$log_dir\" \"$backup_dir\""),
}),

-- ========================================================================
-- 🔹 BACKUP CONFIG FILE WITH TIMESTAMP
-- ========================================================================
s("bconf", {
  t("config='"), i(1, "myapp.conf"), t("'\n"),
  t("back_filename=\"${config}.$(date '+%Y%m%d')\"\n\n"),
  t("# Якщо файл з такою датою вже існує — додаємо час до секунд\n"),
  t("if [ -e $back_filename ]; then\n"),
  t("  back_filename=\"${config}.$(date '+%Y%m%d%H%M.%S')\"\n"),
  t("fi\n\n"),
  t("cp -v \"$config\" \"$back_filename\""),
}),

s("sqlq", {
  t('query := `SELECT '), i(1, "id, name"), t(' FROM '),
  i(2, "users"), t(' WHERE '), i(3, "id = ?"), t('`'),
  t({ '', '' }),
  t('rows, err := db.QueryContext(ctx, query, '), i(4, "id"), t(')'),
  t({ '', 'if err != nil { return err }' }),
  t({ '', 'defer rows.Close()' }),
}),

s("sqlq", {
  t('query := `SELECT '), i(1, "id, name"), t(' FROM '),
  i(2, "users"), t(' WHERE '), i(3, "id = ?"), t('`'),
  t({ '', '' }),
  t('rows, err := db.QueryContext(ctx, query, '), i(4, "id"), t(')'),
  t({ '', 'if err != nil { return err }' }),
  t({ '', 'defer rows.Close()' }),
}),

  s("blog", fmt([[
log() {{
  local level=$1; shift
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${{level}}] $*" >&2
}}

log_info() {{ log "INFO" "$@"; }}
log_warn() {{ log "WARN" "$@"; }}
log_error() {{ log "ERROR" "$@"; }}

{}
]], {
    i(1, "# your code with log_info/log_warn/log_error")
  }), {
    descr = "Bash: logging functions",
    docstring = [[
      Додає функції логування з таймстампами.
      log_info, log_warn, log_error — вивід у stderr.
    ]]
  }),

  --  List files with full path 
s("bpathls", fmt([[
shopt -s nullglob
for file in {1}/{2}; do
  [ -e "$file" ] || continue
  printf '%%s/%%s\n' "$(pwd)" "${{file#./}}"
done
]], {
  i(1, "."),      -- directory (default: current)
  i(2, "*"),      -- glob pattern
})),

s("sqlq", {
  t('query := `SELECT '), i(1, "id, name"), t(' FROM '),
  i(2, "users"), t(' WHERE '), i(3, "id = ?"), t('`'),
  t({ '', '' }),
  t('rows, err := db.QueryContext(ctx, query, '), i(4, "id"), t(')'),
  t({ '', 'if err != nil { return err }' }),
  t({ '', 'defer rows.Close()' }),
}),

-- 🔹 Bulk rename with pattern — ВИПРАВЛЕНО
s("brename", fmt([[
for file in *{1}*; do
  mv -v "$file" "${{file//{2}/{3}}}"
done
]], {
  i(1, "old"),   -- шаблон пошуку (*old*)
  i(2, "old"),   -- що замінити у імені
  i(3, "new"),   -- на що замінити
})),



 s("blog", fmt([[
log() {{
  local level=$1; shift
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${{level}}] $*" >&2
}}

log_info() {{ log "INFO" "$@"; }}
log_warn() {{ log "WARN" "$@"; }}
log_error() {{ log "ERROR" "$@"; }}

{}
]], {
    i(1, "# your code with log_info/log_warn/log_error")
  }), {
    descr = "Bash: logging functions",
    docstring = [[
      Додає функції логування з таймстампами.
      log_info, log_warn, log_error — вивід у stderr.
    ]]
  }),

  	-- ⏱ Вимірювання часу виконання
s("btime", {
		t('#!/bin/bash'), t({ "", "" }),
		t('start=$(date +%s)'), t({ "", "" }),
		i(1, "# your command here"), t({ "", "" }),
		t('stop=$(date +%s)'), t({ "", "" }),
		t('total_time=$((stop - start))'), t({ "", "" }),
		t('echo "⏱️  Execution time: ${total_time}s"'),
	}),


-- 🔹 4. cut: витяг поля — ВИПРАВЛЕНО
s("cmd_cut", fmt([[
echo "${{{1}}}" | cut -d "{2}" -f {3}
]], {
  i(1, "text"),
  i(2, " "),
  i(3, "1"),
})),


-- 🔹 3. Об'єднання рядків — ВИПРАВЛЕНО (без `fmt()` для `choice_node`)
s("strcat", c(1, {
  -- Варіант 1: простий
  { t('echo "${'), i(1, "var1"), t('}, $'), i(2, "var2"), t('!"') },
  -- Варіант 2: конкатенація
  { t('echo "${'), i(1, "var1"), t('}${'), i(2, ", "), t('}${'), i(3, "var2"), t('}!"') },
  -- Варіант 3: через змінну
  {
    t('str="${'), i(1, "var1"), t('}"; str+="'), i(2, ", "),
    t('"; str+="'), i(3, "var2"), t('!"; echo "$str"'),
  },
})),

-- 🔹 5. tr: заміна / регістр / видалення — ВИПРАВЛЕНО
s("cmd_tr", c(1, {
  -- Варіант 1: заміна символів
  fmt('echo "{1}" | tr "{2}" "{3}"', {
    i(1, "text"),
    i(2, "el"),
    i(3, "x"),
  }),
  -- Варіант 2: регістр
  fmt('echo "{1}" | tr "[:lower:]" "[:upper:]"', {
    i(1, "text"),
  }),
  -- Варіант 3: видалення символів
  fmt('echo "{1}" | tr -d "{2}"', {
    i(1, "text"),
    i(2, "el"),
  }),
})),

-- 🔹 6. sed: заміна та Regex — ВИПРАВЛЕНО
s("cmd_sed", c(1, {
  -- Варіант 1: проста заміна
  fmt('echo "{1}" | sed "s/{2}/{3}/"', {
    i(1, "text"),
    i(2, "find"),
    i(3, "replace"),
  }),
  -- Варіант 2: Regex з -E
  fmt('echo "{1}" | sed -E "s/{2}/{3}/g"', {
    i(1, "text"),
    i(2, "regex_pattern"),
    i(3, "replacement"),
  }),
})),

s("argchk", fmt([[
if [ "{1}" == "{2}" ]; then
  {3}
fi
]], {
  i(1, "$1"),
  i(2, "value"),
  i(3, [[echo "First arg is 'hi'!"]]),
})),

s("bftp", fmt([[
#!/bin/sh
set -euo pipefail

FILE_NAME="{1}"
HOST='{2}'
USER='{3}'
PASSWD='{4}'

if ! ftp -nv <<EOF
open $HOST
user $USER $PASSWD
cd {5}
put $FILE_NAME
bye
EOF
then
  echo "❌ FTP upload failed" >&2
  exit 1
fi
]], {
  i(1, "path/to/file"),
  i(2, "ftp.example.com"),
  i(3, "username"),
  i(4, "password"),
  i(5, "remote/directory"),
})),

-- 🔹 1. Безпечний запуск скрипта + код повернення + пауза — ВИПРАВЛЕНО
s("runexec", fmt([[
scriptname="{1}"
returncode=0

if [ ${{#}} -ge 1 ] ; then
  if [ -x "$scriptname" ] ; then
    "${{@}}"
  else
    $SHELL "${{@}}"
  fi
  returncode=$?
  [ $returncode -ne 0 ] && printf "'${{@}}' returned ${{returncode}}\n"
else
  printf "\n!! ${{0}} : no argument(s) !!\n"
fi

read -p "... press return key ... " dummy
exit $returncode
]], {
  i(1, "myscript.sh"),  -- поле для імені скрипта
})),

  -- 🔹 1. Простий калькулятор (два числа)
  s("bcalc2", {
    t("echo -n 'Enter the First Number: '"), t({ "", "" }),
    t("read -r "), i(1, "a"), t({ "", "" }),
    t("echo -n 'Enter the Second Number: '"), t({ "", "" }),
    t("read -r "), i(2, "b"), t({ "", "" }),
    t('echo "$'), rep(1), t(' + $'), rep(2), t(' = $(( '), rep(1), t(' + '), rep(2), t(' ))"'),
  }),

  -- 🔹 2. Loading spinner animation
  s("bspinner", {
    t("arr=('−' '\\' '|' '/')"), t({ "", "" }),
    t("while true; do"), t({ "", "\t" }),
    t("for c in \"${arr[@]}\"; do"), t({ "", "\t\t" }),
    t('echo -en "\\r $c "'), t({ "", "\t\t" }),
    t("sleep .5"), t({ "", "\t" }),
    t("done"), t({ "", "done" }),
  }),

  -- 🔹 3. Tar + GPG backup script
  s("btargpg", {
    t("name="), i(1, "backup_name"), t({ "", "" }),
    t("path="), i(2, "/path/to/data"), t({ "", "" }),
    t('tar -czvf "$name.tar.gz" "$path"'), t({ "", "" }),
    t('gpg -c "$name.tar.gz"'), t({ "", "" }),
    t('rm -f "$name.tar.gz"'), t({ "", "" }),
    t('echo "✅ Encrypted backup: $name.tar.gz.gpg"'),
  }),

  -- 🔹 4. Armstrong number checker
  s("barmstrong", {
    t("echo -n 'Enter A Number: '"), t({ "", "" }),
    t("read -r "), i(1, "n"), t({ "", "" }),
    t("arm=0"), t({ "", "" }),
    t("temp=$"), rep(1), t({ "", "" }),
    t("while [ \"$"), rep(1), t('" -ne 0 ]; do'), t({ "", "\t" }),
    t("r=$(( "), rep(1), t(" % 10 ))"), t({ "", "\t" }),
    t("arm=$(( arm + r * r * r ))"), t({ "", "\t" }),
    t(rep(1), t(" = $(( "), rep(1), t(" / 10 ))")), t({ "", "done" }),
    t("echo $arm"), t({ "", "" }),
    t("if [ $arm -eq \"$temp\" ]; then"), t({ "", "\t" }),
    t('echo "✓ Armstrong"'), t({ "", "else" }), t({ "", "\t" }),
    t('echo "✗ Not Armstrong"'), t({ "", "fi" }),
  }),

  -- 🔹 5. Binary to Decimal converter
  s("bbin2dec", {
    t("echo -n 'Enter a binary number: '"), t({ "", "" }),
    t("read -r "), i(1, "binary"), t({ "", "" }),
    t("if [ \"$"), rep(1), t('" -eq 0 ]; then'), t({ "", "\t" }),
    t('echo "⚠️ Enter a valid number"'), t({ "", "\t" }),
    t("return"), t({ "", "else" }), t({ "", "\t" }),
    t("decimal=0"), t({ "", "\t" }),
    t("power=1"), t({ "", "\t" }),
    t("temp=$"), rep(1), t({ "", "\t" }),
    t("while [ \"$temp\" -ne 0 ]; do"), t({ "", "\t\t" }),
    t("rem=$(( temp % 10 ))"), t({ "", "\t\t" }),
    t("decimal=$(( decimal + (rem * power) ))"), t({ "", "\t\t" }),
    t("power=$(( power * 2 ))"), t({ "", "\t\t" }),
    t("temp=$(( temp / 10 ))"), t({ "", "\t" }),
    t("done"), t({ "", "\t" }),
    t('echo "✅ Decimal: $decimal"'), t({ "", "fi" }),
  }),

  -- 🔹 6. Menu-based calculator with bc
  s("bcalc_menu", {
    t("echo 'Enter two numbers:'"), t({ "", "" }),
    t("read "), i(1, "a"), t({ "", "" }),
    t("read "), i(2, "b"), t({ "", "" }),
    t({ "", 'echo "Enter your choice:"' }),
    t({ "", 'echo "1. Addition"' }),
    t({ "", 'echo "2. Subtraction"' }),
    t({ "", 'echo "3. Multiplication"' }),
    t({ "", 'echo "4. Division"' }),
    t("read "), i(3, "ch"), t({ "", "" }),
    t("case $"), rep(3), t(" in"), t({ "", "\t" }),
    t("1) res=$(echo \"$"), rep(1), t(" + $"), rep(2), t('" | bc) ;;'), t({ "", "\t" }),
    t("2) res=$(echo \"$"), rep(1), t(" - $"), rep(2), t('" | bc) ;;'), t({ "", "\t" }),
    t('3) res=$(echo "$'), rep(1), t(' * $'), rep(2), t('" | bc) ;;'), t({ "", "\t" }),
    t('4) res=$(echo "scale=2; $'), rep(1), t(' / $'), rep(2), t('" | bc) ;;'), t({ "", "esac" }),
    t({ "", "" }),
    t('echo "✅ Result: $res"'),
  }),


    -- 🔹 1. Network Info Collector Script (повний шаблон)
  s("bnetinfo", {
    t({ "#!/bin/bash", "" }),
    t("IP4FW=/sbin/iptables"), t({ "", "" }),
    t("IP6FW=/sbin/ip6tables"), t({ "", "" }),
    t("LSPCI=/usr/bin/lspci"), t({ "", "" }),
    t("ROUTE=/sbin/route"), t({ "", "" }),
    t("NETSTAT=/bin/netstat"), t({ "", "" }),
    t("LSB=/usr/bin/lsb_release"), t({ "", "" }),
    t({ "", "## files ##" }),
    t('DNSCLIENT="/etc/resolv.conf"'), t({ "", "" }),
    t('DRVCONF="/etc/modprobe.conf"'), t({ "", "" }),
    t('NETCFC="/etc/sysconfig/network-scripts/ifcfg-eth?"'), t({ "", "" }),
    t('SYSCTL="/etc/sysctl.conf"'), t({ "", "" }),
    t({ "", '## Output file ##' }),
    t('OUTPUT="network.$(date +\'%d-%m-%y\').info.txt"'), t({ "", "" }),
    t('SUPPORT_ID="'), i(1, "admin@example.com"), t('"'), t({ "", "" }),
    t({ "chk_root() {", "\tlocal meid=$(id -u)", "\tif [ $meid -ne 0 ]; then", "\t\techo \"You must be root user to run this tool\"", "\t\texit 999", "\tfi", "}", "" }),
    t({ "write_header() {", '\techo "---------------------------------------------------" >>$OUTPUT', '\techo "$@" >>$OUTPUT', '\techo "---------------------------------------------------" >>$OUTPUT', "}", "" }),
    t({ "dump_info() {", '\techo "* Hostname: $(hostname)" >$OUTPUT', '\techo "* Run date and time: $(date)" >>$OUTPUT', "" }),
    t({ '\twrite_header "Linux Distro"', '\techo "Linux kernel: $(uname -mrs)" >>$OUTPUT', '\t$LSB -a >>$OUTPUT', "" }),
    t({ '\twrite_header "PCI Devices"', '\t${LSPCI} -v >>$OUTPUT', "" }),
    t({ '\twrite_header "Kernel Routing Table"', '\t$ROUTE -n >>$OUTPUT', "" }),
    t({ '\twrite_header "DNS Client $DNSCLIENT Configuration"', '\t[ -f $DNSCLIENT ] && cat $DNSCLIENT >>$OUTPUT || echo "Error $DNSCLIENT file not found." >>$OUTPUT', "" }),
    t({ '\twrite_header "Network Configuration File"', "\tfor f in $NETCFC; do", '\t\tif [ -f $f ]; then', '\t\t\techo "** $f **" >>$OUTPUT', '\t\t\tcat $f >>$OUTPUT', '\t\telse', '\t\t\techo "Error $f not found." >>$OUTPUT', '\t\tfi', '\tdone', "" }),
    t({ '\twrite_header "IP4 Firewall Configuration"', '\t$IP4FW -L -n >>$OUTPUT', "" }),
    t({ '\twrite_header "IP6 Firewall Configuration"', '\t$IP6FW -L -n >>$OUTPUT', "" }),
    t({ '\twrite_header "Network Stats"', '\t$NETSTAT -s >>$OUTPUT', "" }),
    t({ '\techo "The Network Configuration Info Written To $OUTPUT. Please email this file to $SUPPORT_ID."', "}", "" }),
    t({ "chk_root", "dump_info" }),
  }),

  -- 🔹 2. File Case Converter (uppercase → lowercase)
  s("bcaseconv", {
    t({ "#!/bin/bash", "" }),
    t('echo -n "Enter File Name: "'), t({ "", "" }),
    t("read -r "), i(1, "file"), t({ "", "" }),
    t({ 'if [ ! -f "$', rep(1), '" ]; then', '\techo "Filename $', rep(1), ' does not exists"', "\texit 1", "fi", "" }),
    t("tr '[:upper:]' '[:lower:]' < \"$"), rep(1), t('" >> '), i(2, "small.txt"),
  }),

  -- 🔹 3. CPU Usage Monitor with Email Alert
  s("bcpumonitor", {
    t({ "#!/bin/bash", "" }),
    t("MAX="), i(1, "95"), t({ "", "" }),
    t("EMAIL="), i(2, "admin@example.com"), t({ "", "" }),
    t({ "", "USE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage \"\"}')", "" }),
    t({ 'if [ $USE -gt $MAX ]; then', '\techo "Percent used: $USE" | mail -s "Running out of CPU power" $EMAIL', 'fi' }),
  }),

  -- 🔹 4. Decimal to Hex Converter
  s("bdec2hex", {
    t({ "#!/bin/bash", "" }),
    t('printf "0x%x\\n" "$'), i(1, "1"), t('"'),
  }),

  -- 🔹 5. Generic File Check Template
  s("bfilecheck", {
    t({ "#!/bin/bash", "" }),
    t('if [ ! -f "$'), i(1, "filename"), t('" ]; then', '\techo "Error: $'), rep(1), t(' not found" >&2', '\texit 1', 'fi'),
  }),

  -- 🔹 6. Generic Function with Root Check
  s("bfuncroot", {
    t({ "#!/bin/bash", "" }),
    t({ "chk_root() {", "\tlocal meid=$(id -u)", "\tif [ $meid -ne 0 ]; then", '\t\techo "You must be root to run this script" >&2', "\t\texit 999", "\tfi", "}", "" }),
    t("chk_root"), t({ "", "" }),
    i(0, "# your code here"),
  }),

  -- 🔹 1. Decimal to Binary Converter
  s("bdec2bin", {
    t({ "#!/bin/bash", "" }),
    t("for ((i = 32; i >= 0; i--)); do"), t({ "", "\t" }),
    t("r=$((2 ** i))"), t({ "", "\t" }),
    t("Probablity+=($r)"), t({ "", "done", "" }),
    t({ '[[ $# -eq 0 ]] && {', '\techo -e "Usage \\n \\t $0 numbers"', '\texit 1', '}', "" }),
    t({ 'echo -en "Decimal\\t\\tBinary\\n"', 'for input_int; do', '\ts=0', '\ttest ${#input_int} -gt 11 && {',
        '\t\techo "Support Upto 10 Digit number :: skiping \\"$input_int\\""', '\t\tcontinue', '\t}', "" }),
    t({ '\tprintf "%-10s\\t" "$input_int"', "" }),
    t({ "\tfor n in ${Probablity[@]}; do", "\t\tif [[ $input_int -lt $n ]]; then",
        "\t\t\t[[ $s == 1 ]] && printf \"%d\" 0", "\t\telse", '\t\t\techo -n 1', '\t\t\ts=1',
        '\t\t\tinput_int=$((input_int - n))', "\t\tfi", "\tdone", "\techo -e", "done" }),
  }),

  -- 🔹 2. Directory Size Checker
  s("bdirsize", {
    t({ "#!/bin/bash", "" }),
    t('echo -n "Enter your directory: "'), t({ "", "" }),
    t("read -r "), i(1, "dir"), t({ "", "" }),
    t('du -sh "$'), rep(1), t('"'),
  }),

  -- 🔹 3. Disk Space Monitor with Email Alert
  s("bdiskmon", {
    t({ "#!/bin/bash", "" }),
    t("MAX="), i(1, "95"), t({ "", "" }),
    t("EMAIL="), i(2, "admin@example.com"), t({ "", "" }),
    t("PART="), i(3, "sda1"), t({ "", "" }),
    t({ "", 'USE=$(df -h | grep $PART | awk \'{ print $5 }\' | cut -d\'%\' -f1)', "" }),
    t({ 'if [ $USE -gt $MAX ]; then', '\techo "Percent used: $USE" | mail -s "Running out of disk space" $EMAIL', 'fi' }),
  }),

  -- 🔹 4. Simple Division Calculator
  s("bdiv", {
    t({ "#!/bin/bash", "" }),
    t('echo -n "Enter the First Number: "'), t({ "", "" }),
    t("read "), i(1, "a"), t({ "", "" }),
    t('echo -n "Enter the Second Number: "'), t({ "", "" }),
    t("read "), i(2, "b"), t({ "", "" }),
    t('echo "$'), rep(1), t(' / $'), rep(2), t(' = $(( '), rep(1), t(' / '), rep(2), t(' ))"'),
  }),

  -- 🔹 5. GPG File Encryptor
  s("bgpgenc", {
    t({ "#!/bin/bash", "" }),
    t({ 'echo "Welcome, I am ready to encrypt a file/folder for you"',
        'echo "currently I have a limitation, Place me to the same folder, where a file to be encrypted is present"',
        'echo "Enter the Exact File Name with extension"' }),
    t({ "", "" }),
    t("read -r "), i(1, "file"), t({ "", "" }),
    t("# 🔓 Decryption command: gpg -d filename.gpg > filename"), t({ "", "" }),
    t('gpg -c "$'), rep(1), t('"'), t({ "", "" }),
    t({ 'echo "I have encrypted the file sucessfully..."',
        'echo "Now I will be removing the original file"',
        'rm -rf "$', rep(1), '"' }),
  }),

  -- 🔹 6. Even/Odd Number Checker
  s("bevenodd", {
    t({ "#!/bin/bash", "" }),
    t('echo -n "Enter The Number: "'), t({ "", "" }),
    t("read -r "), i(1, "n"), t({ "", "" }),
    t("if [ $(( "), rep(1), t(" % 2 )) -eq 0 ]; then"), t({ "", "\t" }),
    t('echo "✓ is a Even Number"'), t({ "", "else" }), t({ "", "\t" }),
    t('echo "✓ is a Odd Number"'), t({ "", "fi" }),
  }),

  -- 🔹 7. Generic Power-of-2 Loop Template
  s("bpowloop", {
    t("for ((i = "), i(1, "32"), t("; i >= "), i(2, "0"), t("; i--)); do"), t({ "", "\t" }),
    t("r=$((2 ** i))"), t({ "", "\t" }),
    i(3, "array"), t("+=( $r )"), t({ "", "done" }),
  }),

  -- 🔹 8. Safe Input Read Template
  s("bread_safe", {
    t('echo -n "'), i(1, "Prompt: "), t('"'), t({ "", "" }),
    t("read -r "), i(2, "var"),
  }),

  -- 🔹 9. Numeric Validation + Action
  s("bnumcheck", {
    t("if [[ "), i(1, "$var"), t(" =~ ^[0-9]+$ ]]; then"), t({ "", "\t" }),
    i(2, "# valid number action"), t({ "", "else" }), t({ "", "\t" }),
    t('echo " Not a number" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi" }),
  }),

  -- 🔹 1. Factorial Calculator
  s("bfact", {
    t({ "#!/bin/bash", "" }),
    t('echo -n "Enter The Number: "'), t({ "", "" }),
    t("read -r "), i(1, "n"), t({ "", "" }),
    t("fact=1"), t({ "", "" }),
    t("while [ \"$"), rep(1), t('" -ne 0 ]; do'), t({ "", "\t" }),
    t("fact=$(( fact * "), rep(1), t(" ))"), t({ "", "\t" }),
    t(rep(1), t(" = $(( "), rep(1), t(" - 1 ))")), t({ "", "done" }),
    t({ "", 'echo "Factorial: $fact"' }),
  }),

  -- 🔹 2. Fibonacci Sequence Generator
  s("bfib", {
    t({ "#!/bin/bash", "" }),
    t("x=0; y=1; i=2"), t({ "", "" }),
    t("echo -n \"Fibonacci: $x $y \""), t({ "", "" }),
    t("while [ $i -lt "), i(1, "10"), t(" ]; do"), t({ "", "\t" }),
    t("z=$(( x + y ))"), t({ "", "\t" }),
    t('echo -n "$z "'), t({ "", "\t" }),
    t("x=$y"), t({ "", "\t" }),
    t("y=$z"), t({ "", "\t" }),
    t("i=$(( i + 1 ))"), t({ "", "done" }),
    t({ "", 'echo ""' }),
  }),

  -- 🔹 3. Temperature Reader (Celsius → Fahrenheit)
  s("btemp", {
    t({ "#!/bin/bash", "" }),
    t('TEMP_FILE="'), i(1, "/sys/class/thermal/thermal_zone0/temp"), t('"'), t({ "", "" }),
    t("ORIGINAL_TEMP=$(cat $TEMP_FILE)"), t({ "", "" }),
    t("TEMP_C=$(( ORIGINAL_TEMP / 1000 ))"), t({ "", "" }),
    t("TEMP_F=$(( TEMP_C * 9 / 5 + 32 ))"), t({ "", "" }),
    t('echo "🌡️  Temperature: $TEMP_C°C / $TEMP_F°F"'),
  }),

  -- 🔹 4. System Info Menu (повний шаблон)
  s("bsysmenu", {
    t({ "#!/bin/bash", "" }),
    t("function menuprincipal() {"), t({ "", "\t" }),
    t("clear"), t({ "", "\t" }),
    t("TIME=1"), t({ "", "\t" }),
    t({ 'echo ""', 'echo "$0"', 'echo ""' }),
    t({ '\techo "Choose an option below!"', '\techo ""' }),
    t({ '\techo "1 - Verify desktop processor"', '\techo "2 - Verify system kernel"' }),
    t({ '\techo "3 - Verify installed softwares"', '\techo "4 - OS version"' }),
    t({ '\techo "5 - Verify desktop memory"', '\techo "6 - Verify serial number"' }),
    t({ '\techo "7 - Verify system IP"', '\techo "0 - Exit"' }),
    t({ '\techo ""', '\techo -n "Chosen option: "' }),
    t({ "", "\t" }), t("read opcao"), t({ "", "\t" }),
    t("case $opcao in"), t({ "", "\t\t" }),
    -- Option 1: CPU
    t({ '1)', '\tfunction processador() {', '\t\tCPU_INFO=$(cat /proc/cpuinfo | grep -i "^model name" | cut -d: -f2 | sed -n 1p)', '\t\techo "CPU model: $CPU_INFO"', '\t\tsleep $TIME', '\t}', '\tprocessador', '\tread -n 1 -p "<Enter> for main menu"', '\tmenuprincipal', '\t;;' }),
    -- Option 2: Kernel
    t({ "", "\t\t", '2)', '\tfunction kernel() {', '\t\tKERNEL_VERSION=$(uname -r)', '\t\tif [ -f /etc/lsb-release ]; then', '\t\t\techo "Kernel (Ubuntu): $KERNEL_VERSION"', '\t\telse', '\t\t\techo "Kernel (CentOS): $KERNEL_VERSION"', '\t\tfi', '\t}', '\tkernel', '\tread -n 1 -p "<Enter> for main menu"', '\tmenuprincipal', '\t;;' }),
    -- Option 3: Software
    t({ "", "\t\t", '3)', '\techo "Listing installed packages..."', '\tdpkg -l 2>/dev/null | grep ^ii | wc -l', '\tread -n 1 -p "<Enter> for main menu"', '\tmenuprincipal', '\t;;' }),
    -- Option 4: OS Version
    t({ "", "\t\t", '4)', '\tif [ -f /etc/os-release ]; then', '\t\tgrep ^PRETTY_NAME /etc/os-release', '\telse', '\t\techo "OS not supported"', '\tfi', '\tread -n 1 -p "<Enter> for main menu"', '\tmenuprincipal', '\t;;' }),
    -- Option 5: Memory
    t({ "", "\t\t", '5)', '\tMEMORY_FREE=$(free -m | grep ^Mem | awk "{print \\$4}")', '\techo "Free memory: ${MEMORY_FREE}MB"', '\tread -n 1 -p "<Enter> for main menu"', '\tmenuprincipal', '\t;;' }),
    -- Option 6: Serial
    t({ "", "\t\t", '6)', '\tSERIAL=$(dmidecode -t 1 2>/dev/null | grep -i "Serial Number" | cut -d: -f2 | xargs)', '\techo "Serial: ${SERIAL:-N/A}"', '\tread -n 1 -p "<Enter> for main menu"', '\tmenuprincipal', '\t;;' }),
    -- Option 7: IP
    t({ "", "\t\t", '7)', '\tIP_ADDR=$(hostname -I | awk "{print \\$1}")', '\techo "IP address: $IP_ADDR"', '\tread -n 1 -p "<Enter> for main menu"', '\tmenuprincipal', '\t;;' }),
    -- Option 0: Exit
    t({ "", "\t\t", '0)', '\techo "Exiting..."', '\tsleep $TIME', '\texit 0', '\t;;' }),
    -- Default
    t({ "", "\t\t", '*)', '\techo "Invalid option, try again!"', '\tsleep $TIME', '\tmenuprincipal', '\t;;' }),
    t({ "", "\t" }), t("esac"), t({ "", "}" }),
    t({ "", "menuprincipal" }),
  }),

  -- 🔹 5. Generic Menu Template (спрощений)
  s("bmenu", {
    t({ "#!/bin/bash", "" }),
    t("function "), i(1, "menu_name"), t("() {"), t({ "", "\t" }),
    t("while true; do"), t({ "", "\t\t" }),
    t('echo "===== Menu ====="'), t({ "", "\t\t" }),
    t('echo "1) '), i(2, "Option 1"), t('"'), t({ "", "\t\t" }),
    t('echo "2) '), i(3, "Option 2"), t('"'), t({ "", "\t\t" }),
    t('echo "0) Exit"'), t({ "", "\t\t" }),
    t('echo -n "Choose: "'), t({ "", "\t\t" }),
    t("read choice"), t({ "", "\t\t" }),
    t("case $choice in"), t({ "", "\t\t\t" }),
    t("1) "), i(4, "# action 1"), t(" ;;"), t({ "", "\t\t\t" }),
    t("2) "), i(5, "# action 2"), t(" ;;"), t({ "", "\t\t\t" }),
    t("0) exit 0 ;;"), t({ "", "\t\t\t" }),
    t("*) echo 'Invalid' ;;"), t({ "", "\t\t" }),
    t("esac"), t({ "", "\t" }),
    t("done"), t({ "", "}" }),
    t({ "", i(1), "" }),
  }),

  -- 🔹 6. Read with Validation Template
  s("bread_val", {
    t('echo -n "'), i(1, "Prompt"), t(': "'), t({ "", "" }),
    t("read -r "), i(2, "var"), t({ "", "" }),
    t("while [[ ! \"$"), rep(2), t('" =~ ^'), i(3, "[0-9]+"), t("$ ]]; do"), t({ "", "\t" }),
    t('echo "❌ Invalid input, try again"'), t({ "", "\t" }),
    t('echo -n "'), rep(1), t(': "'), t({ "", "\t" }),
    t("read -r "), rep(2), t({ "", "done" }),
  }),

    -- 🔹 1. printf decimal
  s("bprintf", {
    t('printf "%d\\n" "$'), i(1, "1"), t('"'),
  }),

  -- 🔹 2. Interactive name prompt
  s("bread_name", {
    t('echo -n "Hey, what\'s your first name? "'), t({ "", "" }),
    t("read "), i(1, "fname"), t({ "", "" }),
    t('echo -n "Welcome Mr./Mrs. $'), rep(1), t(', would you like to tell us your last name? "'), t({ "", "" }),
    t("read "), i(2, "lname"), t({ "", "" }),
    t('echo "Thanks Mr./Mrs. $'), rep(1), t(' $'), rep(2), t(' for telling us your name"'),
    t({ "", 'echo "*******************"', '' }),
    t('echo "Mr./Mrs. $'), rep(2), t(', it\'s time to say goodbye"'),
  }),

  -- 🔹 3. Loop over positional parameters (set -- *)
  s("bfor_set", {
    t("set -- "), i(1, "*"), t({ "", "" }),
    t("for "), i(2, "item"), t("; do"), t({ "", "\t" }),
    t('echo "$'), rep(2), t('"'), t({ "", "done" }),
  }),

  -- 🔹 4. Uppercase to lowercase converter
  s("btr_lower", {
    t('echo -n "Enter String: "'), t({ "", "" }),
    t("read -r "), i(1, "str"), t({ "", "" }),
    t('echo "$'), rep(1), t('" | tr \'[:upper:]\' \'[:lower:]\''),
  }),

  -- 🔹 5. Multiplication calculator
  s("bcalc_mult", {
    t('echo -n "Enter the First Number: "'), t({ "", "" }),
    t("read "), i(1, "a"), t({ "", "" }),
    t('echo -n "Enter the Second Number: "'), t({ "", "" }),
    t("read "), i(2, "b"), t({ "", "" }),
    t('echo "$'), rep(1), t(' * $'), rep(2), t(' = $(( '), rep(1), t(' * '), rep(2), t(' ))"'),
  }),

  -- 🔹 6. Pomodoro Timer (Cross-platform: macOS / Linux)
  s("bpomodoro", {
    t({ '#!/usr/bin/env bash', '', 'WSECONDS=${1:-25}*60', 'PSECONDS=${2:-5}*60', '', 'if [ "$(uname)" == "Darwin" ]; then' }),
    t({ '', '\twhile true; do', '\t\tdate1=$(( $(date +%s) + $WSECONDS ))', '\t\twhile [ "$date1" -ge $(date +%s) ]; do', '\t\t\techo -ne "$(date -u -j -f %s $((date1 - $(date +%s))) +%H:%M:%S)\\r"', '\t\tdone', '\t\tosascript -e \'display notification "Time to walk and rest!" with title "Break"\'', '\t\tread -n1 -rsp $\'Press any key to continue or Ctrl+C to exit...\\n\'', '\t\tdate2=$(( $(date +%s) + $PSECONDS ))', '\t\twhile [ "$date2" -ge $(date +%s) ]; do', '\t\t\techo -ne "$(date -u -j -f %s $((date2 - $(date +%s))) +%H:%M:%S)\\r"', '\t\tdone', '\t\tosascript -e \'display notification "Time to get back to work" with title "Work"\'', '\t\tread -n1 -rsp $\'Press any key to continue or Ctrl+C to exit...\\n\'', '\tdone' }),
    t({ '', 'elif [ "$(uname -s)" == "Linux" ]; then' }),
    t({ '', '\twhile true; do', '\t\tdate1=$(( $(date +%s) + $WSECONDS ))', '\t\twhile [ "$date1" -ge $(date +%s) ]; do', '\t\t\techo -ne "$(date -u --date @$((date1 - $(date +%s))) +%H:%M:%S)\\r"', '\t\tdone', '\t\tnotify-send "Break" "Time to walk and rest"', '\t\tread -n1 -rsp $\'Press any key to continue or Ctrl+C to exit...\\n\'', '\t\tdate2=$(( $(date +%s) + $PSECONDS ))', '\t\twhile [ "$date2" -ge $(date +%s) ]; do', '\t\t\techo -ne "$(date -u --date @$((date2 - $(date +%s))) +%H:%M:%S)\\r"', '\t\tdone', '\t\tnotify-send "Work" "Time to get back to work"', '\t\tread -n1 -rsp $\'Press any key to continue or Ctrl+C to exit...\\n\'', '\tdone' }),
    t({ '', 'else', '\techo "Your OS is currently not supported"', 'fi' }),
  }),

  -- 🔹 1. Prime Number Checker
  s("bprime", {
    t({ "#!/bin/bash", "" }),
    t('echo -n "Enter Any Number: "'), t({ "", "" }),
    t("read -r "), i(1, "n"), t({ "", "" }),
    t("i=1; c=1"), t({ "", "" }),
    t("while [ $i -le \"$"), rep(1), t("\" ]; do"), t({ "", "\t" }),
    t("i=$(( i + 1 ))"), t({ "", "\t" }),
    t("r=$(( "), rep(1), t(" % i ))"), t({ "", "\t" }),
    t("[ $r -eq 0 ] && c=$(( c + 1 ))"), t({ "", "done", "" }),
    t("if [ $c -eq 2 ]; then"), t({ "", "\t" }),
    t('echo "✓ Prime"'), t({ "", "else" }), t({ "", "\t" }),
    t('echo "✗ Not Prime"'), t({ "", "fi" }),
  }),

  -- 🔹 2. Unicode Spinner Animation
  s("bunicode_spin", {
    t({ "#!/bin/bash", "" }),
    t("while true; do"), t({ "", "\t" }),
    t("rand=$(shuf -i "), i(1, "2600"), t("-"), i(2, "2700"), t(" -n 1)"), t({ "", "\t" }),
    t('echo -en "   \\u$rand\\r"'), t({ "", "\t" }),
    t("sleep "), i(3, "0.1"), t({ "", "done" }),
  }),

  -- 🔹 3. Hello + Uptime + Log File
  s("blog_save", {
    t({ "#!/bin/bash", "" }),
    t('echo "Hello $USER"'), t({ "", "" }),
    t('uptime >> "$(date +%Y%m%d_%H%M%S).'), i(1, "log"), t('"'), t({ "", "" }),
    t('echo "✓ File saved to $(pwd)/$(date +%Y%m%d_%H%M%S).'), rep(1), t('"'),
  }),

  -- 🔹 4. Random Number in Range
  s("brandom", {
    t("shuf -i "), i(1, "1"), t("-"), i(2, "100"), t(" -n 1"),
  }),

  -- 🔹 5. Interactive System Info Menu
  s("bsysinfo_menu", {
    t({ "#!/bin/bash", "clear", "" }),
    t({ 'cat << EOF', 'Please Select:', '' }),
    t({ '    1. Display System Information', '    2. Display Disk Space' }),
    t({ '    3. Display Home Space Utilization', '    0. Quit', '' }),
    t("EOF"), t({ "", "" }),
    t("echo -n 'Enter selection [0-3]: '"), t({ "", "" }),
    t("read -r sel"), t({ "", "" }),
    t("case $sel in"), t({ "", "\t" }),
    t("0) echo \"Program terminated.\" ;;"), t({ "", "\t" }),
    t('1) echo "Hostname: $HOSTNAME"; uptime ;;'), t({ "", "\t" }),
    t("2) df -h ;;"), t({ "", "\t" }),
    t("3)"), t({ "", "\t\t" }),
    t("if [ \"$UID\" = 0 ]; then"), t({ "", "\t\t\t" }),
    t('echo "Home Space Utilization (All Users)"'), t({ "", "\t\t\t" }),
    t("du -sh /home/*"), t({ "", "\t\t" }),
    t("else"), t({ "", "\t\t\t" }),
    t('echo "Home Space Utilization ($USER)"'), t({ "", "\t\t\t" }),
    t('du -sh "$HOME"'), t({ "", "\t\t" }),
    t("fi"), t({ "", "\t" }),
    t(";;"), t({ "", "\t" }),
    t("*)"), t({ "", "\t\t" }),
    t('echo "Invalid entry." >&2'), t({ "", "\t\t" }),
    t("exit 1"), t({ "", "esac" }),
  }),

  -- 🔹 6. Rsync Backup + Email Notification
  s("brsync_backup", {
    t("rsync -avz -e \"ssh\" "), i(1, "/path/to/source"), t(" "),
    i(2, "user@backupserver.com"), t(":"), i(3, "/backup/"), t({ "", "" }),
    t('echo "Backup completed: $(date)" | mail -s "✅ Backup Complete" '),
    i(4, "admin@example.com"),
  }),

  -- 🔹 7. Generic While-True Loop Template
  s("bwhile_inf", {
    t("while true; do"), t({ "", "\t" }),
    i(1, "# your code"), t({ "", "\t" }),
    t("sleep "), i(2, "1"), t({ "", "done" }),
  }),

  -- 🔹 8. Safe Read with Prompt
  s("bread_prompt", {
    t('echo -n "'), i(1, "Prompt: "), t(': "'), t({ "", "" }),
    t("read -r "), i(2, "var"),
  }),

  -- 🔹 9. Date-based Filename Template
  s("bdate_file", {
    t('"$(date +%Y%m%d_%H%M%S).'), i(1, "log"), t('"'),
  }),

  -- 🔹 10. Case Statement Template
  s("bcase", {
    t("case $"), i(1, "var"), t(" in"), t({ "", "\t" }),
    i(2, "pattern1"), t(")"), t({ "", "\t\t" }),
    i(3, "# action"), t({ "", "\t" }), t(";;"), t({ "", "\t" }),
    t("*)"), t({ "", "\t\t" }),
    t("# default"), t({ "", "\t" }), t(";;"), t({ "", "esac" }),
  }),

    -- 🔹 7. Case Menu Template (generic)
  s("bcase_menu", {
    t("echo 'Select option:'"), t({ "", 'echo "1) ', i(1, "Option 1"), '"' }),
    t({ '', 'echo "2) ', i(2, "Option 2"), '"' }),
    t({ '', 'read -r choice', '', 'case $choice in', '\t1)', '\t\t', i(3, "# action 1"), '\t\t;;' }),
    t({ '', '\t2)', '\t\t', i(4, "# action 2"), '\t\t;;' }),
    t({ '', '\t*)', '\t\techo "Invalid"', '\t\t;;', 'esac' }),
  }),

-- 🔹 5. Input Validation Template — ВИПРАВЛЕНО
s("bval_range", {
  t('if ! [ $'), i(1, "VAR"), t(' -ge '), i(2, "5"), t(' -a $'), rep(1), t(' -le '), i(3, "9"), t(' ]; then'),
  t({ "", '\techo "❌ Value must be between ' }), rep(2), t(' and '), rep(3), t({ '"', '\texit 1', 'fi' }),
}),

-- 🔹 6. Nested Loop Template — ВИПРАВЛЕНО
s("bnest_loop", {
  t("for (("), i(1, "i"), t(" = 1; "), rep(1), t(" <= "), i(2, "MAX"), t("; "), rep(1), t("++)); do"),
  t({ "", "\t" }),
  t("for (("), i(3, "j"), t(" = 1; "), rep(3), t(" <= "), rep(1), t("; "), rep(3), t("++)); do"),
  t({ "", "\t\t" }),
  t('echo -n "'), i(4, " ."), t('"'),
  t({ "", "\t" }),
  t("done"),
  t({ "", "\t" }),
  t('echo ""'),
  t({ "", "done" }),
}),

  -- 🔹 4. Quick System Info (спрощена версія)
  s("bquickinfo", {
    t({ "#!/bin/bash", "" }),
    t('echo "Date: $(date)"'), t({ "", "" }),
    t('echo "⏱Uptime: $(uptime -p)"'), t({ "", "" }),
    t('echo "Disk: $(df -h / | awk \'NR==2 {print $3" / "$2}\')"'), t({ "", "" }),
    t('echo "Memory: $(free -h | awk \'NR==2 {print $3" / "$2}\')"'), t({ "", "" }),
    t('echo "Connections: $(ss -tun | wc -l)"'), t({ "", "" }),
    t('echo "Top processes:"'), t({ "", "\t" }),
    t('ps aux --sort=-%mem | head -6 | awk \'{print $11}\' | tail -5'),
  }),


    -- 🔹 3. Pyramid Pattern Printer
  s("bpyramid", {
    t({ "#!/bin/bash", "" }),
    t("MAX_NO=0"), t({ "", "" }),
    t('echo -n "Enter Number between (5 to 9) : "'), t({ "", "" }),
    t("read -r MAX_NO"), t({ "", "" }),
    t({ 'if ! [ $MAX_NO -ge 5 -a $MAX_NO -le 9 ]; then', '\techo "WTF... I ask to enter number between 5 and 9, Try Again"', '\texit 1', 'fi', '' }),
    t("clear"), t({ "", "" }),
    t({ 'for ((i = 1; i <= MAX_NO; i++)); do', '\tfor ((s = MAX_NO; s >= i; s--)); do', '\t\techo -n " "', '\tdone' }),
    t({ '\tfor ((j = 1; j <= i; j++)); do', '\t\techo -n " ."', '\tdone', '\techo ""', 'done' }),
    t({ "", "###### Second stage ######################", "" }),
    t({ 'for ((i = MAX_NO; i >= 1; i--)); do', '\tfor ((s = i; s <= MAX_NO; s++)); do', '\t\techo -n " "', '\tdone' }),
    t({ '\tfor ((j = 1; j <= i; j++)); do', '\t\techo -n " ."', '\tdone', '\techo ""', 'done', "" }),
    t({ 'echo -e "\\n\\n\\t\\t\\t Whenever you need help, Tecmint.com is always there"' }),
  }),


   -- 🔹 1. System Monitoring Script (повний шаблон)
  s("bsysmon", {
    t({ "#!/bin/bash", "" }),
    t({ 'date', 'echo "uptime:"', 'uptime', 'echo "Currently connected:"', 'w', 'echo "--------------------"' }),
    t({ 'echo "Last logins:"', 'last -a | head -3', 'echo "--------------------"' }),
    t({ 'echo "Disk and memory usage:"' }),
    t({ 'df -h | xargs | awk \'{print "Free/total disk: " $11 " / " $9}\'', '' }),
    t({ 'free -m | xargs | awk \'{print "Free/total memory: " $17 " / " $8 " MB"}\'' }),
    t({ 'echo "--------------------"' }),
    t({ 'start_log=$(head -1 /var/log/messages | cut -c 1-12)', '' }),
    t({ 'oom=$(grep -ci kill /var/log/messages)', '' }),
    t({ 'echo -n "OOM errors since $start_log : " $oom', 'echo ""', 'echo "--------------------"' }),
    t({ 'echo "Utilization and most expensive processes:"', 'top -b | head -3', 'echo', '' }),
    t({ 'top -b | head -10 | tail -4', 'echo "--------------------"' }),
    t({ 'echo "Open TCP ports:"', 'nmap -p -T4 127.0.0.1', 'echo "--------------------"' }),
    t({ 'echo "Current connections:"', 'ss -s', 'echo "--------------------"' }),
    t({ 'echo "processes:"', 'ps auxf --width=200', 'echo "--------------------"' }),
    t({ 'echo "vmstat:"', 'vmstat 1 5' }),
  }),

    -- 🔹 2. Interactive Calculator with Menu
  s("bcalc_menu", {
    t({ "#!/bin/bash", "clear", "" }),
    t("sum=0"), t({ "", 'i="y"', "" }),
    t({ 'echo "Enter one no."', 'read -r ', i(1, "n1"), '' }),
    t({ 'echo "Enter second no."', 'read -r ', i(2, "n2"), '' }),
    t({ "", 'while [ $i = "y" ]; do', '\techo "1.Addition"', '\techo "2.Subtraction"' }),
    t({ '\techo "3.Multiplication"', '\techo "4.Division"', '\techo "Enter your choice"', '\tread ch' }),
    t({ "", '\tcase $ch in', '\t1)', '\t\tsum=$(expr $', rep(1), t(' + $'), rep(2), t(')') }),
    t({ '', '\t\techo "Sum = $sum"', '\t\t;;' }),
    t({ '\t2)', '\t\tsum=$(expr $', rep(1), t(' - $'), rep(2), t(')') }),
    t({ '', '\t\techo "Sub = $sum"', '\t\t;;' }),
    t({ '\t3)', '\t\tsum=$(expr $', rep(1), t(' \\* $'), rep(2), t(')') }),
    t({ '', '\t\techo "Mul = $sum"', '\t\t;;' }),
    t({ '\t4)', '\t\tsum=$(expr $', rep(1), t(' / $'), rep(2), t(')') }),
    t({ '', '\t\techo "Div = $sum"', '\t\t;;' }),
    t({ '\t*) echo "Invalid choice" ;;', '\tesac', '' }),
    t({ '\techo "Do u want to continue (y/n) ?"', '\tread i', '' }),
    t({ '\tif [ $i != "y" ]; then', '\t\texit', '\tfi', 'done' }),
  }),

  
    -- 🔹 1. Subtraction Calculator
  s("bsub", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('printf "Enter the First Number: "'), t({ "", "" }),
    t("read -r "), i(1, "a"), t({ "", "" }),
    t('printf "Enter the Second Number: "'), t({ "", "" }),
    t("read -r "), i(2, "b"), t({ "", "" }),
    t('echo "$'), rep(1), t(' - $'), rep(2), t(' = $(( $'), rep(1), t(' - $'), rep(2), t(' ))"'),
  }),

  -- 🔹 2. Multiplication Table Generator
  s("btable", {
    t('echo -n "Enter The Number: "'), t({ "", "" }),
    t("read -r "), i(1, "n"), t({ "", "" }),
    t("i=1"), t({ "", "" }),
    t("while [ $i -ne "), i(2, "10"), t(" ]; do"), t({ "", "\t" }),
    t("i=$(( i + 1 ))"), t({ "", "\t" }),
    t("table=$(( i * "), rep(1), t(" ))"), t({ "", "\t" }),
    t('echo "$table"'), t({ "", "done" }),
  }),

  -- 🔹 3. File/Directory Property Checker
  s("bfilecheck2", {
    t('echo -n "Enter File/Directory path: "'), t({ "", "" }),
    t("read -r "), i(1, "path"), t({ "", "" }),
    t('if [ -e "$'), rep(1), t('" ]; then'),
    t({ "", '\tif [ -f "$', rep(1), '" ]; then' }),
    t({ "", '\t\techo "$', rep(1), ' is a regular file."' }),
    t({ "", '\tfi' }),
    t({ "", '\tif [ -d "$', rep(1), '" ]; then' }),
    t({ "", '\t\techo "$', rep(1), ' is a directory."' }),
    t({ "", '\tfi' }),
    t({ "", '\tif [ -r "$', rep(1), '" ]; then' }),
    t({ "", '\t\techo "$', rep(1), ' is readable."' }),
    t({ "", '\tfi' }),
    t({ "", '\tif [ -w "$', rep(1), '" ]; then' }),
    t({ "", '\t\techo "$', rep(1), ' is writable."' }),
    t({ "", '\tfi' }),
    t({ "", '\tif [ -x "$', rep(1), '" ]; then' }),
    t({ "", '\t\techo "$', rep(1), ' is executable/searchable."' }),
    t({ "", '\tfi' }),
    t({ "", 'else' }),
    t({ "", '\techo "$', rep(1), ' does not exist"' }),
    t({ "", '\texit 1' }),
    t({ "", 'fi' }),
    t({ "", 'exit 0' }),
  }),


    s("vardemo", {
    t({ "#!/bin/bash", "" }),
    t("# 🔹 Просте присвоєння"), t({ "", "" }),
    -- ✅ Кожна нода окремо в списку:
    i(1, "PI"), t("="), i(2, "3.14"), t({ "", "" }),
    i(3, "VAR_A"), t("="), i(4, "10"), t({ "", "" }),
    i(5, "VAR_B"), t("=$"), rep(3), t({ "", "" }),
    i(6, "VAR_C"), t("=${"), rep(3), t("}"), t({ "", "" }),
    
    t({ "", 'echo "📋 Lets print 3 variables:"', "" }),
    t('echo "$'), rep(3), t('"'), t({ "", "" }),
    t('echo "$'), rep(5), t('"'), t({ "", "" }),
    t('echo "$'), rep(6), t('"'), t({ "", "" }),
    
    t({ "", "" }),
    t("# ⚠️ Проблема: $VARabc — Bash думає, що це змінна $VARabc"), t({ "", "" }),
    t('echo "❌ The value of PI is $'), rep(1), t('abc"  # Breaks!'), t({ "", "" }),
    
    t({ "", "" }),
    t("# ✅ Рішення 1: ${VAR}abc — чітко відокремлює ім'я змінної"), t({ "", "" }),
    t('echo "✅ 1. The value of PI is ${'), rep(1), t('}abc"'), t({ "", "" }),
    
    t({ "", "" }),
    t("# ✅ Рішення 2: $VAR abc — пробіл також відокремлює"), t({ "", "" }),
    t('echo "✅ 2. The value of PI is" $'), rep(1), t({ "", "" }),
    
    t({ "", "" }),
    t("# ✅ Рішення 3: \"${VAR}abc\" — у лапках найнадійніше"), t({ "", "" }),
    t('echo "✅ 3. The value of PI is ${'), rep(1), t('}abc"'), t({ "", "" }),
    
    t({ "", "" }),
    t("# 🔹 Конкатенація рядків"), t({ "", "" }),
    t('STR_A="'), i(7, "Bob"), t('"'), t({ "", "" }),
    t('STR_B="'), i(8, "Jane"), t('"'), t({ "", "" }),
    t('echo "${'), rep(7), t('} + ${'), rep(8), t('} equals Bob + Jane"'), t({ "", "" }),
    t('STR_C=${'), rep(7), t('}+" + "+${'), rep(8), t('}'), t({ "", "" }),
    
    -- ✅ rep() приймає ТІЛЬКИ індекс. Замінив rep(9, "STR_C") на i(9, "STR_C")
    t('echo "${'), i(9, "STR_C"), t('} is the same as Bob + Jane too!"'), t({ "", "" }),
    t('echo "${'), rep(9), t('} + ${'), rep(1), t('}"'), t({ "", "" }),
    
    t({ "", "exit 0" }),
  }),

  -- 🔹 1. Простий if
  s("if", {
    i(1, "AGE"), t("="), i(2, "17"), t({ "", "" }),
    t("if [ $"), rep(1), t(" -lt "), i(3, "18"), t(" ]; then"), t({ "", "\t" }),
    t('echo "'), i(4, "You must be 18 or older"), t('"'), t({ "", "fi" }),
  }),

  -- 🔹 2. if-else
  s("if_else", {
    i(1, "AGE"), t("="), i(2, "9000"), t({ "", "" }),
    t("if [ $"), rep(1), t(" -lt "), i(3, "18"), t(" ]; then"), t({ "", "\t" }),
    t('echo "'), i(4, "You must be 18 or older"), t('"'), t({ "", "else" }), t({ "", "\t" }),
    t('echo "'), i(5, "You may see the movie!"), t('"'), t({ "", "\t" }),
    t("exit "), i(6, "1"), t({ "", "fi", "" }),
    t('echo "'), i(7, "This line will never get executed"), t('"'),
  }),

  s("if_elif", {
  i(1, "AGE"), t("="), i(2, "21"), t({ "", "" }),
  t("if [ $"), rep(1), t(" -lt "), i(3, "18"), t(" ]; then"), t({ "", "\t" }),
  t('echo "'), i(4, "You must be 18 or older"), t('"'),
  t({ "", "elif [ $" }), rep(1), t(" -eq "), i(5, "21"), t(" ]; then"), t({ "", "\t" }),
  t('echo "'), i(6, "You may see the movie and get popcorn"), t('"'),
  t({ "", "else" }), t({ "", "\t" }),
  t('echo "'), i(7, "You may see the movie!"), t('"'),
  t({ "", "\t" }), t("exit "), i(8, "1"), t({ "", "fi", "" }),
  t('echo "'), i(9, "This line might not get executed"), t('"'),
}),

  -- 🔹 1. String comparisons with && / ||
  s("if_str_logic", {
    t('MY_NAME="'), i(1, "John"), t({ '"', "" }),
    t('NAME_1="'), i(2, "Bob"), t({ '"', "" }),
    t('NAME_2="'), i(3, "Jane"), t({ '"', "" }),
    t('NAME_3="'), i(4, "Sue"), t({ '"', "" }),
    t('Name_4="'), i(5, "Kate"), t({ '"', "", "" }),
    -- ✅ Fixed: Changed [ ] to [[ ]] for proper && / || support in Bash
    t('if [[ "${'), rep(1), t('" == "Ron" ]]; then'), t({ "", "\t" }),
    t('echo "Ron is home from vacation"'),
    t({ "", 'elif [[ "${', rep(1) }), t('" != "${'), rep(2), t('" && "${'), rep(1), t('" != "${'), rep(3), t('" && "${'), rep(1), t('" == "John" ]]; then'), t({ "", "\t" }),
    t('echo "John is home after some unnecessary AND logic"'),
    t({ "", 'elif [[ "${', rep(1) }), t('" == "${'), rep(4), t('" || "${'), rep(1), t('" == "${'), rep(5), t('" ]]; then'), t({ "", "\t" }),
    t('echo "Looks like one of the ladies are home"'),
    t({ "", "else" }), t({ "", "\t" }),
    t('echo "Who is this stranger?"'),
    t({ "", "fi" }),
  }),

  -- 🔹 2. Nested if statements
  s("if_nested", {
    t('USER_AGE='), i(1, "18"), t({ "", "" }),
    t('AGE_LIMIT='), i(2, "18"), t({ "", "" }),
    t('NAME="'), i(3, "Bob"), t({ '"', "" }),
    t('HAS_NIGHTMARES="'), i(4, "true"), t({ '"', "", "" }),
    t('if [[ "${USER}" == "${'), rep(3), t('" ]]; then'), t({ "", "\t" }),
    t('if [[ ${'), rep(1), t(' -ge ${'), rep(2), t(' ]]; then'), t({ "", "\t\t" }),
    t('if [[ "${'), rep(4), t('" == "true" ]]; then'), t({ "", "\t\t\t" }),
    t('echo "${USER} gets nightmares, and should not see the movie"'),
    t({ "", "\t\t" }), t("fi"),
    t({ "", "\t" }), t("fi"),
    t({ "", "else" }), t({ "", "\t" }),
    t('echo "Who is this?"'),
    t({ "", "fi" }),
  }),

  -- 🔹 3. Numeric if-elif-else chain
  s("if_chain_num", {
    i(1, "VAR"), t("="), i(2, "10"), t({ "", "" }),
    t("if [ $"), rep(1), t(" -eq "), i(3, "1"), t(" ]; then"), t({ "", "\t" }),
    t('echo "$'), rep(1), t('"'),
    t({ "", "elif [ $" }), rep(1), t(" -eq "), i(4, "2"), t(" ]; then"), t({ "", "\t" }),
    t('echo "$'), rep(1), t('"'),
    t({ "", "elif [ $" }), rep(1), t(" -eq "), i(5, "3"), t(" ]; then"), t({ "", "\t" }),
    t('echo "$'), rep(1), t('"'),
    t({ "", "else" }), t({ "", "\t" }),
    t('echo "'), i(6, "I am not looking to match this value"), t('"'),
    t({ "", "fi" }),
  }),

  -- 🔹 4. Case statement
  s("case", {
    t("case $"), i(1, "VAR"), t(" in"), t({ "", "\t" }),
    i(2, "1"), t(")"), t({ "", "\t\t" }),
    t('echo "'), rep(2), t('"'), t({ "", "\t\t;;" }),
    t({ "", "\t" }), i(3, "2"), t(")"), t({ "", "\t\t" }),
    t('echo "'), rep(3), t('"'), t({ "", "\t\t;;" }),
    t({ "", "\t" }), t("*)"), t({ "", "\t\t" }),
    t('echo "'), i(4, "What is this var?"), t('"'), t({ "", "\t\t" }),
    t("exit "), i(5, "1"), t({ "", "\t\t;;" }),
    t({ "", "esac" }),
  }),

    -- 🔹 1. For loop over array
  s("for_arr", {
    i(1, "FILES"), t('=( "'), i(2, "file1"), t('" "'), i(3, "file2"), t('" "'), i(4, "file3"), t('" )'), t({ "", "" }),
    t('for ELEMENT in "${'), rep(1), t("[@]}\""),
    t({ "", "do", "\t" }),
    t('echo "${ELEMENT}"'),
    t({ "", "done", "" }),
    t("echo \"Echo'd all the files\""),
  }),

  -- 🔹 2. While loop with counter
  s("while_ctr", {
    i(1, "CTR"), t("="), i(2, "1"), t({ "", "" }),
    t("while [ $"), rep(1), t(" -lt "), i(3, "9"), t(" ]"),
    t({ "", "do", "\t" }),
    t('echo "CTR var: $'), rep(1), t('"'),
    t({ "", "\t((" }), rep(1), t("++)) # Increment by 1"),
    t({ "", "done", "" }),
    t('echo "Finished"'),
  }),

  -- 🔹 3. Until loop with counter
  s("until_ctr", {
    i(1, "CTR"), t("="), i(2, "1"), t({ "", "" }),
    t("until [ $"), rep(1), t(" -gt "), i(3, "9"), t(" ]"),
    t({ "", "do", "\t" }),
    t('echo "CTR var: $'), rep(1), t('"'),
    t({ "", "\t((" }), rep(1), t("++)) # Increment by 1"),
    t({ "", "done", "" }),
    t('echo "Finished"'),
  }),

  -- 🔹 4. For loop + Function for file creation
  s("for_func", {
    i(1, "FILES"), t('=( "'), i(2, "file1"), t('" "'), i(3, "file2"), t('" "'), i(4, "file3"), t('" )'), t({ "", "" }),
    t("function "), i(5, "create_file"), t("() {"),
    t({ "", "\tlocal FNAME=\"${1}\"" }),
    t({ "", "\tlocal PERMISSIONS=\"${2}\"" }),
    t({ "", "\ttouch \"${FNAME}\"" }),
    t({ "", "\tchmod \"${PERMISSIONS}\" \"${FNAME}\"" }),
    t({ "", "\tls -l \"${FNAME}\"" }),
    t({ "", "}", "" }),
    t('for ELEMENT in "${'), rep(1), t("[@]}\""),
    t({ "", "do", "\t" }),
    rep(5), t(' "${ELEMENT}" "'), i(6, "a+x"), t('"'),
    t({ "", "done", "" }),
    t('echo "Created all the files with a function!"'),
    t({ "", "exit 0" }),
  }),

    -- 🔹 1. Source library + create/delete functions
  s("bsource_lib", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("source "), i(1, "library.sh"), t({ "", "" }),
    t('FNAME="'), i(2, "my_test_file.txt"), t({ '"', "" }),
    t('create_file "${FNAME}"'), t({ "", "" }),
    t('delete_file "${FNAME}"'), t({ "", "" }),
    t({ "", "exit 0", "" }),
    t("function create_file() {"), t({ "", "\t" }),
    t("local FNAME=$1"), t({ "", "\t" }),
    t('touch "${FNAME}"'), t({ "", "\t" }),
    t('ls "${FNAME}" &>/dev/null && echo "✅ File created"'), t({ "", "}", "" }),
    t("function delete_file() {"), t({ "", "\t" }),
    t("local FNAME=$1"), t({ "", "\t" }),
    t('rm -f "${FNAME}"'), t({ "", "\t" }),
    t('[[ ! -e "${FNAME}" ]] && echo "✅ File deleted"'), t({ "", "}" }),
  }),

  -- 🔹 2. Function return patterns (global, return, stdout)
  s("bfunc_returns", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("GLOBAL_RET="), i(1, "255"), t({ "", "" }),
    t("# 🔹 Method 1: Global variable"), t({ "", "" }),
    t("function my_function_global() {"), t({ "", "\t" }),
    t('ls "/home/${USER}/.bashrc" &>/dev/null'), t({ "", "\t" }),
    t("GLOBAL_RET=$?"), t({ "", "}", "" }),
    t("# 🔹 Method 2: return status"), t({ "", "" }),
    t("function my_function_return() {"), t({ "", "\t" }),
    t('ls "/home/${USER}/.bashrc" &>/dev/null'), t({ "", "\t" }),
    t("return $?"), t({ "", "}", "" }),
    t("# 🔹 Method 3: stdout capture"), t({ "", "" }),
    t("function my_function_str() {"), t({ "", "\t" }),
    t("local UNAME=$1"), t({ "", "\t" }),
    t('local OUTPUT=""'), t({ "", "\t" }),
    t('if [[ -e "/home/${UNAME}/.bashrc" ]]; then'), t({ "", "\t\t" }),
    t("OUTPUT='FOUND IT'"), t({ "", "\t" }),
    t("else"), t({ "", "\t\t" }),
    t("OUTPUT='NOT FOUND'"), t({ "", "\t" }),
    t("fi"), t({ "", "\t" }),
    t('echo "${OUTPUT}"'), t({ "", "}", "" }),
    t({ "", "# 📤 Usage & Testing" }),
    t({ '', 'echo "Current ret: ${GLOBAL_RET}"', '' }),
    t('my_function_global "${USER}"'), t({ "", "" }),
    t({ '', 'echo "After global: ${GLOBAL_RET}"', "" }),
    t("GLOBAL_RET="), i(2, "255"), t({ "", "" }),
    t({ '', 'echo "Current ret: ${GLOBAL_RET}"', '' }),
    t('my_function_return "${USER}"'), t({ "", "" }),
    t("GLOBAL_RET=$?"), t({ "", "" }),
    t({ '', 'echo "After return: ${GLOBAL_RET}"', "" }),
    t("# And for giggles, we can pass back output too!"), t({ "", "" }),
    t('GLOBAL_RET=""'), t({ "", "" }),
    t({ '', 'echo "Current ret: ${GLOBAL_RET}"', '' }),
    t('GLOBAL_RET=$(my_function_str "${USER}")'), t({ "", "" }),
    t('# You could also use GLOBAL_RET=`my_function_str "${USER}"`'), t({ "", "" }),
    t({ '', 'echo "After capture: $GLOBAL_RET"', "" }),
    t("exit 0"),
  }),

  -- 🔹 Bonus: Generic function template with return & echo
  s("bfunc_gen", {
    t("function "), i(1, "my_function"), t("() {"), t({ "", "\t" }),
    t("local ARG1=$1"), t({ "", "\t" }),
    t("local ARG2=$2"), t({ "", "\t" }),
    t({ "", "\t# Your logic here" }),
    t({ "", "\tlocal RESULT=$(( ARG1 + ARG2 ))" }),
    t({ "", "", "\t# 🔙 Return status (0-255)" }),
    t({ "", "\treturn 0" }),
    t({ "", "", "\t# 📤 OR echo data to capture: $(my_function 1 2)" }),
    t({ "", '\techo "${RESULT}"' }),
    t({ "", "}" }),
  }),

    -- 🔹 1. I/O Redirection & Pipes Demo
  s("bredirect", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 1. Send all output to /dev/null (silence command)"), t({ "", "" }),
    t('echo "No output?"'), t({ "", "" }),
    t("ls ~/"), i(1, "fakefile.txt"), t(" > /dev/null 2>&1"), t({ "", "" }),
    t("# 🔹 2. Capture piped output (modern $() syntax)"), t({ "", "" }),
    t("HISTORY_TEXT=$(cat ~/.bashrc | grep "), i(2, "HIST"), t(")"), t({ "", "" }),
    t('echo "${HISTORY_TEXT}"'), t({ "", "" }),
    t("# 🔹 3. Redirect output to file (overwrite)"), t({ "", "" }),
    t('echo "${HISTORY_TEXT}" > "'), i(3, "history.config"), t('"'), t({ "", "" }),
    t("# 🔹 4. Use file as input"), t({ "", "" }),
    t("cat < "), rep(3), t({ "", "" }),
    t("# 🔹 5. Append to file"), t({ "", "" }),
    t('echo "'), i(4, "MY_VAR=1"), t('" >> '), rep(3), t({ "", "" }),
    t("# 🔹 6. Tee: output to console AND file simultaneously"), t({ "", "" }),
    t("ls -la "), i(5, "~/fakefile.txt"), t(" ~/ 2>&1 | tee "), i(6, "neato.txt"),
  }),

  s("bgetopts", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('HELP_STR="usage: $0 [-h] [-f <val>] [-l <val>] [--firstname=<val>] [--lastname=<val>] [--help]"'), t({ "", "" }),
    t('optspec=":flh-:"'), t({ "", "" }),
    t("while getopts \"$optspec\" optchar; do"), t({ "", "\t" }),
    t('case "${optchar}" in'), t({ "", "\t\t" }),
    t("-)"), t({ "", "\t\t\t" }),
    t('case "${OPTARG}" in'), t({ "", "\t\t\t\t" }),
    t("firstname)"), t({ "", "\t\t\t\t\t" }),
    t('val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))'), t({ "", "\t\t\t\t\t" }),
    -- ✅ ВИПРАВЛЕНО: прибрано зайвий t() та додано правильну структуру
    i(1, "FIRSTNAME"), t('="${val}"'), t({ "", "\t\t\t\t" }),
    t(";;"),
    t({ "", "\t\t\t\t" }),
    t("lastname)"), t({ "", "\t\t\t\t\t" }),
    t('val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))'), t({ "", "\t\t\t\t\t" }),
    -- ✅ ВИПРАВЛЕНО
    i(2, "LASTNAME"), t('="${val}"'), t({ "", "\t\t\t\t" }),
    t(";;"),
    t({ "", "\t\t\t\t" }),
    t("help)"), t({ "", "\t\t\t\t\t" }),
    t('echo "${HELP_STR}"'), t({ "", "\t\t\t\t\t" }),
    t("exit 0"), t({ "", "\t\t\t\t" }),
    t(";;"),
    t({ "", "\t\t\t\t" }),
    t("*)"), t({ "", "\t\t\t\t\t" }),
    t('if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then'), t({ "", "\t\t\t\t\t\t" }),
    t('echo "Unknown option --${OPTARG}" >&2'), t({ "", "\t\t\t\t\t" }),
    t("fi"), t({ "", "\t\t\t\t\t" }),
    t(";;"),
    t({ "", "\t\t\t\t" }),
    t("esac"), t({ "", "\t\t\t" }),
    t(";;"),
    t({ "", "\t\t" }),
    t("f)"), t({ "", "\t\t\t" }),
    t('val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))'), t({ "", "\t\t\t" }),
    rep(1), t('="${val}"'), t({ "", "\t\t" }),
    t(";;"),
    t({ "", "\t\t" }),
    t("l)"), t({ "", "\t\t\t" }),
    t('val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))'), t({ "", "\t\t\t" }),
    rep(2), t('="${val}"'), t({ "", "\t\t" }),
    t(";;"),
    t({ "", "\t\t" }),
    t("h)"), t({ "", "\t\t\t" }),
    t('echo "${HELP_STR}" >&2'), t({ "", "\t\t\t" }),
    t("exit 2"), t({ "", "\t\t" }),
    t(";;"),
    t({ "", "\t\t" }),
    t("*)"), t({ "", "\t\t\t" }),
    t('if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then'), t({ "", "\t\t\t\t" }),
    t("echo \"Error parsing short flag: '-${OPTARG}'\" >&2"), t({ "", "\t\t\t\t" }),
    t("exit 1"), t({ "", "\t\t\t" }),
    t("fi"), t({ "", "\t\t" }),
    t(";;"),
    t({ "", "\t" }),
    t("esac"), t({ "", "" }),
    t("done"), t({ "", "" }),
    t("# 🔹 Validate arguments"), t({ "", "" }),
    t('if [ -z "$1" ]; then'), t({ "", "\t" }),
    t('echo "${HELP_STR}" >&2'), t({ "", "\t" }),
    t("exit 2"), t({ "", "fi", "" }),
    t('if [ -z "${'), rep(1), t('}" ] || [ -z "${'), rep(2), t('" ]; then'), t({ "", "\t" }),
    t('echo "Both firstname and lastname are required!"'), t({ "", "\t" }),
    t("exit 3"), t({ "", "fi", "" }),
    t('echo "Welcome ${'), rep(1), t('} ${'), rep(2), t('}!"'), t({ "", "" }),
    t("exit 0"),
  }),

    -- 🔹 1. Grep/Find Search Patterns Demo
  s("bgrep_find", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('DIRECTORY="'), i(1, "www.packtpub.com/"), t('"'), t({ "", "" }),
    t('SEARCH_TERM="'), i(2, "Packt"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Basic grep (stdout → file, stderr → /dev/null)" }),
    t('grep "${SEARCH_TERM}" ~/* > result1.txt 2>&1'), t({ "", "" }),
    t({ "", "# 🔹 Recursive grep" }),
    t('grep -r "${SEARCH_TERM}" "${DIRECTORY}" > result2.txt'), t({ "", "" }),
    t({ "", "# 🔹 Multiple search terms (-e)" }),
    t('grep -r -e "${SEARCH_TERM}" -e "'), i(3, "Publishing"), t('" "${DIRECTORY}" > result3.txt'), t({ "", "" }),
    t({ "", "# 🔹 Find + xargs + grep" }),
    t('find "${DIRECTORY}" -type f -print | xargs grep "${SEARCH_TERM}" > result4.txt'), t({ "", "" }),
    t({ "", "# 🔹 Find by extension + exclude" }),
    t('find "${DIRECTORY}" -type f -name "*.'), i(4, "xml"), t('" ! -name "*.css" -print | xargs grep "${SEARCH_TERM}" > result5.txt'), t({ "", "" }),
    t({ "", "# 🔹 Wildcards + subshell (use with caution!)" }),
    t('grep "${SEARCH_TERM}" $(ls -R "${DIRECTORY}"*.{'), i(5, "html"), t(","), i(6, "txt"), t('}) > result6.txt'), t({ "", "" }),
    t("RES=$?"), t({ "", "" }),
    t({ "", 'if [ ${RES} -eq 0 ]; then', '\techo "✅ We found results!"', "else", '\techo "❌ It broke - it shouldn\'t happen!"', "fi", "" }),
    t({ "", "# 🔹 Bonus: search command history" }),
    t('history | grep "'), i(7, "ls"), t('"'), t({ "", "" }),
    t({ "", 'echo "🎯 We can do a lot with grep!"', "exit 0" }),
  }),

  -- 🔹 2. Character Class Patterns with grep/ls
  s("bgrep_class", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('STR1="'), i(1, "123 is a number, ABC is alphabetic & aBC123 is alphanumeric."), t({ '"', "" }),
    t({ "", 'echo "-------------------------------------------------"', "" }),
    t({ "", "# 🔹 Files starting with uppercase + ending with .pdf" }),
    t('ls * | grep "[[:upper:]]*.pdf"'), t({ "", "" }),
    t({ "", 'echo "-------------------------------------------------"', "" }),
    t({ "", "# 🔹 Just directories starting with uppercase" }),
    t('ls -l [[:upper:]]* | grep "^d"'), t({ "", "" }),
    t({ "", 'echo "-------------------------------------------------"', "" }),
    t({ "", "# 🔹 Files created with brace expansion" }),
    t('ls *.{'), i(2, "test"), t(","), i(3, "txt"), t("}"), t({ "", "" }),
    t({ "", 'echo "-------------------------------------------------"', "" }),
    t({ "", "# 🔹 Extract punctuation on one line" }),
    t('echo "${STR1}" | grep -o "[[:punct:]]" | xargs echo'), t({ "", "" }),
    t({ "", 'echo "-------------------------------------------------"', "" }),
    t({ "", "# 🔹 Regex groups + single-char wildcards (top 5)" }),
    t('ls | grep -E "([[:upper:]])([[:digit:]])?.test?" | tail -n 5'), t({ "", "" }),
    t({ "", "exit 0" }),
  }),

  -- 🔹 3. String Substring Extraction ${VAR:start:length}
  s("str_sub", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('VARIABLE="'), i(1, "My test string"), t({ '"', "" }),
    t({ "", "# 🔹 ${VAR:start:length} — позиція з 0, довжина опціональна" }),
    t({ "", "# Приклад: ${VARIABLE:3:4} → 'test' (починаючи з індексу 3, 4 символи)" }),
    t({ "", "" }),
    t('echo "Original: ${VARIABLE}"'), t({ "", "" }),
    t('echo "Substring (3:4): ${VARIABLE:'), i(2, "3"), t(":"), i(3, "4"), t('}"'), t({ "", "" }),
    t({ "", "# 🔹 Інші варіанти:" }),
    t({ "", '# ${VARIABLE:5}      → від позиції 5 до кінця', "" }),
    t({ "", '# ${VARIABLE: -7}    → останні 7 символів (пробіл перед -!)', "" }),
    t({ "", '# ${VARIABLE:0:2}    → перші 2 символи', "" }),
    t({ "", "" }),
    t('echo "From pos 5: ${VARIABLE:5}"'), t({ "", "" }),
    t('echo "Last 7 chars: ${VARIABLE: -7}"'), t({ "", "" }),
    t('echo "First 2 chars: ${VARIABLE:0:2}"'), t({ "", "" }),
    t({ "", "exit 0" }),
  }),

    -- 🔹 1. Tarball Space Checker + Safe Extract
  s("tar_check", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Retrieve filesystem info (1M blocks, no header)"), t({ "", "" }),
    t('TARBALL="'), i(1, "archive.tar.gz"), t('"'), t({ "", "" }),
    t('CURRENT_PART_ALL=$(df --output=size,avail,used /home -B 1M | tail -n1)'), t({ "", "" }),
    t({ "", "# 🔹 Parse into array (quote variable to preserve spaces)" }),
    t("IFS=' ' read -r -a array <<< \"$CURRENT_PART_ALL\""), t({ "", "" }),
    t({ "", "# 🔹 Calculate compressed size from tar listing" }),
    t('COMPRESSED_SZ=$(tar tzvf "${TARBALL}" | sed \'s/ \\+/ /g\' | cut -f3 -d\' \' | sed \'2,$s/^/+ /\' | paste -sd\' \' | bc)'), t({ "", "" }),
    t({ "", 'echo "🔍 First inspection - is there enough space?"', "" }),
    t('if [ "${array[1]}" -lt "${COMPRESSED_SZ}" ]; then'), t({ "", "\t" }),
    t('echo "❌ Not enough space to decompress the binary"'), t({ "", "\t" }),
    t("exit 1"), t({ "", "else" }), t({ "", "\t" }),
    t('echo "✅ Seems we have enough space - continuing"'), t({ "", "\t" }),
    t("VAR=$((${array[0]} - ${array[2]}))"), t({ "", "\t" }),
    t('echo "💾 Space left: ${VAR}M"'), t({ "", "fi", "" }),
    t({ "", 'echo "🛡️ Safety check - do we have at least double the space?"', "" }),
    t("CHECK=$((${array[1]} * 2))"), t({ "", "" }),
    t('echo "📏 Double required: ${CHECK}M"'), t({ "", "" }),
    t({ "", "# 🔹 Optional: bc floating-point check (mhelper example)" }),
    t('RES=$(echo "scale=2; ${array[1]} / 2 > 0" | bc -l)'), t({ "", "" }),
    t('if [[ "${RES}" == "1" ]]; then'), t({ "", "\t" }),
    t('echo "🧟 Sppppppaaaaccee (imagine zombies)"'), t({ "", "fi", "" }),
    t({ "", "# 🔹 Finally: extract tarball" }),
    t('tar xzvf "${TARBALL}"'), t({ "", "" }),
    t("RES=$?"), t({ "", "" }),
    t('if [ ${RES} -ne 0 ]; then'), t({ "", "\t" }),
    t('echo "❌ Error decompressing the tarball!"'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", 'echo "🎉 Decompression complete!"', "exit 0" }),
  }),

 s("bstr_compare", {
    t("#!/bin/bash"), t({ "", "" }),
    t("# 🔹 Substring extraction & lexicographic comparison"), t({ "", "" }),
    
    t('STR="'), i(1, "1234567890asdfghjkl"), t('"'), t({ "", "" }),
    t('echo "first character ${STR:0:1}"'), t({ "", "" }),
    t('echo "first three characters ${STR:0:3}"'), t({ "", "" }),
    t('echo "third character onwards ${STR:3}"'), t({ "", "" }),
    t('echo "forth to sixth character ${STR:3:3}"'), t({ "", "" }),
    t('echo "last character ${STR: -1}"'), t({ "", "" }),
    
    t({ "", "" }),
    t("# 🔹 Lexicographic comparison (case-sensitive)"), t({ "", "" }),
    
    t('STR2="'), i(2, "abc"), t('"'), t({ "", "" }),
    t('STR3="'), i(3, "bcd"), t('"'), t({ "", "" }),
    t('STR4="'), i(4, "Bcd"), t('"'), t({ "", "" }),
    
    t("if [[ $STR2 < $STR3 ]]; then"), t({ "", "\t" }),
    t('echo "STR2 is less than STR3"'), t({ "", "else", "\t" }),
    t('echo "STR3 is greater than STR2"'), t({ "", "fi", "" }),
    
    t({ "", "" }),
    t("# Case matters: ASCII 'b' (98) > 'B' (66)"), t({ "", "" }),
    t("if [[ $STR3 < $STR4 ]]; then"), t({ "", "\t" }),
    t('echo "STR3 is less than STR4"'), t({ "", "else", "\t" }),
    t('echo "STR4 is greater than STR3"'), t({ "", "fi" }),
  }),

  s("csv_process", {
    t("#!/bin/bash"), t({ "", "" }),
    t("# 🔹 CSV Processing: strip, uppercase, replace, remove column"), t({ "", "" }),
    
    t('GB_CSV="'), i(1, "testdata/garbage.csv"), t('"'), t({ "", "" }),
    t('EM_CSV="'), i(2, "testdata/employees.csv"), t('"'), t({ "", "" }),
    
    t({ "", "# 🔹 Save & set IFS for CSV parsing" }),
    t("oldIFS=$IFS"), t({ "", "" }),
    t("IFS=','"), t({ "", "" }),
    
    t({ "", "# 🔹 Read garbage.csv into array" }),
    t('readarray -t ARR < "${'), rep(1), t('"'), t({ "", "" }),
    t({ "", '# 🔹 Count rows', '' }),
    t('ARRY_ELEM=${#ARR[@]}'), t({ "", "" }),
    t('echo "We have ${ARRY_ELEM} rows in ${'), rep(1), t('}"'), t({ "", "" }),
    
    t({ "", "# 🔹 Strip spaces after commas" }),
    t("INC=0"), t({ "", "" }),
    t('for i in "${ARR[@]}"; do'), t({ "", "\t" }),
    t('res="${i// /}"  # Remove all spaces'), t({ "", "\t" }),
    t('TMP_CNT=${#res}'), t({ "", "\t" }),
    t('while [ ${TMP_CNT} -gt 0 ]; do'), t({ "", "\t\t" }),
    t('i=${i/, /,}  # Replace ", " with ","'), t({ "", "\t\t" }),
    t("TMP_CNT=$(( TMP_CNT - 1 ))"), t({ "", "\t" }),
    t("done"), t({ "", "\t" }),
    t("ARR[$INC]=$i"), t({ "", "\t" }),
    t("INC=$(( INC + 1 ))"), t({ "", "done", "" }),
    
    t({ "", "# 🔹 Remove last character from each line" }),
    t("INC=0"), t({ "", "" }),
    t('for i in "${ARR[@]}"; do'), t({ "", "\t" }),
    t('ARR[$INC]=${i::-1}'), t({ "", "\t" }),
    t("INC=$(( INC + 1 ))"), t({ "", "done", "" }),
    
    t({ "", "# 🔹 Convert to uppercase" }),
    t("INC=0"), t({ "", "" }),
    t('for i in "${ARR[@]}"; do'), t({ "", "\t" }),
    t('ARR[$INC]=${i^^}'), t({ "", "\t" }),
    t('printf "%s\\n" "${ARR[$INC]}"'), t({ "", "\t" }),
    t("INC=$(( INC + 1 ))"), t({ "", "done", "" }),
    
    t({ "", "# 🔹 Process employees.csv: prepend # to first field" }),
    t("IFS=','"), t({ "", "" }),
    t('readarray -t ARR < "${'), rep(2), t('"'), t({ "", "" }),
    t('ARRY_ELEM=${#ARR[@]}'), t({ "", "" }),
    t('echo; echo "We have ${ARRY_ELEM} rows in ${'), rep(2), t('}"'), t({ "", "" }),
    
    t({ "", "# 🔹 Add # at start of each line" }),
    t("INC=0"), t({ "", "" }),
    t('for i in "${ARR[@]}"; do'), t({ "", "\t" }),
    t('ARR[$INC]="#${i}"'), t({ "", "\t" }),
    t('printf "%s\\n" "${ARR[$INC]}"'), t({ "", "\t" }),
    t("INC=$(( INC + 1 ))"), t({ "", "done", "" }),
    
    t({ "", "# 🔹 Replace Bob → Robert" }),
    t('echo; echo "Let\'s make Bob, Robert!"'), t({ "", "" }),
    t("INC=0"), t({ "", "" }),
    t('for i in "${ARR[@]}"; do'), t({ "", "\t" }),
    t('ARR[$INC]=${i/Bob/Robert}'), t({ "", "\t" }),
    t('printf "%s\\n" "${ARR[$INC]}"'), t({ "", "\t" }),
    t("INC=$(( INC + 1 ))"), t({ "", "done", "" }),
    
    t({ "", "# 🔹 Remove column (e.g., birthday = column 4, 0-indexed)" }),
    t('echo; echo "Lets remove the column: birthday (1-31)"'), t({ "", "" }),
    t("INC=0"), t({ "", "" }),
    t("COLUMN_TO_REM="), i(3, "4"), t("  # 0-indexed column to remove"), t({ "", "" }),
    t('for i in "${ARR[@]}"; do'), t({ "", "\t" }),
    t("TMP_CNT=0"), t({ "", "\t" }),
    t('STR=""'), t({ "", "\t" }),
    t("IFS=',' read -ra ELEM_ARR <<< \"$i\""), t({ "", "\t" }),
    t('for field in "${ELEM_ARR[@]}"; do'), t({ "", "\t\t" }),
    t('if [ $TMP_CNT -ne 0 ] && [ $TMP_CNT -ne $COLUMN_TO_REM ]; then'), t({ "", "\t\t\t" }),
    t('STR="${STR},${field}"'), t({ "", "\t\t" }),
    t("elif [ $TMP_CNT -eq 0 ]; then"), t({ "", "\t\t\t" }),
    t('STR="${STR}${field}"'), t({ "", "\t\t" }),
    t("fi"), t({ "", "\t\t" }),
    t("TMP_CNT=$(( TMP_CNT + 1 ))"), t({ "", "\t" }),
    t("done"), t({ "", "\t" }),
    t("ARR[$INC]=$STR"), t({ "", "\t" }),
    t('echo "${ARR[$INC]}"'), t({ "", "\t" }),
    t("INC=$(( INC + 1 ))"), t({ "", "done", "" }),
    
    t({ "", "# 🔹 Restore IFS" }),
    t("IFS=$oldIFS"), t({ "", "" }),
    t("exit 0"),
  }),

  -- 🔹 1. Sed String Manipulation (substring via regex)
  s("sed_str", {
    t("#!/bin/bash"), t({ "", "" }),
    t('STR="'), i(1, "1234567890asdfghjkl"), t({ '"', "" }),
    t({ "", "# 🔹 Extract characters using sed" }),
    t({ "", "# First character (skip 1, print rest)" }),
    t('echo -n "First character: "; sed \'s/.//2g\' <<< "$STR"'), t({ "", "" }),
    t({ "", "# First three characters (skip 4, print rest)" }),
    t('echo -n "First three: "; sed \'s/.//4g\' <<< "$STR"'), t({ "", "" }),
    t({ "", "# Third character onwards (remove first 3)" }),
    t('echo -n "From pos 3: "; sed -r \'s/.{3}//\' <<< "$STR"'), t({ "", "" }),
    t({ "", "# Fourth to sixth (remove first 3, then skip 4)" }),
    t('echo -n "Pos 3-5: "; sed -r \'s/.{3}//;s/.//4g\' <<< "$STR"'), t({ "", "" }),
    t({ "", "# Last character only" }),
    t('echo -n "Last char: "; sed \'s/.*\\(.$\\)/\\1/\' <<< "$STR"'), t({ "", "" }),
    t({ "", "# Remove last character" }),
    t('echo -n "Without last: "; sed \'s/.$//\' <<< "$STR"'),
  }),

s("bprintf_fmt", {
  t("#!/bin/bash"), t({ "", "" }),
  t("# 🔹 Set locale for consistent decimal separator"), t({ "", "" }),
  t('export LC_NUMERIC="'), i(1, "en_US.UTF-8"), t('"'), t({ "", "" }),
  t({ "", 'printf "This is the same as echo -e with a new line (\\\\n)\\n"', "" }),
  t({ "", "# 🔹 Decimal formatting" }),
  t("DECIMAL="), i(2, "10.0"), t({ "", "" }),
  t("FLOAT="), i(3, "3.333333"), t({ "", "" }),
  t("FLOAT2="), i(4, "6.666"), t("  # On purpose two missing values"), t({ "", "" }),
  t({ "", 'printf "%s %.2f\\n\\n" "This is two decimal places: " ${DECIMAL}', "" }),
  t({ "", "# 🔹 Alignment: right/left padded" }),
  t({ "", 'printf "Shall we align:\\n\\n %.3f %-.6f\\n" ${FLOAT} ${FLOAT2}', "" }),
  t({ "", 'printf " %10f %-6f\\n" ${FLOAT} ${FLOAT2}', "" }),
  t({ "", 'printf " %-10f %-6f\\n" ${FLOAT} ${FLOAT2}', "" }),
  t({ "", "", "# 🔹 Print repeated character (20 dashes)" }),
  -- ✅ ВИПРАВЛЕНО: розбито на окремі ноди
  t('printf "%.0s-" {1..'), i(5, "20"), t('}; printf "\\n"'), t({ "", "" }),
  t({ "", "# 🔹 Print each char + hex value" }),
  t('STR="'), i(6, "No place like home!"), t({ '"', "" }),
  t('CNT=$(wc -c <<< "$STR")'), t({ "", "" }),
  t("TMP_CNT=0"), t({ "", "" }),
  t({ "", 'printf "Char  Hex\\n"', "" }),
  t({ "", "while [ $TMP_CNT -lt $(( CNT - 1 )) ]; do", "\t" }),
  -- ✅ ВИПРАВЛЕНО: одинарна лапка екранована, ноди розділені
  t('printf "%-5s 0x%-2X\\n" "${STR:$TMP_CNT:1}" "\'${STR:$TMP_CNT:1}"'), t({ "", "" }),
  t({ "", "\t", "TMP_CNT=$(( TMP_CNT + 1 ))", "done" }),
}),

  s("bcsv_full", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 CSV Processing: strip spaces, uppercase, prepend #, remove column"), t({ "", "" }),
    
    t('GB_CSV="'), i(1, "testdata/garbage.csv"), t('"'), t({ "", "" }),
    t('EM_CSV="'), i(2, "testdata/employees.csv"), t('"'), t({ "", "" }),
    
    t({ "", "# 🔹 Save & set IFS for CSV parsing" }),
    t("oldIFS=$IFS"), t({ "", "" }),
    t("IFS=','"), t({ "", "" }),
    
    t({ "", "# 🔹 Read garbage.csv into array" }),
    t('readarray -t ARR < "${'), rep(1), t('"'), t({ "", "" }),
    t({ "", '# 🔹 Count rows', '' }),
    t('ARRY_ELEM=${#ARR[@]}'), t({ "", "" }),
    t('echo "We have ${ARRY_ELEM} rows in ${'), rep(1), t('}"'), t({ "", "" }),
    
    t({ "", "# 🔹 Strip spaces using sed" }),
    t("INC=0"), t({ "", "" }),
    t('for i in "${ARR[@]}"; do'), t({ "", "\t" }),
    t('ARR[$INC]=$(echo "$i" | sed \'s/ //g\')'), t({ "", "\t" }),
    t('echo "${ARR[$INC]}"'), t({ "", "\t" }),
    t("INC=$(( INC + 1 ))"), t({ "", "done", "" }),
    
    t({ "", "# 🔹 Remove last char + convert to UPPERCASE" }),
    t("INC=0"), t({ "", "" }),
    t('for i in "${ARR[@]}"; do'), t({ "", "\t" }),
    t('ARR[$INC]=$(echo "$i" | sed \'s/.$//\' | sed \'s/.*/\\U&/\')'), t({ "", "\t" }),
    t('echo "${ARR[$INC]}"'), t({ "", "\t" }),
    t("INC=$(( INC + 1 ))"), t({ "", "done", "" }),
    
    t({ "", "# 🔹 Process employees.csv: prepend # to each line" }),
    t("IFS=','"), t({ "", "" }),
    t('readarray -t ARR < "${'), rep(2), t('"'), t({ "", "" }),
    t("INC=0"), t({ "", "" }),
    t('for i in "${ARR[@]}"; do'), t({ "", "\t" }),
    t('ARR[$INC]=$(sed -e \'s/^/#/\' <<< "$i")'), t({ "", "\t" }),
    t('echo "${ARR[$INC]}"'), t({ "", "\t" }),
    t("INC=$(( INC + 1 ))"), t({ "", "done", "" }),
    
    t({ "", "# 🔹 In-place replacement: Bob → Robert, then prepend #" }),
    t('sed -i \'s/Bob/Robert/\' "${'), rep(2), t('"'), t({ "", "" }),
    t('sed -i \'s/^/#/\' "${'), rep(2), t('"'), t({ "", "" }),
    t('cat "${'), rep(2), t('"'), t({ "", "" }),
    
    t({ "", "# 🔹 Remove column 5 (birthday) using awk" }),
    t('awk \'BEGIN { FS=","; OFS="," } {$5=""; gsub(",+",",",$0)}1\' OFS=, "${'), rep(2), t('"'),
    
    t({ "", "", "# 🔹 Restore IFS" }),
    t("IFS=$oldIFS"), t({ "", "" }),
    t("exit 0"),
  }),

  s("bi18n_func", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t(". gettext.sh"), t({ "", "" }),
    t("function "), i(1, "i_have"), t("() {"), t({ "", "\t" }),
    t("local COUNT=$1"), t({ "", "" }),
    t({ "", "\t###i18n: Please leave $COUNT as is" }),
    -- ✅ ВИПРАВЛЕНО: \\$ дає літеральний \$ у виводі, прибрано зайві {}
    t('\techo -e "\\n\\t" $(eval_ngettext "I have \\$COUNT electronic device" "I have \\$COUNT electronic devices" $COUNT)'),
    t({ "", "}", "" }),
    t({ "", "# 🔹 Usage examples" }),
    t('echo $(gettext "'), i(2, "Hello"), t('")'), t({ "", "" }),
    t('echo $(gettext "'), i(3, "What is your name?"), t('")'), t({ "", "" }),
    t({ "", "###i18n: Please leave $USER as is" }),
    t('\techo -e "\\t" $(eval_gettext "My name is \\$USER")'),
    t({ "", "" }),
    t('echo $(gettext "'), i(4, "Do you have electronics?"), t('")'), t({ "", "" }),
    t({ "", "# 🔹 Test with different counts" }),
    t("i_have 0"), t({ "", "" }),
    t("i_have 1"), t({ "", "" }),
    t("i_have 2"),
  }),

  -- 🔹 2. Locale environment setup for testing
  s("bi18n_env", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Set localization variables for testing"), t({ "", "" }),
    t('export TEXTDOMAIN="'), i(1, "hellobonjour"), t('"'), t({ "", "" }),
    t('export TEXTDOMAINDIR="$(pwd)/'), i(2, "locale"), t('"'), t({ "", "" }),
    t('export LANGUAGE="'), i(3, "fr"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Optional: override LC_MESSAGES for specific category" }),
    t('export LC_MESSAGES="${LANGUAGE}"'), t({ "", "" }),
    t({ "", "# 🔹 Run your script with new locale" }),
    t("./"), i(4, "hellobonjour"), t(".sh"),
  }),

  -- 🔹 3. Quick gettext call template
  s("bgettext", {
    t('$(gettext "'), i(1, "Message to translate"), t('")'),
  }),

  -- 🔹 4. eval_gettext with variable template
  s("beval_gettext", {
    t("###i18n: Please leave $"), i(1, "VAR"), t(" as is"), t({ "", "" }),
    t('$(eval_gettext "'), i(2, "Template with $"), rep(1), t('")'),
  }),

  -- 🔹 5. ngettext (singular/plural) template
  s("bngettext", {
    t("###i18n: Please leave $"), i(1, "COUNT"), t(" as is"), t({ "", "" }),
    t('$(eval_ngettext "'), i(2, "One item: $"), rep(1), t('"'), t({ "", "" }),
    t('  "'), i(3, "Multiple items: $"), rep(1), t('"'), t({ "", "" }),
    t("  $"), rep(1), t(")"),
  }),

    s("bfile_attrib", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("FILE_TO_TEST=\"\""), t({ "", "" }),
    t("function permissions() {"), t({ "", "  " }),
    t('echo -e "\\nWhat are our permissions on this $2?\\n"'), t({ "", "  " }),
    t('if [ -r "$1" ]; then'), t({ "", "    " }),
    t('echo -e "[R] Read"'), t({ "", "  " }),
    t("fi"), t({ "", "  " }),
    t('if [ -w "$1" ]; then'), t({ "", "    " }),
    t('echo -e "[W] Write"'), t({ "", "  " }),
    t("fi"), t({ "", "  " }),
    t('if [ -x "$1" ]; then'), t({ "", "    " }),
    t('echo -e "[X] Exec"'), t({ "", "  " }),
    t("fi"), t({ "", "}" }), t({ "", "" }),
    t("function file_attributes() {"), t({ "", "  " }),
    t('if [ ! -s "$1" ]; then'), t({ "", "    " }),
    t('echo "\\"$1\\" is empty"'), t({ "", "  " }),
    t("else"), t({ "", "    " }),
    t('FSIZE=$(stat --printf="%s" "$1" 2>/dev/null)'), t({ "", "    " }),
    t("RES=$?"), t({ "", "    " }),
    t("if [ $RES -eq 1 ]; then"), t({ "", "      " }),
    t("return"), t({ "", "    " }),
    t("else"), t({ "", "      " }),
    t('echo "\\"$1\\" file size is: ${FSIZE}\\""'), t({ "", "    " }),
    t("fi"), t({ "", "  " }),
    t("fi"), t({ "", "  " }),
    t('if [ ! -O "$1" ]; then'), t({ "", "    " }),
    t('echo -e "${USER} is not the owner of \\"$1\\"\\n"'), t({ "", "  " }),
    t("fi"), t({ "", "  " }),
    t('if [ ! -G "$1" ]; then'), t({ "", "    " }),
    t('echo -e "${USER} is not among the owning group(s) for \\"$1\\"\\n"'), t({ "", "  " }),
    t("fi"), t({ "", "  " }),
    t("permissions \"$1\" \"file\""), t({ "", "}" }), t({ "", "" }),
    t("function dir_attributes() {"), t({ "", "  " }),
    t('echo -e "Directory \\"$1\\" has children:\\n\\n"'), t({ "", "  " }),
    t("ls -1 \"$1\""), t({ "", "  " }),
    t("permissions \"$1\" \"directory\""), t({ "", "}" }), t({ "", "" }),
    t("function checkout_file() {"), t({ "", "  " }),
    t("FILE_TO_TEST=\"\""), t({ "", "  " }),
    t('echo -en "\\n'), i(1, "What is the complete path of the file you want to inspect?"), t('\\n # "'), t({ "", "  " }),
    t("read -r FILE_TO_TEST"), t({ "", "  " }),
    t("echo"), t({ "", "  " }),
    t('if [ ! -e "${FILE_TO_TEST}" ]; then'), t({ "", "    " }),
    t('echo "Error: \\"${FILE_TO_TEST}\\" does not exist!"'), t({ "", "    " }),
    t("exit 1"), t({ "", "  " }),
    t("fi"), t({ "", "  " }),
    t('if [ -f "${FILE_TO_TEST}" ]; then'), t({ "", "    " }),
    t('file_attributes "${FILE_TO_TEST}"'), t({ "", "    " }),
    t("checkout_file"), t({ "", "  " }),
    t("else"), t({ "", "    " }),
    t('dir_attributes "${FILE_TO_TEST}"'), t({ "", "    " }),
    t("checkout_file"), t({ "", "  " }),
    t("fi"), t({ "", "}" }), t({ "", "" }),
    t('echo "'), i(2, "Welcome to the file attributes tester"), t('"'), t({ "", "" }),
    t("echo"), t({ "", "" }),
    t('echo "To exit, press CTRL + C"'), t({ "", "" }),
    t("checkout_file"),
  }),

    -- 🔹 1. XML Generation from CSV + Templates
  s("bxml_gen", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("source xml-parent.tpl"), t({ "", "" }),
    t("source word.tpl"), t({ "", "" }),
    t('OUTPUT_FILE="'), i(1, "words.xml"), t('"'), t({ "", "" }),
    t('INPUT_FILE="'), i(2, "words.csv"), t('"'), t({ "", "" }),
    t("DELIMITER="), i(3, "','"), t({ "", "" }),
    t({ "", "# 🔹 Setup header" }),
    t('echo "${XML_HDR}" > "${OUTPUT_FILE}"'), t({ "", "" }),
    t('echo "${SRT_CONTR}" >> "${OUTPUT_FILE}"'), t({ "", "" }),
    t({ "", "# 🔹 Process CSV into XML via template pipeline" }),
    t([[echo "${ELM}" | \]]), t({ "", "" }),
    t([[sed '{:q;N;s/\n/\\n/g;t q}' | \]]), t({ "", "" }),
    t([[awk '{ print "awk \x27 BEGIN{FS="']] ), t('${DELIMITER}'), t([['"}{print "$0"}\x27 ']]), t('${INPUT_FILE}'), t([['"}' | \]]), t({ "", "" }),
    t('  sh >> "${OUTPUT_FILE}"'), t({ "", "" }),
    t({ "", "# 🔹 Append trailer" }),
    t('echo "${END_CONTR}" >> "${OUTPUT_FILE}"'), t({ "", "" }),
    t('cat "${OUTPUT_FILE}"'),
  }),

  -- 🔹 2. XML to JSON Converter
  s("bxml2json", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('INPUT_FILE="'), i(4, "words.xml"), t('"'), t({ "", "" }),
    t('OUTPUT_FILE="'), i(5, "words.json"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 One-line XML to JSON conversion" }),
    t('xml2json < "${INPUT_FILE}" > "${OUTPUT_FILE}"'), t({ "", "" }),
    t('echo "✅ Converted ${INPUT_FILE} -> ${OUTPUT_FILE}"'),
  }),

    s("btree", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Recursive Directory Tree Printer"), t({ "", "" }),
    t("CURRENT_LVL=0"), t({ "", "" }),
    t("function tab_creator() {"), t({ "", "  " }),
    t("local LVL=$1"), t({ "", "  " }),
    t('local TABS=""'), t({ "", "  " }),
    t("local X=0"), t({ "", "  " }),
    t("while [ $X -lt $LVL ]; do"), t({ "", "    " }),
    t('TABS="${TABS}'), i(1, "  "), t('"  # Indent per level'), t({ "", "    " }),
    t("X=$(( X + 1 ))"), t({ "", "  " }),
    t("done"), t({ "", "  " }),
    t('echo -n "$TABS"'), t({ "", "}", "", "" }),
    t("function recursive_tree() {"), t({ "", "  " }),
    t("local ENTRY=$1"), t({ "", "  " }),
    t('for LEAF in "${ENTRY}"/*; do'), t({ "", "    " }),
    t('[ -e "$LEAF" ] || continue  # Skip empty dirs'), t({ "", "    " }),
    t('if [ -d "$LEAF" ]; then'), t({ "", "      " }),
    t('TABS=$(tab_creator $CURRENT_LVL)'), t({ "", "      " }),
    t('printf "%s├─ %s\\n" "$TABS" "$LEAF"'), t({ "", "      " }),
    t("CURRENT_LVL=$(( CURRENT_LVL + 1 ))"), t({ "", "      " }),
    t('recursive_tree "$LEAF"'), t({ "", "      " }),
    t("CURRENT_LVL=$(( CURRENT_LVL - 1 ))"), t({ "", "    " }),
    t('elif [ -f "$LEAF" ]; then'), t({ "", "      " }),
    t('TABS=$(tab_creator $CURRENT_LVL)'), t({ "", "      " }),
    t('printf "%s└─ %s\\n" "$TABS" "$LEAF"'), t({ "", "    " }),
    t("fi"), t({ "", "  " }),
    t("done"), t({ "", "}", "", "" }),
    t("# 🔹 Usage: ./script.sh <directory>"), t({ "", "" }),
    t('PARENTDIR="${1:-.}"'), t({ "", "" }),
    t('if [ ! -d "$PARENTDIR" ]; then'), t({ "", "  " }),
    t('echo "Error: \\"$PARENTDIR\\" not found" >&2'), t({ "", "  " }),
    t("exit 1"), t({ "", "fi", "", "" }),
    t('echo "📂 Tree for: $PARENTDIR"'), t({ "", "" }),
    t('recursive_tree "$PARENTDIR"'),
  }),

    s("btestdir", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('BDIR="'), i(1, "files_galore"), t('"'), t({ "", "" }),
    t("# 🔹 Clean & recreate directory"), t({ "", "" }),
    t('rm -rf "${BDIR}"'), t({ "", "" }),
    t('mkdir -p "${BDIR}"'), t({ "", "" }),
    t({ "", "# 🔹 Populate with test files" }),
    t('touch "${BDIR}/file1"; echo "'), i(2, "1111111111111111111111111111111"), t('" > "${BDIR}/file1"'), t({ "", "" }),
    t('touch "${BDIR}/file2"; echo "'), i(3, "2222222222222222222222222222222"), t('" > "${BDIR}/file2"'), t({ "", "" }),
    t('touch "${BDIR}/file3"; echo "'), i(4, "3333333333333333333333333333333"), t('" > "${BDIR}/file3"'), t({ "", "" }),
    t('touch "${BDIR}/file4"; echo "'), i(5, "4444444444444444444444444444444"), t('" > "${BDIR}/file4"'), t({ "", "" }),
    t('touch "${BDIR}/file5"; echo "'), i(6, "4444444444444444444444444444444"), t('" > "${BDIR}/file5"'), t({ "", "" }),
    t('touch "${BDIR}/sameas5"; echo "'), i(7, "4444444444444444444444444444444"), t('" > "${BDIR}/sameas5"'), t({ "", "" }),
    t('touch "${BDIR}/sameas1"; echo "'), i(8, "1111111111111111111111111111111"), t('" > "${BDIR}/sameas1"'),
  }),

    s("bdedup", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("declare -a HASH_ARRAY=()"), t({ "", "" }),
    t("add_hash() {"), t({ "", "\t" }),
    t('HASH_ARRAY+=("$1")'), t({ "", "}", "" }),
    t("check_file() {"), t({ "", "\t" }),
    t('local FILE="$1"'), t({ "", "\t" }),
    t('[[ -f "$FILE" ]] || return 1'), t({ "", "\t" }),
    t("local SUM"), t({ "", "\t" }),
    t([[SUM=$(sha512sum "$FILE" | awk '{print $1}')]]), t({ "", "\t" }),
    t("# 🔍 Check if hash already exists"), t({ "", "\t" }),
    t('for HASH in "${HASH_ARRAY[@]}"; do'), t({ "", "\t\t" }),
    t('if [[ "$SUM" == "$HASH" ]]; then'), t({ "", "\t\t\t" }),
    t('echo "dup"'), t({ "", "\t\t\t" }),
    t("return 0"), t({ "", "\t\t" }),
    t("fi"), t({ "", "\t" }),
    t("done"), t({ "", "\t" }),
    t("# ✅ New hash found"), t({ "", "\t" }),
    t('add_hash "$SUM"'), t({ "", "\t" }),
    t('echo "new"'), t({ "", "\t" }),
    t("return 0"), t({ "", "}", "" }),
    t("deduplicate() {"), t({ "", "\t" }),
    t('local DIR_TO_SRCH="$1"'), t({ "", "\t" }),
    t("shopt -s nullglob  # Handle empty dirs safely"), t({ "", "\t" }),
    t('local FILES=("${DIR_TO_SRCH}"/*)'), t({ "", "\t" }),
    t("shopt -u nullglob"), t({ "", "\t" }),
    t('if [[ ${#FILES[@]} -eq 0 ]]; then'), t({ "", "\t\t" }),
    t([[echo "No files found in \"$DIR_TO_SRCH\""]]), t({ "", "\t\t" }),
    t("return"), t({ "", "\t" }),
    t("fi"), t({ "", "\t" }),
    t('for FILE in "${FILES[@]}"; do'), t({ "", "\t\t" }),
    t("local STATUS"), t({ "", "\t\t" }),
    t('STATUS=$(check_file "$FILE")'), t({ "", "\t\t" }),
    t('if [[ "$STATUS" == "dup" ]]; then'), t({ "", "\t\t\t" }),
    t('echo "🗑️  Deleting duplicate: $FILE"'), t({ "", "\t\t\t" }),
    t('rm "$FILE"'), t({ "", "\t\t" }),
    t("else"), t({ "", "\t\t\t" }),
    t('echo "✅ Keeping new file: $FILE"'), t({ "", "\t\t" }),
    t("fi"), t({ "", "\t" }),
    t("done"), t({ "", "}", "" }),
    t("dump_hashes() {"), t({ "", "\t" }),
    t([[echo -e "\n📋 Unique SHA-512 hashes tracked:"]]), t({ "", "\t" }),
    t('for i in "${!HASH_ARRAY[@]}"; do'), t({ "", "\t\t" }),
    t('echo "[$i] ${HASH_ARRAY[$i]}"'), t({ "", "\t" }),
    t("done"), t({ "", "}", "" }),
    t('echo "Enter directory to deduplicate:"'), t({ "", "" }),
    t("read -r DIR"), t({ "", "" }),
    t('[[ -d "$DIR" ]] || { echo "Directory not found!"; exit 1; }'), t({ "", "" }),
    t('deduplicate "$DIR"'), t({ "", "" }),
    t("dump_hashes"),
  }),

    s("bsplit_file", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("FNAME=\"\""), t({ "", "" }),
    t("LEN="), i(1, "10"), t({ "", "" }),
    t("TYPE=\""), i(2, "line"), t("\"  # line or size"), t({ "", "" }),
    t("OPT_ERROR=0"), t({ "", "" }),
    t("set -f  # Disable pathname expansion"), t({ "", "" }),
    t({ "", "function determine_type_of_file() {", "\t" }),
    t('local FILE="$1"'), t({ "", "\t" }),
    t([[file -b "$FILE" | grep -q "ASCII text"]]), t({ "", "\t" }),
    t("if [[ $? -eq 0 ]]; then"), t({ "", "\t\t" }),
    t('echo "✅ ASCII file - continuing"'), t({ "", "\t" }),
    t("else"), t({ "", "\t\t" }),
    t('echo "❌ Not an ASCII file, perhaps binary?"'), t({ "", "\t" }),
    t("fi"), t({ "", "}", "" }),
    t({ "", "function write_to_file() {", "\t" }),
    t('local B_FNAME="$1"'), t({ "", "\t" }),
    t('printf "%b" "${BUFFER}" > "${B_FNAME}.${F_CNT}"'), t({ "", "\t" }),
    t('echo "Wrote buffer to file: ${B_FNAME}.${F_CNT}"'), t({ "", "}", "" }),
    t({ "", "function read_and_split_by_line() {", "\t" }),
    t('local B_FNAME="$1"'), t({ "", "\t" }),
    t("local L_CNT=0 F_CNT=0"), t({ "", "\t" }),
    t('local BUFFER=""'), t({ "", "\t" }),
    t("while IFS= read -r LINE; do"), t({ "", "\t\t" }),
    t('BUFFER+="${LINE}\\n"'), t({ "", "\t\t" }),
    t("L_CNT=$(( L_CNT + 1 ))"), t({ "", "\t\t" }),
    t("if [[ $L_CNT -eq $LEN ]]; then"), t({ "", "\t\t\t" }),
    t("F_CNT=$(( F_CNT + 1 ))"), t({ "", "\t\t\t" }),
    t('write_to_file "$B_FNAME" "$F_CNT" "$BUFFER"'), t({ "", "\t\t\t" }),
    t("L_CNT=0"), t({ "", "\t\t\t" }),
    t('BUFFER=""'), t({ "", "\t\t" }),
    t("fi"), t({ "", "\t" }),
    t('done < "$B_FNAME"'), t({ "", "" }),
    t('if [[ -n "$BUFFER" ]]; then'), t({ "", "\t\t" }),
    t("F_CNT=$(( F_CNT + 1 ))"), t({ "", "\t\t" }),
    t('write_to_file "$B_FNAME" "$F_CNT" "$BUFFER"'), t({ "", "\t" }),
    t("fi"), t({ "", "}", "" }),
    t({ "", "function read_and_write_by_size() {", "\t" }),
    t('local B_FNAME="$1"'), t({ "", "\t" }),
    t("local L_CNT=0 F_CNT=0"), t({ "", "\t" }),
    t('local BUFFER=""'), t({ "", "\t" }),
    t("PAGESIZE=$(getconf PAGESIZE)"), t({ "", "\t" }),
    t("while IFS= read -n $PAGESIZE LINE; do"), t({ "", "\t\t" }),
    t('BUFFER+="$LINE"'), t({ "", "\t\t" }),
    t("L_CNT=$(( L_CNT + 1 ))"), t({ "", "\t\t" }),
    t("if [[ $L_CNT -eq $LEN ]]; then"), t({ "", "\t\t\t" }),
    t("F_CNT=$(( F_CNT + 1 ))"), t({ "", "\t\t\t" }),
    t('write_to_file "$B_FNAME" "$F_CNT" "$BUFFER"'), t({ "", "\t\t\t" }),
    t("L_CNT=0"), t({ "", "\t\t\t" }),
    t('BUFFER=""'), t({ "", "\t\t" }),
    t("fi"), t({ "", "\t" }),
    t('done < "$B_FNAME"'), t({ "", "" }),
    t('if [[ -n "$BUFFER" ]]; then'), t({ "", "\t\t" }),
    t("F_CNT=$(( F_CNT + 1 ))"), t({ "", "\t\t" }),
    t('write_to_file "$B_FNAME" "$F_CNT" "$BUFFER"'), t({ "", "\t" }),
    t("fi"), t({ "", "}", "" }),
    t({ "", "# 🔹 Option Parsing", "\t" }),
    t('while getopts ":i:l:t:" opt; do'), t({ "", "\t" }),
    t("case $opt in"), t({ "", "\t\t" }),
    t("i)"), t({ "", "\t\t\t" }),
    t('FNAME="$OPTARG"'), t({ "", "\t\t\t" }),
    t('if [[ ! -e "$FNAME" || ! -f "$FNAME" ]]; then'), t({ "", "\t\t\t\t" }),
    t('echo "ERROR: Input file does not exist or is not a file" >&2'), t({ "", "\t\t\t\t" }),
    t("OPT_ERROR+=1"), t({ "", "\t\t\t" }),
    t("fi"), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t("t)"), t({ "", "\t\t\t" }),
    t('TYPE="$OPTARG"'), t({ "", "\t\t\t" }),
    t('if [[ "$TYPE" != "line" && "$TYPE" != "size" ]]; then'), t({ "", "\t\t\t\t" }),
    t('echo "ERROR: -t must be line or size" >&2'), t({ "", "\t\t\t\t" }),
    t("OPT_ERROR+=1"), t({ "", "\t\t\t" }),
    t("fi"), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t("l)"), t({ "", "\t\t\t" }),
    t('LEN="$OPTARG"'), t({ "", "\t\t\t" }),
    t('if [[ $LEN -le 0 ]]; then'), t({ "", "\t\t\t\t" }),
    t('echo "ERROR: -l must be > 0" >&2'), t({ "", "\t\t\t\t" }),
    t("OPT_ERROR+=1"), t({ "", "\t\t\t" }),
    t("fi"), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t("\\?)"), t({ "", "\t\t\t" }),
    t('echo "Invalid option: -$OPTARG" >&2'), t({ "", "\t\t\t" }),
    t("OPT_ERROR+=1"), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t(":)"), t({ "", "\t\t\t" }),
    t('echo "Option -$OPTARG requires an argument." >&2'), t({ "", "\t\t\t" }),
    t("OPT_ERROR+=1"), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t("esac"), t({ "", "" }),
    t("done"), t({ "", "" }),
    t('if [[ -z "$FNAME" ]]; then'), t({ "", "\t" }),
    t('echo "ERROR: -i input parameter required" >&2'), t({ "", "\t" }),
    t("OPT_ERROR+=1"), t({ "", "fi", "" }),
    t('if [[ $OPT_ERROR -ne 0 ]]; then'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('determine_type_of_file "$FNAME"'), t({ "", "" }),
    t('if [[ "$TYPE" == "size" ]]; then'), t({ "", "\t" }),
    t('read_and_write_by_size "$FNAME"'), t({ "", "else", "\t" }),
    t('read_and_split_by_line "$FNAME"'), t({ "", "fi", "" }),
    t("exit 0"),
  }),

  s("binsert_file", {
  t("#!/usr/bin/env bash"), t({ "", "" }),
  t('INAME="'), i(1, "input.txt"), t('"'), t({ "", "" }),
  t('ONAME="'), i(2, "block.txt"), t('"'), t({ "", "" }),
  t('FNAME="'), i(3, "output.txt"), t('"'), t({ "", "" }),
  t('WHERE="'), i(4, ""), t('"  # Line number to insert after (leave empty to append)'), t({ "", "" }),
  t("OPT_ERROR=0"), t({ "", "" }),
  t("TMPFILE1=$(mktemp)"), t({ "", "" }),
  t("trap 'rm -f \"$TMPFILE1\"' EXIT  # Cleanup temp on exit/error"), t({ "", "" }),
  t({ "", "function determine_type_of_file() {", "\t" }),
  t('local FILE="$1"'), t({ "", "\t" }),
  t('if file -b "$FILE" | grep -q "ASCII text"; then'), t({ "", "\t\t" }),
  t('echo "✅ ASCII file - continuing"'), t({ "", "\t" }),
  t("else"), t({ "", "\t\t" }),
  t('echo "❌ Not an ASCII file, perhaps binary?"'), t({ "", "\t" }),
  t("fi"), t({ "", "}", "" }),
  t({ "", "function open_input_and_insert() {", "\t" }),
  t('local INPUT="$1"'), t({ "", "\t" }),
  t('local N_BLOCK="$2"'), t({ "", "\t" }),
  t('local FINAL_OUTPUT="$3"'), t({ "", "\t" }),
  t('local PTR="$4"'), t({ "", "\t" }),
  t("local CTR=0"), t({ "", "\t" }),
  t({ "", "\t# If position not set, just append", "\t" }),
  t('if [[ -z "$PTR" ]]; then'), t({ "", "\t\t" }),
  t('cat "$INPUT" "$N_BLOCK" > "$FINAL_OUTPUT"'), t({ "", "\t\t" }),
  t("return"), t({ "", "\t" }),
  t("fi"), t({ "", "\t" }),
  t('> "$TMPFILE1"  # Clear temp file'), t({ "", "\t" }),
  t('while IFS= read -r LINE; do'), t({ "", "\t\t" }),
  t('if [[ $CTR -eq $PTR ]]; then'), t({ "", "\t\t\t" }),
  t('cat "$N_BLOCK" >> "$TMPFILE1"'), t({ "", "\t\t" }),
  t("fi"), t({ "", "\t\t" }),
  t('echo "$LINE" >> "$TMPFILE1"'), t({ "", "\t\t" }),
  t("CTR=$(( CTR + 1 ))"), t({ "", "\t" }),
  t('done < "$INPUT"'), t({ "", "\t" }),
  t('mv "$TMPFILE1" "$FINAL_OUTPUT"'), t({ "", "}", "" }),
  t({ "", "# 🔹 Option Parsing", "\t" }),
  t('while getopts ":i:o:w:f:" opt; do'), t({ "", "\t" }),
  t("case $opt in"), t({ "", "\t\t" }),
  t("i)"), t({ "", "\t\t\t" }),
  t('INAME="$OPTARG"'), t({ "", "\t\t\t" }),
  t('[[ ! -f "$INAME" ]] && { echo "ERROR: Input file missing" >&2; OPT_ERROR+=1; }'), t({ "", "\t\t\t" }),
  t(";;"), t({ "", "\t\t" }),
  t("o)"), t({ "", "\t\t\t" }),
  t('ONAME="$OPTARG"'), t({ "", "\t\t" }),
  t(";;"), t({ "", "\t\t" }),
  t("f)"), t({ "", "\t\t\t" }),
  t('FNAME="$OPTARG"'), t({ "", "\t\t" }),
  t(";;"), t({ "", "\t\t" }),
  t("w)"), t({ "", "\t\t\t" }),
  t('WHERE="$OPTARG"'), t({ "", "\t\t\t" }),
  t('[[ ! "$WHERE" =~ ^[0-9]+$ ]] && { echo "ERROR: -w must be non-negative integer" >&2; OPT_ERROR+=1; }'), t({ "", "\t\t\t" }),
  t(";;"), t({ "", "\t\t" }),
  t("\\?)"), t({ "", "\t\t\t" }),
  t('echo "Invalid option: -$OPTARG" >&2'), t({ "", "\t\t\t" }),
  t("OPT_ERROR+=1"), t({ "", "\t\t" }),
  t(";;"), t({ "", "\t\t" }),
  t(":)"), t({ "", "\t\t\t" }),
  t('echo "Option -$OPTARG requires an argument." >&2'), t({ "", "\t\t\t" }),
  t("OPT_ERROR+=1"), t({ "", "\t\t" }),
  t(";;"), t({ "", "\t\t" }),
  t("esac"), t({ "", "done", "" }),
  t({ "", "# 🔹 Sanity Checks", "\t" }),
  t('[[ -z "$INAME" ]] && { echo "ERROR: -i required" >&2; OPT_ERROR+=1; }'), t({ "", "" }),
  t('[[ -z "$ONAME" ]] && { echo "ERROR: -o required" >&2; OPT_ERROR+=1; }'), t({ "", "" }),
  t('[[ -z "$FNAME" ]] && { echo "ERROR: -f required" >&2; OPT_ERROR+=1; }'), t({ "", "" }),
  t('[[ $OPT_ERROR -ne 0 ]] && exit 1'), t({ "", "" }),
  t('determine_type_of_file "$INAME"'), t({ "", "" }),
  t('open_input_and_insert "$INAME" "$ONAME" "$FNAME" "$WHERE"'), t({ "", "" }),
  t("exit 0"),
}),

  s("bdata_maker", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Configuration"), t({ "", "" }),
    t("N_FILES="), i(1, "3"), t({ "", "" }),
    t('TYPE="'), i(2, "binary"), t('"  # binary or text'), t({ "", "" }),
    t('DIRECTORY="'), i(3, "qa-data"), t('"'), t({ "", "" }),
    t('NAME="'), i(4, "garbage"), t('"'), t({ "", "" }),
    t('UNIT="'), i(5, "M"), t('"  # M, K, or G'), t({ "", "" }),
    t("OPT_ERROR=0"), t({ "", "" }),
    t("mkdir -p \"$DIRECTORY\""), t({ "", "" }),
    t({ "", "# 🔹 Safe & fast random range generator" }),
    t("get_random_range() {"), t({ "", "\t" }),
    t("local min=$1 max=$2"), t({ "", "\t" }),
    t('echo $(( RANDOM % (max - min + 1) + min ))'), t({ "", "}", "" }),
    t({ "", "# 🔹 Create binary files" }),
    t("create_binary_files() {"), t({ "", "\t" }),
    t("local num_files=$1 min_size=$2 max_size=$3"), t({ "", "\t" }),
    t("for (( i=0; i<num_files; i++ )); do"), t({ "", "\t\t" }),
    t("local size=$(get_random_range \"$min_size\" \"$max_size\")"), t({ "", "\t\t" }),
    t([[echo "Creating binary: ${NAME}${i}.bin (${size}${UNIT})"]]), t({ "", "\t\t" }),
    t('dd if=/dev/urandom of="${DIRECTORY}/${NAME}${i}.bin" bs=1${UNIT} count="$size" status=none'), t({ "", "\t" }),
    t("done"), t({ "", "}", "" }),
    t({ "", "# 🔹 Create text files" }),
    t("create_text_files() {"), t({ "", "\t" }),
    t("local num_files=$1 min_size=$2 max_size=$3"), t({ "", "\t" }),
    t("local tmp_txt=$(mktemp)"), t({ "", "\t" }),
    t('tr -dc "a-zA-Z0-9 \\n" < /dev/urandom | head -c $((max_size * 1024 * 1024)) > "$tmp_txt"'), t({ "", "\t" }),
    t("for (( i=0; i<num_files; i++ )); do"), t({ "", "\t\t" }),
    t("local start=$(get_random_range \"$min_size\" \"$max_size\")"), t({ "", "\t\t" }),
    t("local end=$(get_random_range \"$start\" \"$max_size\")"), t({ "", "\t\t" }),
    t("local count=$(( end - start ))"), t({ "", "\t\t" }),
    t([[echo "Creating text: ${NAME}${i}.txt (offset ${start}${UNIT}, len ${count}${UNIT})"]]), t({ "", "\t\t" }),
    t('dd if="$tmp_txt" of="${DIRECTORY}/${NAME}${i}.txt" bs=1${UNIT} skip="$start" count="$count" status=none'), t({ "", "\t" }),
    t("done"), t({ "", "\t" }),
    t("rm -f \"$tmp_txt\""), t({ "", "}", "" }),
    t({ "", "# 🔹 Option Parsing" }),
    t('while getopts ":t:n:l:u:" opt; do'), t({ "", "\t" }),
    t("case $opt in"), t({ "", "\t\t" }),
    t("t)"), t({ "", "\t\t\t" }),
    t('TYPE="$OPTARG"'), t({ "", "\t\t\t" }),
    t('[[ "$TYPE" != "binary" && "$TYPE" != "text" ]] && { echo "ERROR: -t must be binary or text" >&2; OPT_ERROR+=1; }'), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t("n)"), t({ "", "\t\t\t" }),
    t('N_FILES="$OPTARG"'), t({ "", "\t\t\t" }),
    t('[[ $N_FILES -le 0 ]] && { echo "ERROR: -n must be > 0" >&2; OPT_ERROR+=1; }'), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t("l)"), t({ "", "\t\t\t" }),
    t('LOWER="$OPTARG"'), t({ "", "\t\t\t" }),
    t('[[ $LOWER -le 0 ]] && { echo "ERROR: -l must be > 0" >&2; OPT_ERROR+=1; }'), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t("u)"), t({ "", "\t\t\t" }),
    t('UPPER="$OPTARG"'), t({ "", "\t\t\t" }),
    t('[[ $UPPER -le 0 ]] && { echo "ERROR: -u must be > 0" >&2; OPT_ERROR+=1; }'), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t("\\?)"), t({ "", "\t\t\t" }),
    t('echo "Invalid option: -$OPTARG" >&2'), t({ "", "\t\t\t" }),
    t("OPT_ERROR+=1"), t({ "", "\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t(":)"), t({ "", "\t\t\t" }),
    t('echo "Option -$OPTARG requires an argument." >&2'), t({ "", "\t\t\t" }),
    t("OPT_ERROR+=1"), t({ "", "\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t("esac"), t({ "", "done", "" }),
    t({ "", "# 🔹 Validation & Execution" }),
    t('[[ $OPT_ERROR -ne 0 ]] && exit 1'), t({ "", "" }),
    t('case "$TYPE" in'), t({ "", "\t" }),
    t("binary)"), t({ "", "\t\t" }),
    t('create_binary_files "$N_FILES" "$LOWER" "$UPPER"'), t({ "", "\t\t" }),
    t(";;"), t({ "", "\t" }),
    t("text)"), t({ "", "\t\t" }),
    t('create_text_files "$N_FILES" "$LOWER" "$UPPER"'), t({ "", "\t\t" }),
    t(";;"), t({ "", "\t" }),
    t("*)"), t({ "", "\t\t" }),
    t('echo "ERROR: Unknown type. Use binary or text." >&2'), t({ "", "\t\t" }),
    t("exit 1"), t({ "", "\t" }),
    t("esac"), t({ "", "" }),
    t('echo "✅ DONE! Files created in $DIRECTORY"'), t({ "", "" }),
    t("exit 0"),
  }),

    -- 🔹 1. Recursive function loop
  s("bloop_recursive", {
    t("function recursive_func() {"), t({ "", "\t" }),
    t('echo -n "Press anything to continue loop: "'), t({ "", "\t" }),
    t("read -r input"), t({ "", "\t" }),
    t("recursive_func"), t({ "", "}", "" }),
    t("recursive_func"), t({ "", "" }),
    t("exit 0"),
  }),

  -- 🔹 2. Infinite `for` loop
  s("bloop_for_inf", {
    t("for (( ; ; )); do"), t({ "", "\t" }),
    t('echo "'), i(1, "Shall run forever"), t('"'), t({ "", "\t" }),
    t("sleep "), i(2, "1"), t({ "", "done", "" }),
    t("exit 0"),
  }),

  -- 🔹 3. `while :` with break condition
  s("bloop_while_break", {
    t("EXIT_PLEASE="), i(1, "0"), t({ "", "" }),
    t("while :; do"), t({ "", "\t" }),
    t('echo "Press CTRL+C to stop..."'), t({ "", "\t" }),
    t("sleep "), i(2, "1"), t({ "", "\t" }),
    t('if [[ $EXIT_PLEASE -ne 0 ]]; then'), t({ "", "\t\t" }),
    t("break"), t({ "", "\t" }),
    t("fi"), t({ "", "done", "" }),
    t("exit 0"),
  }),

  -- 🔹 4. Infinite `until` loop (never satisfied)
  s("bloop_until_inf", {
    t("EXIT_PLEASE="), i(1, "0"), t({ "", "" }),
    t("# EXIT_PLEASE is 0, so until will never be satisfied"), t({ "", "" }),
    t("until [[ $EXIT_PLEASE -ne 0 ]]; do"), t({ "", "\t" }),
    t('echo "Press CTRL+C to stop..."'), t({ "", "\t" }),
    t("sleep "), i(2, "1"), t({ "", "done", "" }),
    t("exit 0"),
  }),

  -- 🔹 5. `until` loop with counter
  s("bloop_until_ctr", {
    t("EXIT_PLEASE="), i(1, "0"), t({ "", "" }),
    t("INC="), i(2, "0"), t({ "", "" }),
    t("until [[ $EXIT_PLEASE -ne 0 ]]; do"), t({ "", "\t" }),
    t('echo "Boo $INC" > /dev/null'), t({ "", "\t" }),
    t("INC=$(( INC + 1 ))"), t({ "", "\t" }),
    t("sleep "), i(3, "1"), t({ "", "done", "" }),
    t("exit 0"),
  }),

    -- 🔹 1. File Name Sanitization
  s("bsanitize_fname", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('FILE_NAME="${1:-'), i(1, "my_file (1).txt"), t('}"'), t({ "", "" }),
    t({ "", "# 🔹 Step 1: Strip underscores (optional)" }),
    t('FILE_NAME_CLEAN="${FILE_NAME//_/}"'), t({ "", "" }),
    t({ "", "# 🔹 Step 2: Remove specific pattern (e.g., two chars)" }),
    t("# ⚠️  Original: sed 's/..//g' removes PAIRS of chars"), t({ "", "" }),
    t('FILE_NAME_CLEAN=$(sed \'s/'), i(2, ".."), t('//g\' <<< "$FILE_NAME_CLEAN")'), t({ "", "" }),
    t({ "", "# 🔹 Step 3: Replace spaces with underscores" }),
    t('FILE_NAME_CLEAN="${FILE_NAME_CLEAN// /_}"'), t({ "", "" }),
    t({ "", "# 🔹 Step 4: Keep only alphanumeric, underscore, dot" }),
    t('FILE_NAME_CLEAN=$(echo "$FILE_NAME_CLEAN" | sed \'s/[^a-zA-Z0-9_.]//g\')'), t({ "", "" }),
    t({ "", "# 🔹 Check if file exists" }),
    t('if [[ -f "$FILE_NAME_CLEAN" ]]; then'), t({ "", "\t" }),
    t('echo "✅ File exists: $FILE_NAME_CLEAN"'), t({ "", "\t" }),
    t('ls -l "$FILE_NAME_CLEAN"'), t({ "", "else", "\t" }),
    t('echo "❌ File not found: $FILE_NAME_CLEAN" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi" }),
  }),

  -- 🔹 2. Email Validation (regex)
  s("bvalidate_email", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('EMAIL="${1:-'), i(1, "user@example.com"), t('}"'), t({ "", "" }),
    t({ "", "# 🔹 Basic RFC 5322-ish regex (simplified)" }),
    t("# ✅ Allows: letters, digits, dots, underscores, hyphens in local part"), t({ "", "" }),
    t('if [[ "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$ ]]; then'), t({ "", "\t" }),
    t('echo "✅ $EMAIL is valid"'), t({ "", "else", "\t" }),
    t('echo "❌ $EMAIL is NOT valid" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi" }),
  }),

  -- 🔹 3. IPv4 Address Validation (octet-by-octet)
  s("bvalidate_ipv4", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('IP_ADDR="${1:-'), i(1, "192.168.1.1"), t('}"'), t({ "", "" }),
    t({ "", "# 🔹 Validate IPv4: 4 octets, 0-255, no extra chars" }),
    t('if [[ "$IP_ADDR" =~ ^([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})$ ]]; then'), t({ "", "\t" }),
    t("for octet in \"${BASH_REMATCH[1]}\" \"${BASH_REMATCH[2]}\" \"${BASH_REMATCH[3]}\" \"${BASH_REMATCH[4]}\"; do"), t({ "", "\t\t" }),
    t('if [[ $octet -gt 255 ]]; then'), t({ "", "\t\t\t" }),
    t('echo "❌ Octet $octet > 255" >&2'), t({ "", "\t\t\t" }),
    t("exit 1"), t({ "", "\t\t" }),
    t("fi"), t({ "", "\t" }),
    t("done"), t({ "", "\t" }),
    t('echo "✅ $IP_ADDR is valid"'), t({ "", "else", "\t" }),
    t('echo "❌ $IP_ADDR is NOT a valid IPv4 address" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi" }),
  }),

  -- 🔹 Bonus: Generic regex validator template
  s("bregex_check", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('INPUT="${1:-'), i(1, "value_to_check"), t('}"'), t({ "", "" }),
    t('PATTERN="'), i(2, "^[a-zA-Z0-9]+$"), t('"'), t({ "", "" }),
    t('if [[ "$INPUT" =~ $PATTERN ]]; then'), t({ "", "\t" }),
    t('echo "✅ Match"'), t({ "", "else", "\t" }),
    t('echo "❌ No match" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi" }),
  }),

    s("bselect_menu", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Recursive select-based menu"), t({ "", "" }),
    t('TITLE="'), i(1, "Select file menu"), t('"'), t({ "", "" }),
    t('PROMPT="'), i(2, "Pick a task:"), t('"'), t({ "", "" }),
    t('OPTIONS=('), i(3, '"list" "delete" "modify" "create"'), t(')'), t({ "", "" }),
    t({ "", "# 🔹 List files submenu" }),
    t("function list_files() {"), t({ "", "\t" }),
    t('PS3="Choose a file or type \\"back\\" to return: "'), t({ "", "\t" }),
    t('select OPT in *; do'), t({ "", "\t\t" }),
    t('# ⚠️  REPLY is numeric; "back" sets REPLY to empty'), t({ "", "\t\t" }),
    t('if [[ -z "$REPLY" ]]; then'), t({ "", "\t\t\t" }),
    t('if [[ "$OPT" == "back" ]]; then'), t({ "", "\t\t\t\t" }),
    t("return"), t({ "", "\t\t\t" }),
    t("fi"), t({ "", "\t\t" }),
    t('elif [[ $REPLY -ge 1 && $REPLY -le $(ls -1 | wc -l) ]]; then'), t({ "", "\t\t\t" }),
    t('echo "✅ Selected: $OPT"'), t({ "", "\t\t\t" }),
    t('read -rp "Press Enter to continue..."'), t({ "", "\t\t" }),
    t("else"), t({ "", "\t\t\t" }),
    t('echo "❌ Invalid choice" >&2'), t({ "", "\t\t" }),
    t("fi"), t({ "", "\t" }),
    t("done"), t({ "", "}", "" }),
    t({ "", "# 🔹 Main menu" }),
    t("function main_menu() {"), t({ "", "\t" }),
    t('echo -e "\\n=== $TITLE ==="'), t({ "", "\t" }),
    t('PS3="$PROMPT "'), t({ "", "\t" }),
    t('select OPT in "${OPTIONS[@]}" "quit"; do'), t({ "", "\t\t" }),
    t("case $REPLY in"), t({ "", "\t\t\t" }),
    t("1)"), t({ "", "\t\t\t\t" }),
    t("list_files"), t({ "", "\t\t\t\t" }),
    t("# 🔁 Regenerate menu after submenu"), t({ "", "\t\t\t\t" }),
    t("main_menu"), t({ "", "\t\t\t\t" }),
    t(";;"), t({ "", "\t\t\t" }),
    t("2)"), t({ "", "\t\t\t\t" }),
    t('echo "🗑️  Delete: ${OPT}"  # TODO: implement'), t({ "", "\t\t\t\t" }),
    t(";;"), t({ "", "\t\t\t" }),
    t("3)"), t({ "", "\t\t\t\t" }),
    t('echo "✏️  Modify: ${OPT}"  # TODO: implement'), t({ "", "\t\t\t\t" }),
    t(";;"), t({ "", "\t\t\t" }),
    t("4)"), t({ "", "\t\t\t\t" }),
    t('echo "➕ Create: ${OPT}"  # TODO: implement'), t({ "", "\t\t\t\t" }),
    t(";;"), t({ "", "\t\t\t" }),
    t("5)"), t({ "", "\t\t\t\t" }),
    t('echo "👋 Exiting!"'), t({ "", "\t\t\t\t" }),
    t("break"), t({ "", "\t\t\t\t" }),
    t(";;"), t({ "", "\t\t\t" }),
    t("*)"), t({ "", "\t\t\t\t" }),
    t('echo "❌ Invalid option. Try 1-5." >&2'), t({ "", "\t\t\t\t" }),
    t("continue"), t({ "", "\t\t\t" }),
    t("esac"), t({ "", "\t" }),
    t("done"), t({ "", "}", "" }),
    t({ "", "# 🔹 Safety: limit recursion depth" }),
    t('if [[ "${BASH_LINENO[0]:-0}" -gt 1000 ]]; then'), t({ "", "\t" }),
    t('echo "⚠️  Recursion limit reached" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t("# ▶️  Start the menu"), t({ "", "" }),
    t("main_menu"), t({ "", "" }),
    t("exit 0"),
  }),

    -- 🔹 1. Basic signal handler (SIGINT/SIGTERM)
  s("btrap_basic", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Graceful shutdown with trap"), t({ "", "" }),
    t("function cleanup() {"), t({ "", "\t" }),
    t('echo "🧹 Cleaning up..."'), t({ "", "\t" }),
    t("# 🔹 Add your cleanup logic here: kill children, remove temp files, etc."), t({ "", "\t" }),
    t("exit "), i(1, "0"), t({ "", "}", "" }),
    t("function setup() {"), t({ "", "\t" }),
    t('trap "cleanup" SIGINT SIGTERM'), t({ "", "\t" }),
    t('echo "✅ PID of script is $$"'), t({ "", "}", "" }),
    t("setup"), t({ "", "" }),
    t("# 🔹 Main loop (noop)"), t({ "", "" }),
    t("while :; do"), t({ "", "\t" }),
    t("sleep "), i(2, "1"), t({ "", "done", "" }),
    t("exit 0"),
  }),

   -- 🔹 2. Atomic lock file via hard link
  s("btrap_lockfile", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Single-instance lock using atomic hard link"), t({ "", "" }),
    t('LOCKFILE="'), i(1, "/tmp/mylock"), t('"'), t({ "", "" }),
    t("function setup() {"), t({ "", "\t" }),
    t('local TMPFILE="${LOCKFILE}.$$"'), t({ "", "\t" }),
    t('echo "$$" > "$TMPFILE"'), t({ "", "\t" }),
    t("# 🔹 Atomic lock: hard link succeeds only if LOCKFILE doesn't exist"), t({ "", "\t" }),
    t('if ln "$TMPFILE" "$LOCKFILE" 2>/dev/null; then'), t({ "", "\t\t" }),
    t('echo " Lock acquired (PID $$)"'), t({ "", "\t" }),
    t("else"), t({ "", "\t\t" }),
    t('echo " Locked by PID $(<$LOCKFILE)" >&2'), t({ "", "\t\t" }),
    t('rm -f "$TMPFILE"'), t({ "", "\t\t" }),
    t("exit 1"), t({ "", "\t" }),
    t("fi"), t({ "", "\t" }),
    t("#   SIGKILL cannot be trapped — removed from trap"), t({ "", "\t" }),
    t('trap \'rm -f "$TMPFILE" "$LOCKFILE"\' SIGINT SIGTERM EXIT'), t({ "", "}", "" }),
    t("setup"), t({ "", "" }),
    t('echo " Door was left unlocked (critical section)"'), t({ "", "" }),
    t("# 🔹 Your critical code here"), t({ "", "" }),
    t("sleep "), i(2, "10"), t({ "", "" }),
    t("exit 0"),
  }),

  
  -- 🔹 Bonus: Generic trap template
  s("btrap_template", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("function cleanup() {"), t({ "", "\t" }),
    t('echo "🧹 Cleanup: $@"'), t({ "", "\t" }),
    t("# 🔹 Your cleanup logic here", "", ""),
    t("exit ${1:-0}", "", ""),
    t("}", "", ""),
    t("# 🔹 Register signals (space-separated)", "", ""),
    t('trap \'cleanup "SIGINT"\' SIGINT', "", ""),
    t('trap \'cleanup "SIGTERM"\' SIGTERM', "", ""),
    t('trap \'cleanup "EXIT"\' EXIT', "", ""),
    t({ "", "# 🔹 Main script", "" }),
    t('echo "✅ Script started (PID $$)"', "", ""),
    i(1, "# Your code here"), t({ "", "", "exit 0" }),
  }),

    s("btrap_timer", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Execute command with timeout via SIGALRM"), t({ "", "" }),
    t("SUBPID=0"), t({ "", "" }),
    t("function clean_up() {"), t({ "", "\t" }),
    t('trap - SIGALRM  # Reset trap'), t({ "", "\t" }),
    t('kill -SIGALRM "$SUBPID" 2>/dev/null'), t({ "", "\t" }),
    t('kill "$!" 2>/dev/null  # Kill backgrounded command'), t({ "", "}", "" }),
    t("function func_timer() {"), t({ "", "\t" }),
    t('local TIMEOUT=$1'), t({ "", "\t" }),
    t('trap "clean_up" SIGALRM'), t({ "", "\t" }),
    t('( sleep "$TIMEOUT" && kill -SIGALRM $$ ) &'), t({ "", "\t" }),
    t('TIMER_PID=$!'), t({ "", "}", "" }),
    t({ "", "# 🔹 Usage: ./script.sh <timeout_seconds> command [args...]" }),
    t('if [[ $# -lt 2 ]]; then'), t({ "", "\t" }),
    t('echo "Usage: $0 <timeout> <command> [args...]" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t("TIMEOUT=$1; shift"), t({ "", "" }),
    t('func_timer "$TIMEOUT"'), t({ "", "" }),
    t("SUBPID=$!"), t({ "", "" }),
    t('trap "clean_up" SIGALRM SIGINT'), t({ "", "" }),
    t("# 🔹 Execute the command"), t({ "", "" }),
    t('"$@" &'), t({ "", "" }),
    t("CMD_PID=$!"), t({ "", "" }),
    t("wait $CMD_PID"), t({ "", "" }),
    t("EXIT_CODE=$?"), t({ "", "" }),
    t("# 🔹 Cleanup timer"), t({ "", "" }),
    t("kill -SIGALRM $SUBPID 2>/dev/null"), t({ "", "" }),
    t("wait $SUBPID 2>/dev/null"), t({ "", "" }),
    t("exit $EXIT_CODE"),
  }),

    -- 🔹 1. FIFO Master / Producer
  s("bfifo_master", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('FIFO_FILE="'), i(1, "/tmp/work_queue_fifo"), t('"'), t({ "", "" }),
    t("NUM_WORKERS="), i(2, "5"), t({ "", "" }),
    t('WORKER_SCRIPT="'), i(3, "worker.sh"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Create FIFO (safe idempotent)" }),
    t('[[ -p "$FIFO_FILE" ]] || mkfifo -m 666 "$FIFO_FILE"'), t({ "", "" }),
    t({ "", "# 🔹 Spawn background workers" }),
    t("for (( I=0; I<NUM_WORKERS; I++ )); do"), t({ "", "\t" }),
    t('bash "$WORKER_SCRIPT" "$I" &'), t({ "", "done", "" }),
    t({ "", "# 🔹 Send tasks to FIFO (blocks until worker reads)" }),
    t("for (( I=0; I<NUM_WORKERS; I++ )); do"), t({ "", "\t" }),
    t('echo "$I" > "$FIFO_FILE"'), t({ "", "done", "" }),
    t({ "", "# 🔹 Wait for workers to finish" }),
    t("sleep "), i(4, "5"), t({ "", "" }),
    t('rm -f "$FIFO_FILE"  # FIFO is a file, not a directory'), t({ "", "" }),
    t("exit 0"),
  }),

  -- 🔹 2. FIFO Worker / Consumer
  s("bfifo_worker", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('FIFO_FILE="'), i(5, "/tmp/work_queue_fifo"), t('"'), t({ "", "" }),
    t("WORKER_ID=$1"), t({ "", "" }),
    t('echo "✅ Worker $WORKER_ID started"'), t({ "", "" }),
    t({ "", "# 🔹 Read loop: opens FIFO each iteration" }),
    t("while :; do"), t({ "", "\t" }),
    t('read -r BUFFER < "$FIFO_FILE" || continue'), t({ "", "\t" }),
    t('if [[ -n "$BUFFER" ]]; then'), t({ "", "\t\t" }),
    t('echo "📥 Worker $WORKER_ID received: $BUFFER"'), t({ "", "\t\t" }),
    t("# 🔹 Process task here"), t({ "", "\t\t" }),
    t("exit 0  # ✅ Exit with 0 on success"), t({ "", "\t" }),
    t("fi"), t({ "", "done", "" }),
    t("exit 0"),
  }),

  -- 🔹 3. Simple Infinite `for` Loop
  s("bloop_inf_for", {
    t("for (( ; ; )); do"), t({ "", "\t" }),
    t("sleep "), i(6, "1"), t({ "", "done", "" }),
    t("exit 0"),
  }),

  

  -- 🔹 Bonus: Generic Substring Helper
  s("substr", {
    t('echo "${'), i(1, "VAR"), t(":"), i(2, "0"), t(":"), i(3, "3"), t('}"'),
  }),

    -- 🔹 1. Server Uptime Parser (robust)
  s("buptime_parse", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Parse uptime: handle 'X days' vs 'HH:MM' formats"), t({ "", "" }),
    t('UPTIME_RAW=$(uptime)'), t({ "", "" }),
    t('SERVER_UPTIME=$(echo "$UPTIME_RAW" | awk \'{print $3,$4}\' | sed \'s/,//\' | grep -i "day")'), t({ "", "" }),
    t('if [[ -z "$SERVER_UPTIME" ]]; then'), t({ "", "\t" }),
    t('# 🔹 Less than a day: extract only hours:minutes'), t({ "", "\t" }),
    t('SERVER_UPTIME=$(echo "$UPTIME_RAW" | awk \'{print $3}\' | sed \'s/,//\')'), t({ "", "\t" }),
    t('echo "⏱️  Uptime: $SERVER_UPTIME"'), t({ "", "else", "\t" }),
    t('echo "⏱️  Uptime: $SERVER_UPTIME"'), t({ "", "fi" }),
  }),

    -- 🔹 2. CPU Info Extractor via dmidecode
  s("bcpu_dmidecode", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Extract CPU details (requires root/sudo)"), t({ "", "" }),
    t('if [[ $EUID -ne 0 ]]; then'), t({ "", "\t" }),
    t('echo "⚠️  Please run with sudo" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Get all CPU handles" }),
    t('for HANDLE in $(dmidecode -t 4 | awk \'/Handle / {print $2}\'); do'), t({ "", "\t" }),
    t('echo "🔍 Processing $HANDLE"'), t({ "", "\t" }),
    t('dmidecode -t 4 | sed \'/Flags/,/Version/d\' | egrep -A20 "Handle ${HANDLE}" | \\'), t({ "", "\t\t" }),
    t('  grep -m 1 "Socket Designation" | grep -oE \'.{0,0}:.{0,18}\' | tr -d \':| \''), t({ "", "\t" }),
    t('dmidecode -t 4 | sed \'/Flags/,/Version/d\' | egrep -A20 "Handle ${HANDLE}" | \\'), t({ "", "\t\t" }),
    t('  grep -m 1 "Family" | grep -oE \'.{0,0}:.{0,18}\' | tr -d \':| \''), t({ "", "\t" }),
    t('dmidecode -t 4 | sed \'/Flags/,/Version/d\' | egrep -A20 "Handle ${HANDLE}" | \\'), t({ "", "\t\t" }),
    t('  grep -m 1 "Manufacturer" | grep -oE \'.{0,0}:.{0,18}\' | tr -d \':| \''), t({ "", "\t" }),
    t('dmidecode -t 4 | sed \'/Flags/,/Version/d\' | egrep -A20 "Handle ${HANDLE}" | \\'), t({ "", "\t\t" }),
    t('  grep -m 1 "Current Speed" | grep -oE \'.{0,0}:.{0,18}\' | tr -d \':| \''), t({ "", "\t" }),
    t('dmidecode -t 4 | sed \'/Flags/,/Version/d\' | egrep -A20 "Handle ${HANDLE}" | \\'), t({ "", "\t\t" }),
    t('  grep -m 1 "Voltage" | grep -oE \'.{0,0}:.{0,18}\' | tr -d \':| \''), t({ "", "\t" }),
    t('dmidecode -t 4 | sed \'/Flags/,/Version/d\' | egrep -A20 "Handle ${HANDLE}" | \\'), t({ "", "\t\t" }),
    t('  grep -m 1 "Core Count" | grep -oE \'.{0,0}:.{0,18}\' | tr -d \':| \''), t({ "", "\t" }),
    t("done"),
  }),

    -- 🔹 Bonus: Generic Ping Check Template
  s("bping_generic", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('HOST="'), i(1, "example.com"), t('"'), t({ "", "" }),
    t('TIMEOUT="'), i(2, "1"), t('"'), t({ "", "" }),
    t('if ping -q -c 1 -W "$TIMEOUT" "$HOST" >/dev/null 2>&1; then'), t({ "", "\t" }),
    t('echo "✅ $HOST is reachable"'), t({ "", "else", "\t" }),
    t('echo "❌ $HOST is unreachable" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi" }),
  }),

  -- 🔹 3. IPv4 Connectivity Check (8.8.8.8)
s("bping_ipv4", {
  t("#!/usr/bin/env bash"), t({ "", "" }),
  t("# 🔹 Quick IPv4 connectivity test"), t({ "", "" }),
  -- ✅ Кожна нода окремо в масиві:
  t('if ping -q -c 1 -W '), i(1, "1"), t(' '), i(2, "8.8.8.8"), t(' >/dev/null 2>&1; then'), t({ "", "\t" }),
  t('echo "✅ IPv4 is up"'), t({ "", "else", "\t" }),
  t('echo "❌ IPv4 is down" >&2'), t({ "", "\t" }),
  t("exit 1"), t({ "", "fi" }),
}),

-- 🔹 4. DNS/Network Check (google.com) 
s("bping_dns", {
  t("#!/usr/bin/env bash"), t({ "", "" }),
  t("# 🔹 DNS resolution + network connectivity test"), t({ "", "" }),
  -- ✅ Кожна нода окремо в масиві:
  t('if ping -q -c 1 -W '), i(1, "1"), t(' '), i(2, "google.com"), t(' >/dev/null 2>&1; then'), t({ "", "\t" }),
  t('echo "✅ The network is up"'), t({ "", "else", "\t" }),
  t('echo "❌ The network is down" >&2'), t({ "", "\t" }),
  t("exit 1"), t({ "", "fi" }),
}),

  s("buser_csv", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Bulk user creation from CSV"), t({ "", "" }),
    t("# Format: surname,name,username,department,password"), t({ "", "" }),
    
    t("# 🔹 Require root"), t({ "", "" }),
    t('if [[ $EUID -ne 0 ]]; then'), t({ "", "\t" }),
    t('echo "❌ Please run with sudo" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    
    t("# 🔹 Configuration"), t({ "", "" }),
    t('CSV_FILE="'), i(1, "/home/users.csv"), t('"'), t({ "", "" }),
    t('DEFAULT_SHELL="'), i(2, "/bin/bash"), t('"'), t({ "", "" }),
    t('HOME_BASE="'), i(3, "/home"), t('"'), t({ "", "" }),
    
    t({ "", "# 🔹 Validate CSV exists" }),
    t('if [[ ! -f "$CSV_FILE" ]]; then'), t({ "", "\t" }),
    t('echo "❌ CSV file not found: $CSV_FILE" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    
    t({ "", "# 🔹 Arrays for CSV columns" }),
    t("declare -a A_SURNAME A_NAME A_USERNAME A_DEPARTMENT A_PASSWORD"), t({ "", "" }),
    
    t({ "", "# 🔹 Read CSV (skip comments/empty lines)" }),
    t('while IFS=, read -r COL1 COL2 COL3 COL4 COL5 TRASH; do'), t({ "", "\t" }),
    t('[[ -z "$COL3" || "$COL1" =~ ^# ]] && continue'), t({ "", "\t" }),
    t('A_SURNAME+=("$COL1")'), t({ "", "\t" }),
    t('A_NAME+=("$COL2")'), t({ "", "\t" }),
    t('A_USERNAME+=("$COL3")'), t({ "", "\t" }),
    t('A_DEPARTMENT+=("$COL4")'), t({ "", "\t" }),
    t('A_PASSWORD+=("$COL5")'), t({ "", "done" }),
    t('  < "$CSV_FILE"'), t({ "", "" }),
    
    t({ "", "# 🔹 Create users" }),
    t('for idx in "${!A_USERNAME[@]}"; do'), t({ "", "\t" }),
    t('USERNAME="${A_USERNAME[$idx]}"'), t({ "", "\t" }),
    t('DEPT="${A_DEPARTMENT[$idx]}"'), t({ "", "\t" }),
    t('PASS="${A_PASSWORD[$idx]}"'), t({ "", "\t" }),
    t('HOME_DIR="'), rep(3), t('/${USERNAME}"'), t({ "", "\t" }),
    t({ "", "\t# Hash password via openssl (MD5-based crypt)" }),
    t('HASHED=$(printf "%s" "$PASS" | openssl passwd -1 -stdin)'), t({ "", "\t" }),
    t({ "", "\t# Create user (one-liner, no line breaks!)" }),
    t('useradd -g "$DEPT" -d "$HOME_DIR" -s '), rep(2), t(' -p "$HASHED" "$USERNAME"'), t({ "", "\t" }),
    t('RES=$?'), t({ "", "\t" }),
    t('if [[ $RES -eq 0 ]]; then'), t({ "", "\t\t" }),
    t('echo "✅ Created: $USERNAME"'), t({ "", "\t" }),
    t("else"), t({ "", "\t\t" }),
    t('echo "❌ Failed: $USERNAME (code $RES)" >&2'), t({ "", "\t" }),
    t("fi"), t({ "", "done" }),
    
    t({ "", "" }),
    t('echo "🎉 Bulk user creation complete!"'),
    t("exit 0"),
  }),

    -- 🔹 4. MySQL Query via Heredoc (Generic)
  s("bmysql_query", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Execute MySQL query via heredoc"), t({ "", "" }),
    t('DB_USER="'), i(1, "root"), t('"'), t({ "", "" }),
    t('DB_PASS="'), i(2, "Training2@^"), t('"'), t({ "", "" }),
    t('DB_NAME="'), i(3, ""), t('"  # Optional: use DATABASE or leave empty'), t({ "", "" }),
    t('QUERY="'), i(4, "SELECT VERSION();"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Execute query" }),
    t('mysql -u "$DB_USER" -p"$DB_PASS" ${DB_NAME:+"$DB_NAME"} <<MY_QUERY'),
    t("${QUERY}"),
    t("MY_QUERY"),
  }),

    -- 🔹 3. inotifywait File Monitor + Auto-Archive
  s("binotify_archive", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Monitor folder and archive created files"), t({ "", "" }),
    t('WATCH_FOLDER="'), i(1, "~/Desktop/abc"), t('"'), t({ "", "" }),
    t('ARCHIVE_FOLDER="'), i(2, "~/Desktop/Old_abc"), t('"'), t({ "", "" }),
    t('FILE_PATTERN="'), i(3, "output.txt"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Ensure archive folder exists" }),
    t('mkdir -p "$ARCHIVE_FOLDER"'), t({ "", "" }),
    t({ "", "# 🔹 Timestamp for archive naming" }),
    t('CDATE=$(date +"%Y-%m-%d-%H:%M")'), t({ "", "" }),
    t({ "", "# 🔹 Monitor for file creation events" }),
    t('inotifywait -m -q -e create -r --format \'%:e %w%f\' "$WATCH_FOLDER" | while read -r EVENT FILE; do'), t({ "", "\t" }),
    t('BASENAME=$(basename "$FILE")'), t({ "", "\t" }),
    t('if [[ "$BASENAME" == "$FILE_PATTERN" ]]; then'), t({ "", "\t\t" }),
    t('mv "$FILE" "${ARCHIVE_FOLDER}/${CDATE}-${BASENAME}"'), t({ "", "\t\t" }),
    t('echo "📦 Archived: $BASENAME -> ${CDATE}-${BASENAME}"'), t({ "", "\t" }),
    t("fi"), t({ "", "done" }),
  }),

  -- 🔹 2. WiFi Connection via wpa_supplicant
  s("bwifi_connect", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Connect to WPA2 WiFi (requires sudo)"), t({ "", "" }),
    t('if [[ $EUID -ne 0 ]]; then'), t({ "", "\t" }),
    t('echo "❌ Please run with sudo" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('SSID="'), i(1, "MyNetwork"), t('"'), t({ "", "" }),
    t('PASS="'), i(2, "MyPassword"), t('"'), t({ "", "" }),
    t('INTERFACE="'), i(3, "wlan0"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Backup existing configs" }),
    t('[[ -f /etc/network/interfaces ]] && cp /etc/network/interfaces /etc/network/interfaces.bak'), t({ "", "" }),
    t('[[ -f /etc/wpa_supplicant/wpa_supplicant.conf ]] && cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak'), t({ "", "" }),
    t({ "", "# 🔹 Build /etc/network/interfaces" }),
    t('cat > /etc/network/interfaces <<EOF'),
    t({ "", 'auto lo', 'iface lo inet loopback', 'iface eth0 inet dhcp', "" }),
    t('allow-hotplug ${INTERFACE}'),
    t('iface ${INTERFACE} inet manual'),
    t('wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf'),
    t('iface default inet dhcp'),
    t("EOF"), t({ "", "" }),
    t({ "", "# 🔹 Build wpa_supplicant.conf" }),
    t('cat > /etc/wpa_supplicant/wpa_supplicant.conf <<EOF'),
    t({ "", 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev', 'update_config=1', "" }),
    t("EOF"), t({ "", "" }),
    t({ "", "# 🔹 Add network credentials (passphrase is hashed)" }),
    t('wpa_passphrase "$SSID" "$PASS" >> /etc/wpa_supplicant/wpa_supplicant.conf'), t({ "", "" }),
    t({ "", "# 🔹 Bring interface up" }),
    t('ifdown "$INTERFACE" 2>/dev/null || true'), t({ "", "" }),
    t('ifup "$INTERFACE"'), t({ "", "" }),
    t('echo "✅ Connected to $SSID"'),
  }),

  -- 🔹 1. HTTP Connectivity Check via curl + case — ВИПРАВЛЕНО
s("bhttp_check", {
  t("#!/usr/bin/env bash"), t({ "", "" }),
  t("# 🔹 Check HTTP connectivity via status code"), t({ "", "" }),
  t('URL="'), i(1, "http://google.com"), t('"'), t({ "", "" }),
  t('TIMEOUT="'), i(2, "2"), t('"'), t({ "", "" }),
  t({ "", 'STATUS=$(curl -s --max-time "$TIMEOUT" -I "$URL" \\' }),
  t({ "", "  | sed 's/^[^ ]*  *\\([0-9]\\).*/\\1/; 1q')" }),
  t({ "", 'case "$STATUS" in', "" }),
  t("  [23])"), t({ "", "\t" }),
  t('echo "✅ HTTP connectivity is up (status: $STATUS)"'), t({ "", "\t" }),
  t(";;"), t({ "", "" }),
  t("  5)"), t({ "", "\t" }),
  -- ✅ ВИПРАВЛЕНО: використано подвійні лапки для зовнішнього рядка, щоб апостроф працював
  t("echo \"⚠️  The web proxy won't let us through (5xx)\""), t({ "", "\t" }),
  t(";;"), t({ "", "" }),
  t("  *)"), t({ "", "\t" }),
  t('echo "❌ The network is down or very slow (status: $STATUS)" >&2'), t({ "", "\t" }),
  t("exit 1"), t({ "", "\t" }),
  t(";;"), t({ "", "esac" }),
}),


  s("balarm_clock", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Simple Alarm Clock: sleep until target time"), t({ "", "" }),
    
    t({ "", "# 🔹 Get wake-up time from user" }),
    t('echo -n "⏰ What hour do you wake up? (0-23): "'), t({ "", "" }),
    t("read -r TARGET_H"), t({ "", "" }),
    t('echo -n "⏰ What minute? (0-59): "'), t({ "", "" }),
    t("read -r TARGET_M"), t({ "", "" }),
    
    t({ "", "# 🔹 Validate input" }),
    t('if ! [[ "$TARGET_H" =~ ^[0-9]+$ && "$TARGET_M" =~ ^[0-9]+$ ]]; then'), t({ "", "\t" }),
    t('echo "❌ Invalid input. Use numbers only." >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    
    t({ "", "# 🔹 Get current time" }),
    t('CUR_H=$(date +%H)'), t({ "", "" }),
    t('CUR_M=$(date +%M)'), t({ "", "" }),
    t({ "", "# Remove leading zeros for arithmetic" }),
    t('CUR_H=$((10#$CUR_H)); CUR_M=$((10#$CUR_M))'), t({ "", "" }),
    t('TARGET_H=$((10#$TARGET_H)); TARGET_M=$((10#$TARGET_M))'), t({ "", "" }),
    
    t({ "", 'echo -e "\\n📍 You selected: ${TARGET_H}:${TARGET_M}"', "" }),
    t({ "", 'echo -e "🕐 Current time: ${CUR_H}:${CUR_M}\\n"', "" }),
    
    t({ "", "# 🔹 Calculate time difference (simplified: same-day only)" }),
    t("# ⚠️  For cross-midnight alarms, add date handling"), t({ "", "" }),
    
    t("# 🔹 Hours difference"), t({ "", "" }),
    t('if [[ $CUR_H -lt $TARGET_H ]]; then'), t({ "", "\t" }),
    t('H_LEFT=$(( TARGET_H - CUR_H ))'), t({ "", "\t" }),
    t('echo "✅ $TARGET_H - $CUR_H = $H_LEFT hours remaining"'), t({ "", "elif [[ $CUR_H -gt $TARGET_H ]]; then", "\t" }),
    t('H_LEFT=$(( CUR_H - TARGET_H ))'), t({ "", "\t" }),
    t('echo "⚠️  Target hour passed: $CUR_H - $TARGET_H = $H_LEFT hours ago"'), t({ "", "else", "\t" }),
    t('H_LEFT=0'), t({ "", "\t" }),
    t('echo "🎯 Same hour!"'), t({ "", "fi", "" }),
    
    t({ "", "# 🔹 Minutes difference" }),
    t('if [[ $CUR_M -lt $TARGET_M ]]; then'), t({ "", "\t" }),
    t('M_LEFT=$(( TARGET_M - CUR_M ))'), t({ "", "\t" }),
    t('echo "✅ $TARGET_M - $CUR_M = $M_LEFT minutes remaining"'), t({ "", "elif [[ $CUR_M -gt $TARGET_M ]]; then", "\t" }),
    t('M_LEFT=$(( CUR_M - TARGET_M ))'), t({ "", "\t" }),
    t('echo "⚠️  Target minute passed: $CUR_M - $TARGET_M = $M_LEFT minutes ago"'), t({ "", "else", "\t" }),
    t('M_LEFT=0'), t({ "", "\t" }),
    t('echo "🎯 Same minute!"'), t({ "", "fi", "" }),
    
    t({ "", "", "# 🔹 Total sleep time in seconds" }),
    t('TOTAL_SEC=$(( (H_LEFT * 3600) + (M_LEFT * 60) ))'), t({ "", "" }),
    t({ "", 'echo -e "\\n😴 Sleeping for $H_LEFT hours and $M_LEFT minutes ($TOTAL_SEC seconds)\\n"', "" }),
    
    t({ "", "# 🔹 Sleep (use seconds for precision)" }),
    t('if [[ $TOTAL_SEC -gt 0 ]]; then'), t({ "", "\t" }),
    t("sleep \"$TOTAL_SEC\""), t({ "", "fi", "" }),
    
    t({ "", "# 🔹 Play alarm sound" }),
    t('ALARM_FILE="'), i(1, "~/.alarm/alarm.mp3"), t('"'), t({ "", "" }),
    t('if command -v mplayer >/dev/null 2>&1; then'), t({ "", "\t" }),
    t('mplayer "$ALARM_FILE"'), t({ "", "elif command -v ffplay >/dev/null 2>&1; then", "\t" }),
    t('ffplay -nodisp -autoexit "$ALARM_FILE" 2>/dev/null'), t({ "", "elif command -v paplay >/dev/null 2>&1; then", "\t" }),
    t('paplay "$ALARM_FILE"'), t({ "", "else", "\t" }),
    t('echo "🔔 No audio player found. Please wake up!"'), t({ "", "\t" }),
    t('for i in {1..5}; do echo -ne "\\a"; sleep 0.5; done'), t({ "", "fi" }),
    
    t({ "", "" }),
    t('echo "✅ Alarm finished!"'),
    t("exit 0"),
  }),

    -- 🔹 1. Yes/No Confirmation Dialog
  s("bdialog_yesno", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Yes/No Dialog (requires 'dialog' package)"), t({ "", "" }),
    t('dialog --yesno "'), i(1, "Do you wish to continue?"), t('" 0 0'), t({ "", "" }),
    t("EXIT_CODE=$?"), t({ "", "" }),
    t('if [[ $EXIT_CODE -eq 0 ]]; then'), t({ "", "\t" }),
    t('echo "✅ Yes selected"'), t({ "", "\t" }),
    t("# 🔹 Your 'Yes' logic here"), t({ "", "elif [[ $EXIT_CODE -eq 1 ]]; then", "\t" }),
    t('echo "❌ No/Cancel selected"'), t({ "", "\t" }),
    t("# 🔹 Your 'No' logic here"), t({ "", "else", "\t" }),
    t('echo "⚠️  Escaped via ESC key (code $EXIT_CODE)" >&2'), t({ "", "\t" }),
    t("exit 255"), t({ "", "fi" }),
  }),

   s("bdialog_calendar", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Calendar Dialog: Select a date"), t({ "", "" }),
    t('# ⚠️  Dialog outputs MM/DD/YYYY to --stdout'), t({ "", "" }),
    t('SELECTED_DATE=$(dialog --stdout --calendar "'), i(1, "Select a date..."), t('" 0 0 '), i(2, "1"), t(' '), i(3, "1"), t(' '), i(4, "2024"), t({ "", "" }),
    t("EXIT_CODE=$?"), t({ "", "" }),
    t('if [[ $EXIT_CODE -eq 0 ]]; then'), t({ "", "\t" }),
    t('echo "✅ Date selected: $SELECTED_DATE"'), t({ "", "\t" }),
    t('# 🔹 Parse MM/DD/YYYY'), t({ "", "\t" }),
    t('IFS="/" read -r MONTH DAY YEAR <<< "$SELECTED_DATE"'), t({ "", "\t" }),
    t('echo "📅 Year: $YEAR | Month: $MONTH | Day: $DAY"'), t({ "", "else", "\t" }),
    t('echo "❌ Cancelled or Escaped" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi" }),
  }),

    s("bdialog_checklist", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Checklist Dialog: Multiple selection"), t({ "", "" }),
    t('CHOICES=$(dialog --stdout --checklist "'), i(1, "Enable the account options you want:"), t('" 10 40 3 \\\\'), t({ "", "" }),
    t('  "'), i(2, "1"), t('" "'), i(3, "Home directory"), t('" '), i(4, "on"), t(' \\\\'), t({ "", "" }),
    t('  "'), i(5, "2"), t('" "'), i(6, "Signature file"), t('" '), i(7, "off"), t(' \\\\'), t({ "", "" }),
    t('  "'), i(8, "3"), t('" "'), i(9, "Simple password"), t('" '), i(10, "off"), t({ "", "" }),  -- ✅ ВИПРАВЛЕНО: прибрано зайву )
    t("EXIT_CODE=$?"), t({ "", "" }),
    t('if [[ $EXIT_CODE -eq 0 ]]; then'), t({ "", "\t" }),
    t('echo "✅ Selected items: $CHOICES"'), t({ "", "\t" }),
    t("# 🔹 Process each selected tag"), t({ "", "\t" }),
    t('for ITEM in $CHOICES; do'), t({ "", "\t\t" }),
    t('case "$ITEM" in'), t({ "", "\t\t\t" }),
    t('1) echo "  📁 Home directory enabled" ;;'), t({ "", "\t\t\t" }),
    t('2) echo "  📝 Signature file enabled" ;;'), t({ "", "\t\t\t" }),
    t('3) echo "  🔒 Simple password enabled" ;;'), t({ "", "\t\t" }),
    t('esac'), t({ "", "\t" }),
    t("done"), t({ "", "else", "\t" }),
    t('echo "❌ Cancelled" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi" }),
  }),

    s("bdialog_generic", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Generic dialog: --menu, --inputbox, --radiolist, etc."), t({ "", "" }),
    t('RESULT=$(dialog --stdout --'), i(1, "menu"), t(' "'), i(2, "Choose an option"), t('" 0 0 0 \\'), t({ "", "" }),
    t('  "'), i(3, "opt1"), t('" "'), i(4, "Description 1"), t('" \\'), t({ "", "" }),
    t('  "'), i(5, "opt2"), t('" "'), i(6, "Description 2"), t('" \\'), t({ "", "" }),
    t('  "'), i(7, "opt3"), t('" "'), i(8, "Description 3"), t('"'), t({ "", "" }),  -- ✅ ВИПРАВЛЕНО: прибрано зайву )
    t("EXIT_CODE=$?"), t({ "", "" }),
    t('[[ $EXIT_CODE -eq 0 ]] && echo "👉 Selected: $RESULT" || echo "❌ Cancelled" >&2'),
  }),

    s("bchecksum_db", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 SHA-256 Directory Integrity Checker"), t({ "", "" }),
    t("set -euo pipefail  # Fail on errors, unset vars, pipe failures"), t({ "", "" }),
    t("# 🔹 Error codes"), t({ "", "" }),
    t("E_DIR_NOMATCH="), i(1, "50"), t({ "", "" }),
    t("E_BAD_DBFILE="), i(2, "51"), t({ "", "" }),
    t('DB_FILE="'), i(3, "Filerec.sha256"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Target directory (arg1 or PWD)" }),
    t('DIRECTORY="${1:-$PWD}"'), t({ "", "" }),
    t({ "", "# 🔹 Setup Database" }),
    t("function setup_database() {"), t({ "", "\t" }),
    t('echo "Directory: $DIRECTORY" > "$DB_FILE"'), t({ "", "\t" }),
    t('sha256sum "$DIRECTORY"/* >> "$DB_FILE" 2>/dev/null || true'), t({ "", "}", "" }),
    t({ "", "# 🔹 Check Database" }),
    t("function check_database() {"), t({ "", "\t" }),
    t('if [[ ! -r "$DB_FILE" ]]; then'), t({ "", "\t\t" }),
    t('echo "❌ Unable to read checksum database!" >&2'), t({ "", "\t\t" }),
    t("exit $E_BAD_DBFILE"), t({ "", "\t" }),
    t("fi", "", ""),
    t("\tlocal line_num=0"), t({ "", "\t" }),
    t("while IFS= read -r line; do"), t({ "", "\t\t" }),
    t("line_num=$((line_num + 1))"), t({ "", "\t\t" }),
    t("if [[ $line_num -eq 1 ]]; then"), t({ "", "\t\t\t" }),
    t('local stored_dir="${line#Directory: }"'), t({ "", "\t\t\t" }),
    t('if [[ "$stored_dir" != "$DIRECTORY" ]]; then'), t({ "", "\t\t\t\t" }),
    t('echo "❌ Directories do not match!" >&2'), t({ "", "\t\t\t\t" }),
    t("exit $E_DIR_NOMATCH"), t({ "", "\t\t\t" }),
    t("fi"), t({ "", "\t\t\t" }),
    t("continue"), t({ "", "\t\t" }),
    t("fi", "", ""),
    t("\t\t# Parse sha256sum output: 'hash  filename'"), t({ "", "\t\t" }),
    t('local expected_hash="${line%% *}"'), t({ "", "\t\t" }),
    t('local filename="${line#* }"'), t({ "", "\t\t" }),
    t('if [[ ! -f "$filename" ]]; then'), t({ "", "\t\t\t" }),
    t('echo "⚠️  MISSING: $filename"'), t({ "", "\t\t\t" }),
    t("continue"), t({ "", "\t\t" }),
    t("fi", "", ""),
    t("\t\tlocal current_hash"), t({ "", "\t\t" }),
    t("current_hash=$(sha256sum \"$filename\" | awk '{print $1}')"), t({ "", "\t\t" }),
    t('if [[ "$current_hash" == "$expected_hash" ]]; then'), t({ "", "\t\t\t" }),
    t('echo "✅ OK: $filename"'), t({ "", "\t\t" }),
    t("else"), t({ "", "\t\t\t" }),
    t('echo "❌ CHANGED: $filename"'), t({ "", "\t\t" }),
    t("fi"), t({ "", "\t" }),
    t('done < "$DB_FILE"'), t({ "", "}", "" }),
    t({ "", "# 🔹 Main Logic" }),
    t('if [[ ! -r "$DB_FILE" ]]; then'), t({ "", "\t" }),
    t('echo "📦 Setting up database for: $DIRECTORY"'), t({ "", "\t" }),
    t("setup_database"), t({ "", "\t" }),
    t('echo "✅ Database created."'), t({ "", "else", "\t" }),
    t("check_database"), t({ "", "fi", "" }),
    t("exit 0"),
  }),

    s("tz_check", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Multi-Timezone Clock/Checker"), t({ "", "" }),
    t("# 🔹 Define timezones to monitor (IANA format)"), t({ "", "" }),
    t("TIMEZONES=("), t({ "", "" }),
    t('  "'), i(1, "Antarctica/Casey"), t('"'), t({ "", "" }),
    t('  "'), i(2, "Atlantic/Bermuda"), t('"'), t({ "", "" }),
    t('  "'), i(3, "Asia/Kolkata"), t('"  # Calcutta -> Kolkata'), t({ "", "" }),
    t('  "'), i(4, "Europe/Amsterdam"), t('"'), t({ "", "" }),
    t('  "'), i(5, "UTC"), t('"'), t({ "", "" }),
    t(")"), t({ "", "" }),
    t({ "", "# 🔹 Date format string (see man date)" }),
    t('FORMAT="'), i(6, "%Y-%m-%d %H:%M:%S %Z"), t('"'), t({ "", "" }),
    t({ "", 'echo "🌍 Current Time in Selected Timezones:"', '' }),
    t('echo "--------------------------------------"'), t({ "", "" }),
    t('for TZ_NAME in "${TIMEZONES[@]}"; do'), t({ "", "\t" }),
    t('if [[ -f "/usr/share/zoneinfo/$TZ_NAME" ]]; then'), t({ "", "\t\t" }),
    t('CURRENT_TIME=$(TZ="$TZ_NAME" date +"$FORMAT")'), t({ "", "\t\t" }),
    t('printf "📍 %-20s | %s\\n" "$TZ_NAME" "$CURRENT_TIME"'), t({ "", "\t" }),
    t("else"), t({ "", "\t\t" }),
    t('printf "⚠️  %-20s | Invalid timezone\\n" "$TZ_NAME"'), t({ "", "\t" }),
    t("fi"), t({ "", "done" }),
    t({ "", "exit 0" }),
  }),

  -- 🔹 Bonus: One-liner quick check
  s("tz_quick", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('TZ="'), i(1, "Europe/Kyiv"), t('" date +"%Y-%m-%d %H:%M:%S %Z"'),
  }),

    s("bfirewall_iptables", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 DMZ Firewall Configuration with NAT Port Forwarding"), t({ "", "" }),
    t("# ⚠️  Requires root privileges"), t({ "", "" }),
    t('if [[ $EUID -ne 0 ]]; then'), t({ "", "\t" }),
    t('echo "❌ Please run with sudo" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Network Interface Configuration" }),
    t('INT_IFACE="'), i(1, "eth0"), t('"  # Internal network'), t({ "", "" }),
    t('DMZ_IFACE="'), i(2, "eth2"), t('"  # DMZ segment'), t({ "", "" }),
    t('EXT_IFACE="'), i(3, "ens33"), t('"  # Internet/WAN'), t({ "", "" }),
    t({ "", "# 🔹 Public & DMZ IP Addresses" }),
    t('PUBLIC_IP="'), i(4, "200.0.0.1"), t('"'), t({ "", "" }),
    t('WEB_SERVER="'), i(5, "192.168.20.2"), t('"'), t({ "", "" }),
    t('MAIL_SERVER="'), i(6, "192.168.20.3"), t('"'), t({ "", "" }),
    t('DNS_SERVER="'), i(7, "192.168.20.4"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Flush existing rules (idempotent setup)" }),
    t('iptables -F'), t({ "", "" }),
    t('iptables -t nat -F'), t({ "", "" }),
    t('iptables -X'), t({ "", "" }),
    t({ "", "# 🔹 Default DROP policy (deny all by default)" }),
    t('iptables -P INPUT DROP'), t({ "", "" }),
    t('iptables -P OUTPUT DROP'), t({ "", "" }),
    t('iptables -P FORWARD DROP'), t({ "", "" }),
    t({ "", "# 🔹 Enable IP forwarding (router mode)" }),
    t('sysctl -w net.ipv4.ip_forward=1'), t({ "", "" }),
    t('echo 1 > /proc/sys/net/ipv4/ip_forward'), t({ "", "" }),
    t({ "", "# 🔹 Allow loopback traffic" }),
    t('iptables -A INPUT -i lo -j ACCEPT'), t({ "", "" }),
    t('iptables -A OUTPUT -o lo -j ACCEPT'), t({ "", "" }),
    t({ "", "# 🔹 Allow established/related connections (stateful)" }),
    t('iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT'), t({ "", "" }),
    t('iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT'), t({ "", "" }),
    t({ "", "# 🔹 FORWARD: Internal (eth0) ↔ DMZ (eth2)" }),
    t('iptables -A FORWARD -i "$INT_IFACE" -o "$DMZ_IFACE" -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT'), t({ "", "" }),
    t('iptables -A FORWARD -i "$DMZ_IFACE" -o "$INT_IFACE" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT'), t({ "", "" }),
    t({ "", "# 🔹 FORWARD: Internet (ens33) ↔ DMZ (eth2)" }),
    t('iptables -A FORWARD -i "$EXT_IFACE" -o "$DMZ_IFACE" -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT'), t({ "", "" }),
    t('iptables -A FORWARD -i "$DMZ_IFACE" -o "$EXT_IFACE" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT'), t({ "", "" }),
    t({ "", "# 🔹 NAT: Port Forwarding (DNAT) - Web Server" }),
    t('iptables -t nat -A PREROUTING -p tcp -i "$EXT_IFACE" -d "$PUBLIC_IP" --dport 80 -j DNAT --to-destination "$WEB_SERVER":80'), t({ "", "" }),
    t('iptables -t nat -A PREROUTING -p tcp -i "$EXT_IFACE" -d "$PUBLIC_IP" --dport 443 -j DNAT --to-destination "$WEB_SERVER":443'), t({ "", "" }),
    t({ "", "# 🔹 NAT: Port Forwarding - Mail Server (SMTP)" }),
    t('iptables -t nat -A PREROUTING -p tcp -i "$EXT_IFACE" -d "$PUBLIC_IP" --dport 25 -j DNAT --to-destination "$MAIL_SERVER":25'), t({ "", "" }),
    t({ "", "# 🔹 NAT: Port Forwarding - DNS Server" }),
    t('iptables -t nat -A PREROUTING -p udp -i "$EXT_IFACE" -d "$PUBLIC_IP" --dport 53 -j DNAT --to-destination "$DNS_SERVER":53'), t({ "", "" }),
    t('iptables -t nat -A PREROUTING -p tcp -i "$EXT_IFACE" -d "$PUBLIC_IP" --dport 53 -j DNAT --to-destination "$DNS_SERVER":53'), t({ "", "" }),
    t({ "", "# 🔹 Optional: Log dropped packets for debugging" }),
    t('# iptables -A FORWARD -j LOG --log-prefix "FW-DROP: " --log-level 4'), t({ "", "" }),
    t({ "", "# 🔹 Save rules (distribution-specific)" }),
    t('# Debian/Ubuntu: iptables-save > /etc/iptables/rules.v4'), t({ "", "" }),
    t('# RHEL/CentOS: service iptables save'), t({ "", "" }),
    t({ "", 'echo "✅ Firewall rules applied successfully!"', "" }),
    t("exit 0"),
  }),

   s("bscrape_links", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Extract unique HTTP links from a website"), t({ "", "" }),
    t('TARGET_URL="'), i(1, "https://example.com"), t('"'), t({ "", "" }),
    t('OUTPUT_FILE="'), i(2, "links_final.csv"), t('"'), t({ "", "" }),
    t('TEMP_DIR="'), i(3, "data"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Setup" }),
    t('mkdir -p "$TEMP_DIR"'), t({ "", "" }),
    t('cd "$TEMP_DIR" || exit 1'), t({ "", "" }),
    t({ "", "# 🔹 Recursive download (respect robots.txt, limit depth)" }),
    t('wget -q --execute robots=off -r -l '), i(4, "2"), t(' -np -nH --cut-dirs=1 "$TARGET_URL"'), t({ "", "" }),
    t({ "", "# 🔹 Extract hrefs using grep with Perl regex" }),
    -- ✅ ВИПРАВЛЕНО: використано подвійні лапки зовні, щоб одинарні всередині працювали
    t("if command -v grep >/dev/null 2>&1 && grep -P '' /dev/null 2>/dev/null; then"), t({ "", "\t" }),
    t([[grep -r -Po '(?<=href=")[^"]*' . > ../links.csv 2>/dev/null || true]]), t({ "", "else", "\t" }),
    t('echo "⚠️  grep -P not available, using fallback..." >&2'), t({ "", "\t" }),
    -- ✅ ВИПРАВЛЕНО: long bracket string [[...]] для складних сед-патернів
    t([[grep -roh 'href="[^"]*"' . | sed 's/href="\([^"]*\)"/\1/' > ../links.csv]]), t({ "", "fi", "" }),
    t('cd ..'), t({ "", "" }),
    t({ "", "# 🔹 Filter & deduplicate" }),
    t('grep "^http" links.csv > links_filtered.csv 2>/dev/null || true'), t({ "", "" }),
    t('sort -u links_filtered.csv > "$OUTPUT_FILE"'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup temp files" }),
    t('rm -rf "$TEMP_DIR" links.csv links_filtered.csv'), t({ "", "" }),
    t('COUNT=$(wc -l < "$OUTPUT_FILE")'), t({ "", "" }),
    t('echo "✅ Extracted $COUNT unique links to $OUTPUT_FILE"'),
    t("exit 0"),
  }),

    s("birc_logger", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Simple IRC logger (requires 'nc' netcat)"), t({ "", "" }),
    t('NICK="'), i(1, "blb"), t('_$$"'), t({ "", "" }),
    t('CHANNEL="'), i(2, "testchannel"), t('"'), t({ "", "" }),
    t('SERVER="'), i(3, "irc.libera.chat"), t('"'), t({ "", "" }),
    t('PORT="'), i(4, "6667"), t('"'), t({ "", "" }),
    t('CONFIG="/tmp/irclog_${CHANNEL}"'), t({ "", "" }),
    t({ "", "# 🔹 Override via arguments" }),
    t('[[ -n "$1" ]] && CHANNEL="$1"'), t({ "", "" }),
    t('[[ -n "$2" ]] && SERVER="$2"'), t({ "", "" }),
    t({ "", "# 🔹 Build IRC commands" }),
    t('echo "NICK $NICK" > "$CONFIG"'), t({ "", "" }),
    t('echo "USER $NICK +i * :irc_logger" >> "$CONFIG"'), t({ "", "" }),
    t('sleep 1  # Wait for server to be ready'), t({ "", "" }),
    t('echo "JOIN #$CHANNEL" >> "$CONFIG"'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup on exit" }),
    t('trap \'rm -f "$CONFIG"\' EXIT INT TERM'), t({ "", "" }),
    t({ "", "# 🔹 Main loop: read from server, handle PING, log PRIVMSG" }),
    t('{ cat "$CONFIG"; sleep infinity; } | nc -w 5 "$SERVER" "$PORT" | while IFS= read -r MESSAGE; do'), t({ "", "\t" }),
    t('case "$MESSAGE" in'), t({ "", "\t\t" }),
    t('PING\\ *)'), t({ "", "\t\t\t" }),
    t('echo "PONG${MESSAGE#PING}"'), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    -- ✅ ВИПРАВЛЕНО: використано .. для конкатенації змінної
    t('*PRIVMSG*#' .. '"$CHANNEL"' .. '*'), t({ "", "\t\t\t" }),
    t('echo "$MESSAGE" | sed -nr "s/^:([^!]+).*PRIVMSG[^:]+:(.*)/[$(date \'+%R\')] \\1> \\2/p"'), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t('QUIT|PART|JOIN|NICK)'), t({ "", "\t\t\t" }),
    t("# Ignore system messages"), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t('*'), t({ "", "\t\t\t" }),
    t('# echo "[DEBUG] $MESSAGE" >&2  # Uncomment for debugging'), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t("esac"), t({ "", "\t" }),
    t("done"), t({ "", "" }),
    t("exit 0"),
  }),

    -- 🔹 1. Simple if with numeric comparison
  s("bif_eq", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('a="'), i(1, "100"), t('"'), t({ "", "" }),
    t('if [[ "$a" -eq '), i(2, "100"), t(' ]]; then'), t({ "", "\t" }),
    t('echo "✅ a is equal to $a"'), t({ "", "fi" }),
  }),

  -- 🔹 2. For loop with brace expansion


  -- 🔹 3. While loop with numeric condition
  s("bwhile_eq", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('x="'), i(1, "10"), t('"'), t({ "", "" }),
    t('while [[ "$x" -eq '), i(2, "10"), t(' ]]; do'), t({ "", "\t" }),
    t('echo "🔁 Current value: $x"'), t({ "", "\t" }),
    t("# 🔹 Add break condition to avoid infinite loop!"), t({ "", "\t" }),
    t("# x=$(( x + 1 ))  # Example increment"), t({ "", "\t" }),
    t("sleep "), i(3, "2"), t({ "", "done" }),
  }),

  -- 🔹 4. Variable assignment + arithmetic (FIXED)
  s("bvar_math", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('echo "'), i(1, "Hello World"), t('"'), t({ "", "" }),
    t({ "", "# ⚠️  NO SPACES around = in Bash!" }),
    t('a="'), i(2, "100"), t('"'), t({ "", "" }),
    t('b="'), i(3, "20"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Arithmetic: $(( )) syntax" }),
    t('c=$(( a + b ))'), t({ "", "" }),
    t('echo "➕ Result: $c"'), t({ "", "" }),
    t('echo "📦 Variable a: $a"'),
  }),

  -- 🔹 5. Associative Array Config Parser
  s("bconfig_assoc", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Parse key=value config into associative array"), t({ "", "" }),
    t('declare -A config'), t({ "", "" }),
    t('CONFIG_FILE="'), i(1, "sampleconfig.conf"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Default values" }),
    t('config=('), t({ "", "" }),
    t('  [username]="'), i(2, "student"), t('"'), t({ "", "" }),
    t('  [password]="'), i(3, ""), t('"'), t({ "", "" }),
    t('  [hostname]="'), i(4, "ubuntu"), t('"'), t({ "", "" }),
    t(")"), t({ "", "" }),
    t({ "", "# 🔹 Read config file (override defaults)" }),
    t('if [[ -f "$CONFIG_FILE" ]]; then'), t({ "", "\t" }),
    t('while IFS= read -r line || [[ -n "$line" ]]; do'), t({ "", "\t\t" }),
    t('# Skip empty lines and comments'), t({ "", "\t\t" }),
    t('[[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue'), t({ "", "\t\t" }),
    t('if [[ "$line" == *"="* ]]; then'), t({ "", "\t\t\t" }),
    t('key="${line%%=*}"'), t({ "", "\t\t\t" }),
    t('value="${line#*=}"'), t({ "", "\t\t\t" }),
    t('# Trim whitespace'), t({ "", "\t\t\t" }),
    t('key="${key#"${key%%[![:space:]]*}"}"'), t({ "", "\t\t\t" }),
    t('key="${key%"${key##*[![:space:]]}"}"'), t({ "", "\t\t\t" }),
    t('value="${value#"${value%%[![:space:]]*}"}"'), t({ "", "\t\t\t" }),
    t('value="${value%"${value##*[![:space:]]}"}"'), t({ "", "\t\t\t" }),
    t('config["$key"]="$value"'), t({ "", "\t\t" }),
    t("fi"), t({ "", "\t" }),
    t('done < "$CONFIG_FILE"'), t({ "", "fi", "" }),
    t({ "", "# 🔹 Access values" }),
    t('echo "username: ${config[username]}"'), t({ "", "" }),
    t('echo "password: ${config[password]}"'), t({ "", "" }),
    t('echo "hostname: ${config[hostname]}"'), t({ "", "" }),
    t('echo "PROMPT_COMMAND: ${config[PROMPT_COMMAND]:-not set}"'),
  }),

  s("bfor_brace", {
  t("#!/usr/bin/env bash"), t({ "", "" }),
  t('for i in {'), i(1, "1"), t('..'), i(2, "10"), t('}; do'), t({ "", "\t" }),
  t('echo "'), i(3, "Hello World"), t(' # Iteration $i"'), t({ "", "done" }),
}),

  -- 🔹 1. Ordinal Number Function
  s("bordinal", {
    t("function ordinal() {"), t({ "", "\t" }),
    t('case "$1" in'), t({ "", "\t\t" }),
    t('*1[0-9] | *[04-9]) echo "$1"th ;;'), t({ "", "\t\t" }),
    t('*1) echo "$1"st ;;'), t({ "", "\t\t" }),
    t('*2) echo "$1"nd ;;'), t({ "", "\t\t" }),
    t('*3) echo "$1"rd ;;'), t({ "", "\t" }),
    t("esac"), t({ "", "}" }),
  }),

  -- 🔹 2. Basic getopts Loop
  s("bgetopts_basic", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("while getopts 'srd:f:' c; do"), t({ "", "\t" }),
    t("case $c in"), t({ "", "\t\t" }),
    t("s) ACTION=SAVE ;;"), t({ "", "\t\t" }),
    t("r) ACTION=RESTORE ;;"), t({ "", "\t\t" }),
    t("d) DB_DUMP=$OPTARG ;;"), t({ "", "\t\t" }),
    t("f) TARBALL=$OPTARG ;;"), t({ "", "\t" }),
    t("esac"), t({ "", "done" }),
  }),

  -- 🔹 3. getopts with Action Execution & Checks
  s("bgetopts_actions", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("unset DB_DUMP TARBALL ACTION"), t({ "", "" }),
    t("while getopts 'srd:f:' c; do"), t({ "", "\t" }),
    t("case $c in"), t({ "", "\t\t" }),
    t("s) ACTION=SAVE ;;"), t({ "", "\t\t" }),
    t("r) ACTION=RESTORE ;;"), t({ "", "\t\t" }),
    t("d) DB_DUMP=$OPTARG ;;"), t({ "", "\t\t" }),
    t("f) TARBALL=$OPTARG ;;"), t({ "", "\t" }),
    t("esac"), t({ "", "done", "" }),
    t('if [[ -n "$DB_DUMP" ]]; then'), t({ "", "\t" }),
    t('case $ACTION in'), t({ "", "\t\t" }),
    t('SAVE)    save_database "$DB_DUMP" ;;'), t({ "", "\t\t" }),
    t('RESTORE) restore_database "$DB_DUMP" ;;'), t({ "", "\t" }),
    t("esac"), t({ "", "fi", "" }),
    t('if [[ -n "$TARBALL" ]]; then'), t({ "", "\t" }),
    t('case $ACTION in'), t({ "", "\t\t" }),
    t('SAVE)    save_files "$TARBALL" ;;'), t({ "", "\t\t" }),
    t('RESTORE) restore_files "$TARBALL" ;;'), t({ "", "\t" }),
    t("esac"), t({ "", "fi" }),
  }),

  -- 🔹 4. Advanced getopts (usage + set_variable + validation)
  s("bgetopts_advanced", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("usage() {"), t({ "", "\t" }),
    t('echo "Usage: $0 [-s|-r] [-d DB_DUMP] [-f TARBALL]"'), t({ "", "\t" }),
    t("exit 2"), t({ "", "}", "" }),
    t("set_variable() {"), t({ "", "\t" }),
    t("local varname=$1; shift"), t({ "", "\t" }),
    t('if [[ -z "${!varname}" ]]; then'), t({ "", "\t\t" }),
    t('eval "$varname=\"$*\""'), t({ "", "\t" }),
    t("else"), t({ "", "\t\t" }),
    t('echo "Error: $varname already set"; usage'), t({ "", "\t" }),
    t("fi"), t({ "", "}", "" }),
    t("unset DB_DUMP TARBALL ACTION"), t({ "", "" }),
    t("while getopts 'srd:f:?h' c; do"), t({ "", "\t" }),
    t("case $c in"), t({ "", "\t\t" }),
    t("s) set_variable ACTION SAVE ;;"), t({ "", "\t\t" }),
    t("r) set_variable ACTION RESTORE ;;"), t({ "", "\t\t" }),
    t("d) set_variable DB_DUMP \"$OPTARG\" ;;"), t({ "", "\t\t" }),
    t("f) set_variable TARBALL \"$OPTARG\" ;;"), t({ "", "\t\t" }),
    t("h|?) usage ;;"), t({ "", "\t" }),
    t("esac"), t({ "", "done", "" }),
    t('[[ -z "$ACTION" || ( -z "$DB_DUMP" && -z "$TARBALL" ) ]] && usage', "", ""),
    t("# 🔹 Execution placeholders"), t({ "", "" }),
    t('[[ -n "$DB_DUMP" ]] && echo "Running $ACTION on $DB_DUMP"'), t({ "", "" }),
    t('[[ -n "$TARBALL" ]] && echo "Running $ACTION on $TARBALL"'),
  }),

  -- 🔹 5. getopts with VERBOSE, set -x & shift
  s("bgetopts_verbose", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("unset VERBOSE ACTION"), t({ "", "" }),
    t("while getopts 'smv' c; do"), t({ "", "\t" }),
    t('echo "Processing $c : OPTIND is $OPTIND"'), t({ "", "\t" }),
    t("case $c in"), t({ "", "\t\t" }),
    t("s) ACTION=sha1sum ;;"), t({ "", "\t\t" }),
    t("m) ACTION=md5sum ;;"), t({ "", "\t\t" }),
    t("v) VERBOSE=true ;;"), t({ "", "\t" }),
    t("esac"), t({ "", "done", "" }),
    t('echo "Out of loop. OPTIND=$OPTIND"'), t({ "", "" }),
    t("shift $((OPTIND - 1))"), t({ "", "" }),
    t('[[ "$VERBOSE" == "true" ]] && set -x'), t({ "", "" }),
    t("# 🔹 Execute with remaining arguments"), t({ "", "" }),
    t('"$ACTION" "$@"'),
  }),

  -- 🔹 6. Test Loop calling ordinal()
  s("bloop_ordinal", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Test ordinal function with mixed inputs"), t({ "", "" }),
    t('for x in $(seq 1 25) 100 101 102 $RANDOM $RANDOM $RANDOM $RANDOM; do'), t({ "", "\t" }),
    t('echo "$x is $(ordinal "$x")"'), t({ "", "done" }),
  }),

   -- 🔹 1. Case Modification: Highlight Letter
  s("bcase_highlight", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('read -rp "Enter some lowercase text: " text'), t({ "", "" }),
    t('read -rp "Which letter to highlight?: " highlight'), t({ "", "" }),
    t('echo "I have highlighted that letter for you:"'), t({ "", "" }),
    t('# 🔹 ${var^^pattern} — uppercase matching pattern'), t({ "", "" }),
    t('echo "${text^^$highlight}"'),
  }),

  -- 🔹 2. Portable echo -n Detection
  s("becho_portable", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Detect if echo supports -n"), t({ "", "" }),
    t('if [[ "$(echo -n)" == "-n" ]]; then'), t({ "", "\t" }),
    t('N=""'), t({ "", "\t" }),
    t('C="\\\\c"  # BSD-style suppress newline'), t({ "", "else", "\t" }),
    t('N="-n"'), t({ "", "\t" }),
    t('C=""'), t({ "", "fi", "" }),
    t('echo $N "Enter your name: $C"'), t({ "", "" }),
    t('read -r name'), t({ "", "" }),
    t('echo "Hello, $name"'),
  }),


  -- 🔹 3. Spinner Animation with Background Process + Trap
  s("bspinner", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Animated spinner for long operations"), t({ "", "" }),
    t('spinner="/|\\\\-/|\\\\-"'), t({ "", "" }),
    t("spin() {"), t({ "", "\t" }),
    t('while :; do'), t({ "", "\t\t" }),
    t('for i in {0..7}; do'), t({ "", "\t\t\t" }),
    t('echo -ne "${spinner:$i:1}\\r"'), t({ "", "\t\t\t" }),
    t("sleep 0.1"), t({ "", "\t\t" }),
    t("done"), t({ "", "\t" }),
    t("done"), t({ "", "}", "" }),
    t({ "", "# 🔹 Start spinner in background" }),
    t('echo "⏳ Starting slow operation..."'), t({ "", "" }),
    t("spin &"), t({ "", "" }),
    t("SPIN_PID=$!"), t({ "", "" }),
    t({ "", "# 🔹 Kill spinner on any exit signal" }),
    t('trap "kill $SPIN_PID 2>/dev/null" EXIT INT TERM'), t({ "", "" }),
    t({ "", "# 🔹 Simulate slow operation (replace with real command)" }),
    t('curl -sL "'), i(1, "https://httpbin.org/delay/5"), t('" >/dev/null'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup (trap handles it, but explicit is clearer)" }),
    t("kill $SPIN_PID 2>/dev/null"), t({ "", "" }),
    t('echo -e "\\n✅ Finished!"'),
  }),

-- 🔹 4. Loop Control: continue + break — ВИПРАВЛЕНО
s("bloop_control", {
  t("#!/usr/bin/env bash"), t({ "", "" }),
  t("# 🔹 Demonstrate continue/break in for loop"), t({ "", "" }),
  t('for x in {'), i(1, "1"), t('..'), i(2, "9"), t('}; do'), t({ "", "\t" }),
  t('echo -n "x is $x. "'), t({ "", "\t" }),
  t('if [[ $x -eq '), i(3, "4"), t(' ]]; then'), t({ "", "\t\t" }),
  t('echo  # New line'), t({ "", "\t\t" }),
  t('continue  # Skip rest, go to next iteration'), t({ "", "\t" }),
  t("fi"), t({ "", "\t" }),
  -- ✅ ВИПРАВЛЕНО: використано подвійні лапки зовні, щоб апостроф працював
  t("echo \"Most numbers get here, but $"), rep(3), t(" doesn't.\""), t({ "", "\t" }),
  t('if [[ $x -eq '), i(4, "7"), t(' ]]; then'), t({ "", "\t\t" }),
  t('break  # Exit loop completely'), t({ "", "\t" }),
  t("fi"), t({ "", "done", "" }),
  t('echo "Loop finished. Final x=$x"'),
}),

-- 🔹 5. Loop Control: continue + break + exit — ВИПРАВЛЕНО
s("bloop_exit", {
  t("#!/usr/bin/env bash"), t({ "", "" }),
  t("# 🔹 continue/break/exit comparison"), t({ "", "" }),
  t('for x in {'), i(1, "1"), t('..'), i(2, "9"), t('}; do'), t({ "", "\t" }),
  t('echo -n "x is $x. "'), t({ "", "\t" }),
  t('if [[ $x -eq '), i(3, "4"), t(' ]]; then'), t({ "", "\t\t" }),
  t('echo; continue'), t({ "", "\t" }),
  t("fi"), t({ "", "\t" }),
  t('echo "Most numbers get here"'), t({ "", "\t" }),
  t('if [[ $x -eq '), i(4, "6"), t(' ]]; then'), t({ "", "\t\t" }),
  t('echo "🛑 Exiting script at x=$x"'), t({ "", "\t\t" }),
  t("exit 0  # Quit entire script"), t({ "", "\t" }),
  t("fi"), t({ "", "\t" }),
  t('if [[ $x -eq '), i(5, "7"), t(' ]]; then'), t({ "", "\t\t" }),
  t('break  # Exit only the loop'), t({ "", "\t" }),
  t("fi"), t({ "", "done", "" }),
  t('echo "✅ Loop finished normally. x=$x"'),
}),

 -- 🔹 6. while read with break/exit/continue (interactive)
  s("bwhile_read_interactive", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('COUNT=0'), t({ "", "" }),
    t('echo "Type \'finish\' to quit, \'abort\' to exit, \'silent\' to skip output"'), t({ "", "" }),
    t('while read -rp "Say something> " x; do'), t({ "", "\t" }),
    t('if [[ "$x" == "finish" ]]; then'), t({ "", "\t\t" }),
    t("break"), t({ "", "\t" }),
    t("elif [[ \"$x\" == \"abort\" ]]; then"), t({ "", "\t\t" }),
    t("exit 0"), t({ "", "\t" }),
    t("elif [[ \"$x\" == \"silent\" ]]; then"), t({ "", "\t\t" }),
    t("(( COUNT++ ))"), t({ "", "\t\t" }),
    t("continue"), t({ "", "\t" }),
    t("fi"), t({ "", "\t" }),
    t("(( COUNT++ ))"), t({ "", "\t" }),
    t('echo "✅ You said: \'$x\' (total: $COUNT)"'), t({ "", "done", "" }),
    t('echo "🎉 All done. You said $COUNT things."'),
  }),

-- 🔹 4. Loop Control: continue + break — ВИПРАВЛЕНО
s("bloop_control", {
  t("#!/usr/bin/env bash"), t({ "", "" }),
  t("# 🔹 Demonstrate continue/break in for loop"), t({ "", "" }),
  t('for x in {'), i(1, "1"), t('..'), i(2, "9"), t('}; do'), t({ "", "\t" }),
  t('echo -n "x is $x. "'), t({ "", "\t" }),
  t('if [[ $x -eq '), i(3, "4"), t(' ]]; then'), t({ "", "\t\t" }),
  t('echo  # New line'), t({ "", "\t\t" }),
  t('continue  # Skip rest, go to next iteration'), t({ "", "\t" }),
  t("fi"), t({ "", "\t" }),
  -- ✅ ВИПРАВЛЕНО: використано подвійні лапки зовні, щоб апостроф працював
  t("echo \"Most numbers get here, but $"), rep(3), t(" doesn't.\""), t({ "", "\t" }),
  t('if [[ $x -eq '), i(4, "7"), t(' ]]; then'), t({ "", "\t\t" }),
  t('break  # Exit loop completely'), t({ "", "\t" }),
  t("fi"), t({ "", "done", "" }),
  t('echo "Loop finished. Final x=$x"'),
}),

-- 🔹 5. Loop Control: continue + break + exit — ВИПРАВЛЕНО
s("bloop_exit", {
  t("#!/usr/bin/env bash"), t({ "", "" }),
  t("# 🔹 continue/break/exit comparison"), t({ "", "" }),
  t('for x in {'), i(1, "1"), t('..'), i(2, "9"), t('}; do'), t({ "", "\t" }),
  t('echo -n "x is $x. "'), t({ "", "\t" }),
  t('if [[ $x -eq '), i(3, "4"), t(' ]]; then'), t({ "", "\t\t" }),
  t('echo; continue'), t({ "", "\t" }),
  t("fi"), t({ "", "\t" }),
  t('echo "Most numbers get here"'), t({ "", "\t" }),
  t('if [[ $x -eq '), i(4, "6"), t(' ]]; then'), t({ "", "\t\t" }),
  t('echo " Exiting script at x=$x"'), t({ "", "\t\t" }),
  t("exit 0  # Quit entire script"), t({ "", "\t" }),
  t("fi"), t({ "", "\t" }),
  t('if [[ $x -eq '), i(5, "7"), t(' ]]; then'), t({ "", "\t\t" }),
  t('break  # Exit only the loop'), t({ "", "\t" }),
  t("fi"), t({ "", "done", "" }),
  t('echo "✅ Loop finished normally. x=$x"'),
}),

s("bwhile_read_process_subst", {
  t("#!/usr/bin/env bash"), t({ "", "" }),
  t("# 🔹 Fix subshell scope with input redirection"), t({ "", "" }),
  t('COUNT=0'), t({ "", "" }),
  t('while read -r x; do'), t({ "", "\t" }),
  t("(( COUNT++ ))"), t({ "", "\t" }),
  t('echo "Processed: $x (COUNT=$COUNT)"'), t({ "", "done" }),
  -- ✅ ВИПРАВЛЕНО: кожна нода окремо в масиві
  t('  < "'), i(1, "input.txt"), t('"  # ← Input redirection (NOT a pipe!)'), t({ "", "" }),
  t('echo "✅ Final COUNT=$COUNT (preserved!)"'),
}),

 s("bdeclare_demo", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Bash `declare` & Assignment Patterns"), t({ "", "" }),
    
    t("function declare_vs_assign() {"), t({ "", "\t" }),
    t("# 🔹 -i forces integer evaluation"), t({ "", "\t" }),
    t("declare -i a=5"), t({ "", "\t" }),
    t("declare -i b=a+3  # Arithmetic is automatic with -i"), t({ "", "\t" }),
    t('echo "🔢 declare -i b=$b"'), t({ "", "\t" }),
    t({ "", "\t# Without -i, it's string concatenation", "\t" }),
    t("c=5"), t({ "", "\t" }),
    t('d="${c}+3"'), t({ "", "\t" }),
    t('echo "🔤 String concat d=$d"'), t({ "", "}", "" }),
    
    t("function declare_local() {"), t({ "", "\t" }),
    t("local a='local a'"), t({ "", "\t" }),
    t("declare b='local b'  # ⚠️  `declare` inside func also implies local"), t({ "", "\t" }),
    t('echo "📍 $a"'), t({ "", "\t" }),
    t('echo "📍 $b"'), t({ "", "}", "" }),
    
    t("function declare_export() {"), t({ "", "\t" }),
    t("declare -x MY_EXPORT='exported'"), t({ "", "\t" }),
    t("env | grep MY_EXPORT || true"), t({ "", "\t" }),
    t("unset MY_EXPORT"), t({ "", "\t" }),
    t("env | grep MY_EXPORT || true  # Should be empty"), t({ "", "}", "" }),
    
    t("function declare_integer() {"), t({ "", "\t" }),
    t("declare -i a=$((3*5))"), t({ "", "\t" }),
    t('echo "🔢 declare -i a=$a"'), t({ "", "\t" }),
    t("(( b=3*5 ))  # Alternative: arithmetic context"), t({ "", "\t" }),
    t('echo "🔢 arithmetic b=$b"'), t({ "", "}", "" }),
    
    t("function declare_indexed_array() {"), t({ "", "\t" }),
    t("declare -a arr=('a' 'b' 'c')"), t({ "", "\t" }),
    t('echo "📦 Array: ${arr[@]}"'), t({ "", "\t" }),
    t('echo "🔢 Length: ${#arr[@]}"'), t({ "", "}", "" }),
    
    t("function declare_readonly() {"), t({ "", "\t" }),
    t("declare -r CONST='immutable'"), t({ "", "\t" }),
    t('echo "🔒 Before: $CONST"'), t({ "", "\t" }),
    t("# 🔹 Reassigning will FAIL (Bash prints error)"), t({ "", "\t" }),
    t("CONST='mutable' 2>/dev/null || echo '⚠️  Cannot modify readonly variable'"), t({ "", "}", "" }),
    
    t({ "", "# 🔹 Run demonstrations" }),
    t("declare_vs_assign"), t({ "", "echo ''" }),
    t("declare_local"), t({ "", "echo ''" }),
    t("declare_export"), t({ "", "echo ''" }),
    t("declare_integer"), t({ "", "echo ''" }),
    t("declare_indexed_array"), t({ "", "echo ''" }),
    t("declare_readonly"),
  }),

  s("bparam_defaults", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Parameter Expansion: Default Values & Assignment"), t({ "", "" }),
    t("function echo_lang() {"), t({ "", "\t" }),
    t('# 🔹 :- returns default if unset/empty, DOES NOT assign'), t({ "", "\t" }),
    t('echo "${1:-en-us}"'), t({ "", "\t" }),
    t('# ⚠️  = assigns default (works in Bash, fails in POSIX sh)'), t({ "", "\t" }),
    t('echo "${1=en-us}"'), t({ "", "\t" }),
    t('# ⚠️  := assigns default if unset/empty (Bash only)'), t({ "", "\t" }),
    t('echo "${1:=en-us}"'), t({ "", "}", "" }),
    t({ "", "# 🔹 Standard variable behavior" }),
    t("unset lang  # Clear for clean demo"), t({ "", "" }),
    t('echo "${lang:-en-us}"'), t({ "", "" }),
    t('echo "${lang=en-us}"'), t({ "", "" }),
    t('echo "${lang:=en-us}"'), t({ "", "" }),
    t({ "", "lang='ja-jp'" }), t({ "", "" }),
    t('echo "${lang:-en-us}"'), t({ "", "" }),
    t('echo "${lang=en-us}"'), t({ "", "" }),
    t('echo "${lang:=en-us}"'), t({ "", "" }),
    t({ "", "# 🔹 Positional parameter tests" }),
    t("echo_lang 'de-de'"), t({ "", "" }),
    t("echo_lang  # Empty $1 triggers defaults"),
  }),

    -- 🔹 1. Path Parameter Expansion (% %% # ##)
  s("bparam_path", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t('path="'), i(1, "apple/banana/cherry"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Remove SHORTEST match from end (%)" }),
    t('omit_last="${path%/*}"'), t({ "", "" }),
    t({ "", "# 🔹 Remove LONGEST match from end (%%)" }),
    t('omit_last_all="${path%%/*}"'), t({ "", "" }),
    t({ "", "# 🔹 Remove SHORTEST match from start (#)" }),
    t('omit_first="${path#*/}"'), t({ "", "" }),
    t({ "", "# 🔹 Remove LONGEST match from start (##)" }),
    t('omit_first_all="${path##*/}"'), t({ "", "" }),
    t({ "", 'echo "📉 omit_last: $omit_last"', "" }),
    t({ '', 'echo "📉 omit_last_all: $omit_last_all"', "" }),
    t({ '', 'echo "📈 omit_first: $omit_first"', "" }),
    t({ '', 'echo "📈 omit_first_all: $omit_first_all"', "" }),
  }),

  -- 🔹 2. Unicode & UTF-8 Hex Escaping
  s("bunicode_hex", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Unicode & UTF-8 Hex Escaping with echo -e"), t({ "", "" }),
    t({ "", "# 🔹 Basic Characters" }),
    t('echo -e "\\x61"              # ASCII "a" (hex)'), t({ "", "" }),
    t('echo -e "\\u0061"            # Unicode "a" (requires Bash 4.2+)'), t({ "", "" }),
    t({ "", "# 🔹 Supplementary/Emoji (UTF-8 hex)" }),
    t('echo -e "\\xF0\\x9F\\x91\\x8D"  # 👍 (U+1F44D) - 4-byte UTF-8'), t({ "", "" }),
    t({ "", "# 🔹 Precomposed vs Decomposed" }),
    t('echo -e "\\xE1"              # ❌ Invalid UTF-8 (isolated byte > 0x7F)'), t({ "", "" }),
    t('echo -e "\\xC3\\xA1"          # ✅ á (precomposed: U+00E1)'), t({ "", "" }),
    t('echo -e "\\x61\\xCC\\x81"      # ✅ á (decomposed: a + combining acute)'),
  }),

  -- 🔹 3. Safe 'Press Key' Prompts
  s("bread_prompt", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Robust 'Press Key' Prompts"), t({ "", "" }),
    t("function wait_return() {"), t({ "", "\t" }),
    t('read -rp "Press RETURN to continue..."'), t({ "", "}", "" }),
    t("function wait_any() {"), t({ "", "\t" }),
    t('read -rsp "Press ANY key to continue..." -n 1 key'), t({ "", "\t" }),
    t('echo  # Move to next line after keypress'), t({ "", "}", "" }),
    t({ "", "# 🔹 Usage" }),
    t("wait_return"), t({ "", "" }),
    t("wait_any"),
  }),

    s("bprompt_utils", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Interactive Prompt Utilities"), t({ "", "" }),
    t("function prompt_question() {"), t({ "", "\t" }),
    t('local question="${1}"'), t({ "", "\t" }),
    t('local default_answer="${2}"'), t({ "", "\t" }),
    t('read -rp "${question} (${default_answer}) " answer'), t({ "", "\t" }),
    t('[[ -z "${answer}" ]] && answer="${default_answer}"'), t({ "", "\t" }),
    t('echo "${answer}"'), t({ "", "}", "" }),
    t("function multiple_choice() {"), t({ "", "\t" }),
    t('local question="${1}"'), t({ "", "\t" }),
    t('local csv="${2}"'), t({ "", "\t" }),
    t('local default_idx="${3}"  # Integer index'), t({ "", "\t" }),
    t('local buf="${question}"'), t({ "", "\t" }),
    t("buf+=$'\\n'"), t({ "", "\t" }),
    t("IFS=',' read -r -a choices <<< \"${csv}\""), t({ "", "\t" }),
    t('for (( i=0; i<${#choices[@]}; i++ )); do'), t({ "", "\t\t" }),
    t('buf+="${i} - ${choices[i]}"'), t({ "", "\t\t" }),
    t("buf+=$'\\n'"), t({ "", "\t" }),
    t("done"), t({ "", "\t" }),
    t('read -rp "${buf}Your choice (${default_idx} - ${choices[${default_idx}]}) " answer'), t({ "", "\t" }),
    t('if [[ -z "${answer}" ]]; then'), t({ "", "\t\t" }),
    t('answer="${choices[${default_idx}]}"'), t({ "", "\t" }),
    t("else"), t({ "", "\t\t" }),
    t('answer="${choices[${answer}]}"'), t({ "", "\t" }),
    t("fi"), t({ "", "\t" }),
    t('echo "${answer}"'), t({ "", "}", "" }),
    t({ "", "# 🔹 Usage Examples" }),
    t('path=$(prompt_question "'), i(1, "Enter path to save file?"), t('" "'), i(2, "/home/me"), t('")'), t({ "", "" }),
    t('echo "✅ User entered: ${path}"'), t({ "", "" }),
    t('direction=$(multiple_choice "'), i(3, "Where do you want to go?"), t('" "'), i(4, "North,South,East,West"), t('" '), i(5, "0"), t(')'), t({ "", "" }),
    t('echo "✅ User wants to go: ${direction}"'),
  }),

    s("bloops_all", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Bash Loop Patterns: Arrays & Files"), t({ "", "" }),
    t("array=("), i(1, "9 8 7"), t(")"), t({ "", "" }),
    t("size=${#array[@]}"), t({ "", "" }),
    t({ "", "# 🔹 1. While Loop (index-based)" }),
    t("j=0"), t({ "", "" }),
    t("while [[ $j -lt $size ]]; do"), t({ "", "\t" }),
    t('printf "%s " "${array[j]}"'), t({ "", "\t" }),
    t("((j++))"), t({ "", "done" }),
    t({ "", 'echo', "" }),
    t({ "", "# 🔹 2. Until Loop (index-based)" }),
    t("j=0"), t({ "", "" }),
    t("until [[ $j -eq $size ]]; do"), t({ "", "\t" }),
    t('printf "%s " "${array[j]}"'), t({ "", "\t" }),
    t("((j++))"), t({ "", "done" }),
    t({ "", 'echo', "" }),
    t({ "", "# 🔹 3. C-style For Loop" }),
    t("for (( i=0; i<size; i++ )); do"), t({ "", "\t" }),
    t('printf "%s " "${array[i]}"'), t({ "", "done" }),
    t({ "", 'echo', "" }),
    t({ "", "# 🔹 4. Brace Expansion For Loop (LITERAL values only!)" }),
    t("for i in {"), i(2, "0..2"), t("}; do"), t({ "", "\t" }),
    t('printf "%s " "${array[i]}"'), t({ "", "done" }),
    t({ "", 'echo', "" }),
    t({ "", "# 🔹 5. For-In Loop (iterate elements directly)" }),
    t('for item in "${array[@]}"; do'), t({ "", "\t" }),
    t('printf "%s " "$item"'), t({ "", "done" }),
    t({ "", 'echo', "" }),
    t({ "", "# 🔹 6. For-In with space-separated values" }),
    t("for char in "), i(3, "h e l l o"), t("; do"), t({ "", "\t" }),
    t('printf "%s " "$char"'), t({ "", "done" }),
    t({ "", 'echo', "" }),
    t({ "", "# 🔹 7. For-In with file globbing" }),
    t("for file in "), i(4, "/var/log/*.log"), t("; do"), t({ "", "\t" }),
    t('echo "${file}"'), t({ "", "done" }),
  }),

    -- 🔹 1. Pass Array via CSV String
  s("bfunc_array_csv", {
    t("function pass_array_csv() {"), t({ "", "\t" }),
    t('local person="$1"'), t({ "", "\t" }),
    t('local csv="$2"'), t({ "", "\t" }),
    t('local city="$3"'), t({ "", "" }),
    t("\t# Convert CSV string to array"), t({ "", "\t" }),
    t("IFS=',' read -r -a pets <<< \"${csv}\""), t({ "", "" }),
    t('\tfor pet in "${pets[@]}"; do'), t({ "", "\t\t" }),
    t('echo "${person} owns a ${pet} in ${city}"'), t({ "", "\t" }),
    t("done"), t({ "", "}", "" }),
    t({ "", "# 🔹 Usage: Convert array → CSV → pass to function" }),
    t('declare -a pets=("'), i(1, "cat dog bird"), t('")'), t({ "", "" }),
    t('pets_csv=$(IFS=,; echo "${pets[*]}")'), t({ "", "" }),
    t('pass_array_csv "'), i(2, "Sam"), t('" "${pets_csv}" "'), i(3, "Boston"), t('"'),
  }),

  -- 🔹 2. Return via stdout + Command Substitution
  s("bfunc_return_echo", {
    t("function build_string_echo() {"), t({ "", "\t" }),
    t('local prefix="$1"'), t({ "", "\t" }),
    t('local word="$2"'), t({ "", "" }),
    t("\t# Output to stdout (captured by caller)"), t({ "", "\t" }),
    t('echo "${prefix}-${word}"'), t({ "", "\t" }),
    t("return 0"), t({ "", "}", "" }),
    t({ "", "# 🔹 Capture output via $()" }),
    t('output=$(build_string_echo "'), i(1, "hello"), t('" "'), i(2, "world"), t('")'), t({ "", "" }),
    t('echo "✅ Result: ${output}"'), t({ "", "" }),
    t('echo "🔙 Exit code: $?  (0 = success)"'),
  }),

  -- 🔹 3. Return via Global Variable
  s("bfunc_return_global", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Initialize global return variable"), t({ "", "" }),
    t('RESULT=""'), t({ "", "" }),
    t("function build_string_global() {"), t({ "", "\t" }),
    t('local prefix="$1"'), t({ "", "\t" }),
    t('local word="$2"'), t({ "", "\t" }),
    t('RESULT="${prefix}-${word}"'), t({ "", "}", "" }),
    t({ "", "# 🔹 Usage" }),
    t('build_string_global "'), i(1, "hello"), t('" "'), i(2, "world"), t('"'), t({ "", "" }),
    t('echo "✅ Result: ${RESULT}"'),
  }),

  -- 🔹 4. Arguments as Array (`"$@"`)
  s("bfunc_args_array", {
    t("function print_args_as_array() {"), t({ "", "\t" }),
    t('# Capture all positional params into an array'), t({ "", "\t" }),
    t('declare -a args=("$@")'), t({ "", "" }),
    t('\tfor arg in "${args[@]}"; do'), t({ "", "\t\t" }),
    t('printf "%s " "${arg}"'), t({ "", "\t" }),
    t("done"), t({ "", "\t" }),
    t("echo  # Newline"), t({ "", "}", "" }),
    t({ "", "# 🔹 Usage" }),
    t('print_args_as_array '), i(1, "cat dog horse bird"), t({ "", "" }),
    t('# Quotes preserve spaces inside arguments:'), t({ "", "" }),
    t('# print_args_as_array "red apple" "blue sky" "green grass"'),
  }),

  s("bif_conditions_demo", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Conditional Logic: String, Numeric & Version Checks"), t({ "", "" }),
    t('declare p1_first="'), i(1, "John"), t('"'), t({ "", "" }),
    t('declare p1_last="'), i(2, "Lee"), t('"'), t({ "", "" }),
    t('declare p2_first="'), i(3, "Maggie"), t('"'), t({ "", "" }),
    t('declare p2_last="'), i(4, "Lee"), t('"'), t({ "", "" }),
    t("declare a="), i(5, "75"), t({ "", "" }),
    t("declare b="), i(6, "35"), t({ "", "" }),
    t("declare major_ver="), i(7, "11"), t({ "", "" }),
    t("declare minor_ver="), i(8, "8"), t({ "", "" }),
    t({ "", "# 🔹 String Comparison (Unified to [[ ]])" }),
    t('if [[ "${p1_first}" == "John" ]] && [[ "${p1_last}" == "Lee" ]]; then'), t({ "", "\t" }),
    t('echo "✅ First and last names match John and Lee respectively"'), t({ "", "fi", "" }),
    t('if [[ "${p1_last}" == "${p2_last}" ]] || [[ "${p1_first}" == "${p2_first}" ]]; then'), t({ "", "\t" }),
    t('echo "✅ First or last names match"'), t({ "", "fi", "" }),
    t({ "", "# 🔹 Numeric Range Checks" }),
    t('if [[ ${a} -ge 50 ]] && [[ ${a} -le 100 ]]; then'), t({ "", "\t" }),
    t('echo "✅ Integer ${a} is between 50 and 100"'), t({ "", "fi", "" }),
    t('if [[ ${b} -lt 50 ]] || [[ ${b} -gt 100 ]]; then'), t({ "", "\t" }),
    t('echo "✅ Integer ${b} is outside of 50-100"'), t({ "", "fi", "" }),
    t({ "", "# 🔹 Version/Complex Logic: External vs Internal &&/||" }),
    t("# External: separate [[ ]] blocks (safer for complex pipes)"), t({ "", "" }),
    t('if [[ "${major_ver}" -eq 10 ]] && [[ "${minor_ver}" -ge 10 ]] || [[ "${major_ver}" -ge 11 ]]; then'), t({ "", "\t" }),
    t('echo "✅ Above version 10.10. Supported."'), t({ "", "else", "\t" }),
    t('echo "❌ Below version 10.10. Not supported."'), t({ "", "fi", "" }),
    t({ "", "# Internal: single [[ ]] block (cleaner, Bash-native)" }),
    t('if [[ "${major_ver}" -eq 10 && "${minor_ver}" -ge 10 || "${major_ver}" -ge 11 ]]; then'), t({ "", "\t" }),
    t('echo "✅ (Internal) Above version 10.10. Supported."'), t({ "", "else", "\t" }),
    t('echo "❌ (Internal) Below version 10.10. Not supported."'), t({ "", "fi" }),
  }),

    s("barray_ops", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Bash Array Operations: Init, Slice, Modify, Read"), t({ "", "" }),
    t("function iterate() {"), t({ "", "\t" }),
    t('local items=("$@")'), t({ "", "\t" }),
    t('for item in "${items[@]}"; do'), t({ "", "\t\t" }),
    t('echo "${item}"'), t({ "", "\t" }),
    t("done"), t({ "", "}", "" }),
    t({ "", "# 🔹 1. Initialization & Basic Access" }),
    t('declare -a pets=('), i(1, "'bird' 'cat' 'dog'"), t(')'), t({ "", "" }),
    t('echo "📦 All: ${pets[@]}"'), t({ "", "" }),
    t('echo "📏 Length: ${#pets[@]}"'), t({ "", "" }),
    t('echo "🔍 Index 1: ${pets[1]}"'), t({ "", "" }),
    t('unset pets'), t({ "", "" }),
    t('echo "🗑️  After unset: ${pets[@]:-<empty>}"'), t({ "", "" }),
    t({ "", "# 🔹 2. Slicing & Pattern Substitution" }),
    t("declare -a animals=('bird' 'cat' 'dog' 'hamster')"), t({ "", "" }),
    t('echo "🔪 Slice [1:3]: ${animals[@]:1:3}"'), t({ "", "" }),
    t('echo "🔪 Slice [1:]: ${animals[@]:1}"'), t({ "", "" }),
    t('echo "🔄 Subst: ${animals[@]/bird/parrot}"'), t({ "", "" }),
    t('echo "🔄 Pattern: ${animals[@]/bi*/canary}"'), t({ "", "" }),
    t({ "", "# 🔹 3. Appending, Removing & Merging" }),
    t("animals+=('mouse')"), t({ "", "" }),
    t("animals=(\"${animals[@]}\" 'turtle')"), t({ "", "" }),
    t('echo "📥 After append: ${animals[@]}"'), t({ "", "" }),
    t("unset animals[1]"), t({ "", "" }),
    t('echo "🗑️  Remove index 1: ${animals[@]}"'), t({ "", "" }),
    t('echo "🧹 Remove pattern: ${animals[@]/bi*/}"'), t({ "", "" }),
    t('declare -a farm=('), i(2, "'pig' 'cow' 'chicken'"), t(')'), t({ "", "" }),
    t('declare -a zoo=("${animals[@]}" "${farm[@]}")'), t({ "", "" }),
    t('echo "🤝 Merged: ${zoo[@]}"'), t({ "", "" }),
    t({ "", "# 🔹 4. File to Array & Safe Iteration" }),
    t("# 💡 Modern Bash: mapfile/readarray is safer than IFS+read"), t({ "", "" }),
    t('mapfile -t file_lines < "sample.txt" 2>/dev/null || true'), t({ "", "" }),
    t('echo "📄 File contents: ${file_lines[*]}"'), t({ "", "" }),
    t({ "", "# 🔹 Pass Array to Function" }),
    t('declare -a demo=("apple" "banana" "cherry")'), t({ "", "" }),
    t('iterate "${demo[@]}"'),
  }),

    s("bmath_arithmetic", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Bash Arithmetic: Floats, Integers & Modern Syntax"), t({ "", "" }),
    t({ "", "# 🔹 1. Floating Point (Bash supports ONLY integers)" }),
    t("# ❌ a=$((1+2.5))  # FAILS: syntax error near unexpected token '.'"), t({ "", "" }),
    t("# ✅ Use 'bc' or 'awk' for decimals"), t({ "", "" }),
    t('a=$(echo "1 + 2.5" | bc)'), t({ "", "" }),
    t('echo "🔢 Float: $a"'), t({ "", "" }),
    t('a=$(echo "$a + 0.5" | bc)'), t({ "", "" }),
    t('echo "🔢 Float + 0.5: $a"'), t({ "", "" }),
    t({ "", "# 🔹 2. String vs Integer Declaration" }),
    t('str_val="'), i(1, "1+2"), t('"'), t({ "", "" }),
    t('echo "📝 String (literal): $str_val"'), t({ "", "" }),
    t("declare -i int_val"), t({ "", "" }),
    t('int_val="'), i(2, "1+2"), t('"'), t({ "", "" }),
    t('echo "🔢 Integer (auto-eval): $int_val"'), t({ "", "" }),
    t({ "", "# 🔹 3. Modern Integer Arithmetic ($(( )) & (( ))" }),
    t("x=$((1 + 2))"), t({ "", "" }),
    t('echo "➕ Result: $x"'), t({ "", "" }),
    t("x=$((x + 3))"), t({ "", "" }),
    t('echo "➕ Updated: $x"'), t({ "", "" }),
    t("((x++))"), t({ "", "" }),
    t('echo "📈 Incremented: $x"'), t({ "", "" }),
    t("x=$((x ** 2))"), t({ "", "" }),
    t('echo "🔲 Squared: $x"'), t({ "", "" }),
    t({ "", "# 🔹 4. Legacy 'let' (avoid in modern scripts)" }),
    t('let y=1+2'), t({ "", "" }),
    t('echo "🔢 let result: $y"'), t({ "", "" }),
    t('let "y = 1 + 2"  # Quotes allow spaces'), t({ "", "" }),
    t('echo "🔢 let spaced: $y"'), t({ "", "" }),
    t('let y=y+3'), t({ "", "" }),
    t('echo "🔢 let increment: $y"'), t({ "", "" }),
    t('let y++'), t({ "", "" }),
    t('echo "🔢 let post-increment: $y"'), t({ "", "" }),
    t('let y=y**2'), t({ "", "" }),
    t('echo "🔢 let squared: $y"'), t({ "", "" }),
  }),


  s("bsed_cross_platform", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Cross-Platform sed Operations (macOS vs Linux)"), t({ "", "" }),
    t('CLONED_FILE="'), i(1, "sshd_config.copy"), t('"'), t({ "", "" }),
    t("# 📄 Clone config (ignored by git)"), t({ "", "" }),
    t('cp sshd_config "$CLONED_FILE"'), t({ "", "" }),
    t({ "", "# 🔹 Detect OS for sed -i compatibility" }),
    t('if [[ "$(uname)" == "Darwin" ]]; then'), t({ "", "\t" }),
    t('SED_INPLACE=(-i "")'), t({ "", "else", "\t" }),
    t('SED_INPLACE=(-i)'), t({ "", "fi", "" }),
    t({ "", "# 🔹 1. Replace matching lines" }),
    t("sed \"${SED_INPLACE[@]}\" 's/.*Port .*/Port 6543/g' \"$CLONED_FILE\""), t({ "", "" }),
    t({ "", "# 🔹 2. Delete matching lines" }),
    t("sed \"${SED_INPLACE[@]}\" '/^PermitRootLogin yes/d' \"$CLONED_FILE\""), t({ "", "" }),
    t({ "", "# 🔹 3. Delete range (inclusive)" }),
    t("sed \"${SED_INPLACE[@]}\" '/^AddressFamily any/,/^ListenAddress ::/d' \"$CLONED_FILE\""), t({ "", "" }),
    t({ "", "# 🔹 4. Append AFTER match (a)" }),
    t("if [[ \"$(uname)\" == \"Darwin\" ]]; then"), t({ "", "\t" }),
    t([[sed -i "" -e '/^X11Forwarding/a\' -e 'X11DisplayOffset 10' "$CLONED_FILE"]]), t({ "", "else", "\t" }),
    t("sed -i '/^X11Forwarding.*/a X11DisplayOffset 10' \"$CLONED_FILE\""), t({ "", "fi", "" }),
    t({ "", "# 🔹 5. Insert BEFORE match (i)" }),
    t("if [[ \"$(uname)\" == \"Darwin\" ]]; then"), t({ "", "\t" }),
    t([[sed -i "" -e '/^X11Forwarding/i\' -e 'X11UseLocalhost yes' "$CLONED_FILE"]]), t({ "", "else", "\t" }),
    t("sed -i '/^X11Forwarding.*/i X11UseLocalhost yes' \"$CLONED_FILE\""), t({ "", "fi" }),
  }),

    -- 🔹 1. Terminal Colors via tput
  s("bcolors_tput", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Safe Terminal Colors via tput"), t({ "", "" }),
    t([[BOLD=$(tput bold 2>/dev/null || true)]]), t({ "", "" }),
    t([[RED=$(tput setaf 1 2>/dev/null || true)]]), t({ "", "" }),
    t([[RESET=$(tput sgr0 2>/dev/null || true)]]), t({ "", "" }),
    t({ "", "# 🔹 Usage" }),
    t([[echo "${RED}${BOLD}Hello World${RESET}"]]), t({ "", "" }),
    t([[echo "Normal text (color reset works)"]]),
  }),

  -- 🔹 2. Trap with Lockfile/Cleanup
  s("btrap_lockfile", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Trap with Lockfile/Cleanup"), t({ "", "" }),
    t([[LOCKFILE=$(mktemp) || exit 1]]), t({ "", "" }),
    t("function cleanup() {"), t({ "", "\t" }),
    t('local file="$1"'), t({ "", "\t" }),
    t('echo "🧹 Removing ${file}..."'), t({ "", "\t" }),
    t('rm -f "$file"'), t({ "", "}", "" }),
    t({ "", "# 🔹 Register trap (single quotes delay expansion until execution)" }),
    t([[trap 'cleanup "$LOCKFILE"' EXIT INT TERM]]), t({ "", "" }),
    t('echo "🚀 Running with lockfile: $LOCKFILE"'), t({ "", "" }),
    t({ "", "# 🔹 Main loop (safe, non-blocking)" }),
    t("while true; do"), t({ "", "\t" }),
    t("sleep 1"), t({ "", "done" }),
  }),

  -- 🔹 3. Trap: SIGHUP (Reload) + EXIT (Cleanup)
  s("btrap_sighup", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Trap: SIGHUP (Reload) + EXIT (Cleanup)"), t({ "", "" }),
    t('CONFIG_FILE="'), i(1, "config"), t('"'), t({ "", "" }),
    t("function load_config() {"), t({ "", "\t" }),
    t('local cfg="$1"'), t({ "", "\t" }),
    t('echo "🔄 Loading $cfg..."'), t({ "", "\t" }),
    t('[[ -f "$cfg" ]] && . "$cfg"'), t({ "", "}", "" }),
    t("function cleanup() {"), t({ "", "\t" }),
    t('echo "🧹 Cleaning up & exiting..."'), t({ "", "}", "" }),
    t({ "", "# 🔹 Register signal handlers" }),
    t([[trap 'load_config "$CONFIG_FILE"' HUP]]), t({ "", "" }),
    t([[trap cleanup EXIT INT TERM]]), t({ "", "" }),
    t({ "", "# 🔹 Initial load" }),
    t('load_config "$CONFIG_FILE"'), t({ "", "" }),
    t('echo "🚀 Running... (kill -HUP $$ to reload)"'), t({ "", "" }),
    t("sleep infinity"),
  }),

  -- 🔹 4. Simple EXIT Trap
  s("btrap_simple", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Simple EXIT Trap"), t({ "", "" }),
    t("function cleanup() {"), t({ "", "\t" }),
    t('echo "🧹 Cleanup triggered"'), t({ "", "\t" }),
    t('echo "👋 Exit..."'), t({ "", "}", "" }),
    t("trap cleanup EXIT"), t({ "", "" }),
    t('echo "🚀 Running..."'), t({ "", "" }),
    t("sleep "), i(1, "10"), t({ "", "" }),
    t('echo "✅ Done"'),
  }),

  s("bport_check", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 TCP Port Check with Retries & Final Wait"), t({ "", "" }),
    t("readonly WAIT="), i(1, "2"), t({ "", "" }),
    t("readonly FINAL_WAIT="), i(2, "1"), t({ "", "" }),
    t("readonly PORT="), i(3, "27017"), t({ "", "" }),
    t("readonly RETRIES="), i(4, "3"), t({ "", "" }),
    t({ "", "function check_tcp_port() {" }),
    t('\tprintf "Connecting to port %s" "$PORT"'), t({ "", "" }),
    t("\tfor (( i=1; i<=RETRIES; i++ )); do"), t({ "", "\t\t" }),
    t('\t\tif nc -z -w 1 localhost "$PORT" >/dev/null 2>&1; then'), t({ "", "\t\t\t" }),
    t('\t\t\techo -e "\\n✅ Port $PORT is open"'), t({ "", "\t\t\t" }),
    t('\t\t\techo "⏳ Waiting $FINAL_WAIT seconds for final init..."'), t({ "", "\t\t\t" }),
    t("\t\t\tsleep \"$FINAL_WAIT\""), t({ "", "\t\t\t" }),
    t('\t\t\techo "🚀 Starting main program..."'), t({ "", "\t\t\t" }),
    t("\t\t\t# TODO: exec your_command_here"), t({ "", "\t\t\t" }),
    t("\t\t\treturn 0"), t({ "", "\t\t" }),
    t("\t\telse"), t({ "", "\t\t\t" }),
    t('\t\t\tprintf "."'), t({ "", "\t\t\t" }),
    t("\t\t\t(( i < RETRIES )) && sleep \"$WAIT\""), t({ "", "\t\t" }),
    t("\t\tfi"), t({ "", "\t" }),
    t("\tdone"), t({ "", "\t" }),
    t('\t\techo -e "\\n❌ Port $PORT is closed after $RETRIES retries"'), t({ "", "\t" }),
    t("\t\treturn 1"), t({ "", "}", "" }),
    t("check_tcp_port"), t({ "", "" }),
    t('echo "Script exit code: $?"'),
  }),

  s("b_ls_wrapper", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("VERSION="), i(1, "'v1.2b'"), t({ "", "" }),
    t("function usage_exit() {"), t({ "", "\t" }),
    t('echo "Usage: $0 [color|last|len|long]"'), t({ "", "\t" }),
    t("exit 1"), t({ "", "}", "" }),
    t({ "", "function show_name_lengths() {" }),
    t('\tls -1 "$@" | while IFS= read -r fn; do'), t({ "", "\t\t" }),
    t("printf '%3d %s\\n' \"${#fn}\" \"$fn\""), t({ "", "\t" }),
    t("done | sort -n"), t({ "", "}", "" }),
    t({ "", "# 🔹 Argument validation" }),
    t('[[ $# -lt 1 ]] && usage_exit'), t({ "", "" }),
    t('sub="$1"; shift'), t({ "", "" }),
    t({ "", "# 🔹 Main dispatcher" }),
    t('case "$sub" in'), t({ "", "\t" }),
    t("color)"), t({ "", "\t\t" }),
    t('ls -N --color=always -T 0 "$@"'), t({ "", "\t\t" }),
    t(";;"), t({ "", "" }),
    t("last|latest)"), t({ "", "\t\t" }),
    t('ls -lrt "$@" | tail -n "${1:-5}"'), t({ "", "\t\t" }),
    t(";;"), t({ "", "" }),
    t("len*)"), t({ "", "\t\t" }),
    t('show_name_lengths "$@"'), t({ "", "\t\t" }),
    t(";;"), t({ "", "" }),
    t("long)"), t({ "", "\t\t" }),
    t('show_name_lengths "$@" | tail -n 1'), t({ "", "\t\t" }),
    t(";;"), t({ "", "" }),
    t("*)"), t({ "", "\t\t" }),
    t('echo "❌ Unknown command: $sub" >&2'), t({ "", "\t\t" }),
    t("usage_exit"), t({ "", "\t" }),
    t("esac"),
  }),

    -- 🔹 1. Practical Demo: Parse Customer Subnet String
  s("bparam_expand_demo", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Parameter Expansion Demo: Parse 'Name subnet IP/CIDR'"), t({ "", "" }),
    t('input="'), i(1, "Acme Inc subnet 10.11.12.13/24"), t('"'), t({ "", "" }),
    t({ "", 'echo "📥 Input: $input"', "" }),
    t({ "", "# 🔹 Extract components" }),
    t('name="${input%% subnet*}"  # Remove " subnet..." to end'), t({ "", "" }),
    t('subnet="${input##* }"      # Remove everything before last space'), t({ "", "" }),
    t('ip="${subnet%%/*}"         # Remove "/CIDR" to end'), t({ "", "" }),
    t('cidr="${subnet##*/}"       # Remove everything before "/"'), t({ "", "" }),
    t({ "", "# 🔹 Build firewall object name" }),
    t('fw="${input// /_}"         # Spaces → underscores'), t({ "", "" }),
    t('fw="${fw//\\//-}"          # Slashes → hyphens'), t({ "", "" }),
    t('fw="${fw,,}"               # Lowercase'), t({ "", "" }),
    t({ "", 'echo "📤 Results:"', "" }),
    t('printf "  Name: %s\\n" "$name"'), t({ "", "" }),
    t('printf "  Subnet: %s\\n" "$subnet"'), t({ "", "" }),
    t('printf "  IP: %s\\n" "$ip"'), t({ "", "" }),
    t('printf "  CIDR: %s\\n" "$cidr"'), t({ "", "" }),
    t('printf "  FW Object: %s\\n" "$fw"'),
  }),

  -- 🔹 2. Complete Reference Cheat Sheet
  s("bparam_expand_ref", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Bash Parameter Expansion Reference"), t({ "", "" }),
    t({ "", "# === REMOVAL PATTERNS ===" }),
    t("# 🔹 Remove shortest match from START"), t({ "", "" }),
    t('# ${var#pattern}     # "foo/bar/baz" → ${var#*/} → "bar/baz"'), t({ "", "" }),
    t("# 🔹 Remove longest match from START"), t({ "", "" }),
    t('# ${var##pattern}    # "foo/bar/baz" → ${var##*/} → "baz"'), t({ "", "" }),
    t("# 🔹 Remove shortest match from END"), t({ "", "" }),
    t('# ${var%pattern}     # "foo/bar/baz" → ${var%/*} → "foo/bar"'), t({ "", "" }),
    t("# 🔹 Remove longest match from END"), t({ "", "" }),
    t('# ${var%%pattern}    # "foo.tar.gz" → ${var%%.*} → "foo"'), t({ "", "" }),
    t({ "", "# === REPLACEMENT PATTERNS ===" }),
    t("# 🔹 Replace FIRST occurrence"), t({ "", "" }),
    t('# ${var/pat/repl}    # "a-b-c" → ${var/-/X} → "aXb-c"'), t({ "", "" }),
    t("# 🔹 Replace ALL occurrences"), t({ "", "" }),
    t('# ${var//pat/repl}   # "a-b-c" → ${var//-/X} → "aXbXc"'), t({ "", "" }),
    t("# 🔹 Replace at START / END"), t({ "", "" }),
    t('# ${var/#pat/repl}   # Replace if pattern at beginning'), t({ "", "" }),
    t('# ${var/%pat/repl}   # Replace if pattern at end'), t({ "", "" }),
    t({ "", "# === CASE MODIFICATION ===" }),
    t("# 🔹 Uppercase first / all matching"), t({ "", "" }),
    t('# ${var^pat}         # "hello" → ${var^h} → "Hello"'), t({ "", "" }),
    t('# ${var^^pat}        # "hello" → ${var^^[aeiou]} → "HEllO"'), t({ "", "" }),
    t("# 🔹 Lowercase first / all matching"), t({ "", "" }),
    t('# ${var,pat}         # "HELLO" → ${var,H} → "hELLO"'), t({ "", "" }),
    t('# ${var,,pat}        # "HELLO" → ${var,,[A-Z]} → "hello"'), t({ "", "" }),
    t({ "", "# === SUBSTRING & DEFAULTS ===" }),
    t("# 🔹 Substring extraction"), t({ "", "" }),
    t('# ${var:offset}          # "abcdef" → ${var:2} → "cdef"'), t({ "", "" }),
    t('# ${var:offset:length}   # "abcdef" → ${var:2:3} → "cde"'), t({ "", "" }),
    t("# 🔹 Default values"), t({ "", "" }),
    t('# ${var:-default}    # Use default if unset/empty (no assign)'), t({ "", "" }),
    t('# ${var:=default}    # Assign default if unset/empty'), t({ "", "" }),
    t('# ${var:+alternate}  # Use alternate if SET (opposite of :-)'), t({ "", "" }),
    t('# ${var:?error}      # Exit with error if unset'), t({ "", "" }),
    t({ "", "# === METADATA & TRANSFORMATION ===" }),
    t("# 🔹 Length, keys, attributes"), t({ "", "" }),
    t('# ${#var}            # Length of string'), t({ "", "" }),
    t('# ${!arr[@]}         # Array indexes/keys'), t({ "", "" }),
    t('# ${!prefix*}        # Variable names starting with prefix'), t({ "", "" }),
    t("# 🔹 Bash 4.4+ transformations"), t({ "", "" }),
    t('# ${var@Q}           # Shell-quoted (safe for eval)'), t({ "", "" }),
    t('# ${var@E}           # Expand escape sequences'), t({ "", "" }),
    t('# ${var@P}           # Expand as prompt string'), t({ "", "" }),
    t('# ${var@A}           # Output as declare -a statement'), t({ "", "" }),
    t('# ${var@a}           # Return attribute flags'),
  }),

  s("assoc_array_demo", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Bash Associative Arrays (Hashes) – Complete Demo"), t({ "", "" }),
    t('FORMAT="fmt --width 70 --split-only"'), t({ "", "" }),
    t({ "", "# 🔹 1. Declaration (MUST use -A)" }),
    t("declare -A myhash"), t({ "", "" }),
    t({ "", "# 🔹 2. Assignment: individual keys" }),
    t('myhash[a]="'), i(1, "foo"), t('"'), t({ "", "" }),
    t('myhash[b]="'), i(2, "bar"), t('"'), t({ "", "" }),
    t('myhash[c]="'), i(3, "baz"), t('"'), t({ "", "" }),
    t('myhash[d]="three"'), t({ "", "" }),
    t('myhash[e]="four"'), t({ "", "" }),
    t('myhash[f]="'), i(4, "five by five"), t('"  # Spaces preserved'), t({ "", "" }),
    t('myhash[g]="six"'), t({ "", "" }),
    t({ "", "# 🔹 Alternative: bulk assignment" }),
    t('# myhash=([a]=foo [b]=bar [c]=baz [d]="three" [e]="four" [f]="five by five" [g]="six")', "", ""),
    t({ "", "# 🔹 3. Metadata & Display" }),
    t('printf "\\nThe key count is: %d\\n" "${#myhash[@]}"'), t({ "", "" }),
    t('printf "Length of value [e]: %d\\n" "${#myhash[e]}"'), t({ "", "" }),
    t('echo "Dump:"'), t({ "", "" }),
    t('declare -p myhash | $FORMAT'), t({ "", "" }),
    t({ "", "# 🔹 Quoting matters: [@] vs [*], quoted vs unquoted" }),
    t('printf "\\n%smyhash[@] (unquoted) = " "\\${"'), t({ "", "\t" }),
    t('printf "%q|" ${myhash[@]}'), t({ "", "" }),
    t('printf "\\n%smyhash[*] (unquoted) = " "\\${"'), t({ "", "\t" }),
    t('printf "%q|" ${myhash[*]}'), t({ "", "" }),
    t('printf "\\n%smyhash[@] (quoted) = " "\\"\\${"'), t({ "", "\t" }),
    t('printf "%q|" "${myhash[@]}"'), t({ "", "" }),
    t('printf "\\n%smyhash[*] (quoted) = " "\\"\\${"'), t({ "", "\t" }),
    t('printf "%q|" "${myhash[*]}"'), t({ "", "" }),
    t({ "", "# 🔹 4. Join Functions" }),
    t("function join() {"), t({ "", "\t" }),
    t('local IFS="$1"; shift; printf "%s" "$*"'), t({ "", "}", "" }),
    t('printf "\\nJoin \',\' \\${myhash[@]} = %s\\n" "$(join \',\' "${myhash[@]}")"'), t({ "", "" }),
    t("function string_join() {"), t({ "", "\t" }),
    t('local delim="$1"; shift; local first="$1"; shift'), t({ "", "\t" }),
    t('printf "%s" "$first" "${@/#/$delim}"'), t({ "", "}", "" }),
    t('printf "String_Join \'<>\' = %s\\n" "$(string_join "<>" "${myhash[@]}")"'), t({ "", "" }),
    t({ "", "# 🔹 5. Iteration: CORRECT vs INCORRECT" }),
    t('printf "\\n✅ Correct: for key in \\"\\${!myhash[@]}\\"\\n"'), t({ "", "" }),
    t('for key in "${!myhash[@]}"; do'), t({ "", "\t" }),
    t('printf "\\tKey: %s; value: %s\\n" "$key" "${myhash[$key]}"'), t({ "", "done", "" }),
    t('printf "\\n❌ Incorrect: for key in \\${myhash[*]} (values, not keys!)\\n"'), t({ "", "" }),
    t('for val in ${myhash[*]}; do'), t({ "", "\t" }),
    t('printf "\\tValue (not key!): %s\\n" "$val"'), t({ "", "done", "" }),
    t({ "", "# 🔹 6. Slicing: by INSERTION ORDER, not key order" }),
    t('printf "\\nSlice [5:2] (insertion order): %s\\n" "$(printf "%q|" "${myhash[@]:5:2}")"'), t({ "", "" }),
    t('printf "Slice [0:3]: %s\\n" "$(printf "%q|" "${myhash[@]:0:3}")"'), t({ "", "" }),
    t('printf "Slice [1:3]: %s\\n" "$(printf "%q|" "${myhash[@]:1:3}")"'), t({ "", "" }),
    t({ "", "# 🔹 7. Delete single key" }),
    t('echo -e "\\nBefore unset [c]:"'), t({ "", "" }),
    t('declare -p myhash | $FORMAT'), t({ "", "" }),
    t("unset -v 'myhash[c]'"), t({ "", "" }),
    t('echo "After unset [c]:"'), t({ "", "" }),
    t('declare -p myhash | $FORMAT'), t({ "", "" }),
    t({ "", "# 🔹 8. Delete entire hash" }),
    t("unset -v myhash"), t({ "", "" }),
    t('echo "✅ Demo complete. Hash deleted."'),
  }),

  s("bindexed_array_demo", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Bash Indexed Arrays (Lists) – Complete Demo"), t({ "", "" }),
    t('FORMAT="fmt --width 70 --split-only"'), t({ "", "" }),
    t({ "", "# 🔹 1. Declaration & Initialization" }),
    t("# Option A: Implicit declaration via assignment"), t({ "", "" }),
    t('mylist[0]="'), i(1, "foo"), t('"'), t({ "", "" }),
    t({ "", "# Option B: Explicit declaration" }),
    t("# declare -a mylist", "", ""),
    t({ "", "# Option C: Bulk assignment" }),
    t('# mylist=("foo" "bar" "baz" "three" "four" "five by five" "six")', "", ""),
    t({ "", "# 🔹 2. Append Elements (+=)" }),
    t('mylist+=("'), i(2, "bar"), t('")  # mylist[1]'), t({ "", "" }),
    t('mylist+=("'), i(3, "baz"), t('")  # mylist[2]'), t({ "", "" }),
    t('mylist+=("three" "four")  # mylist[3] AND mylist[4]'), t({ "", "" }),
    t('mylist+=("'), i(4, "five by five"), t('")  # Spaces preserved'), t({ "", "" }),
    t('mylist+=("'), i(5, "six"), t('")  # mylist[6]'), t({ "", "" }),
    t({ "", "# 🔹 3. Metadata & Display" }),
    t('printf "\\n📊 Element count: %d\\n" "${#mylist[@]}"'), t({ "", "" }),
    t('printf "📏 Length of element [4]: %d\\n" "${#mylist[4]}"'), t({ "", "" }),
    t('echo "💾 Dump:"'), t({ "", "" }),
    t('declare -p mylist | $FORMAT'), t({ "", "" }),
    t({ "", "# 🔹 Quoting matters: [@] vs [*], quoted vs unquoted" }),
    t('printf "\\n%smylist[@] (unquoted) = " "\\${"'), t({ "", "\t" }),
    t('printf "%q|" ${mylist[@]}'), t({ "", "" }),
    t('printf "\\n%smylist[*] (unquoted) = " "\\${"'), t({ "", "\t" }),
    t('printf "%q|" ${mylist[*]}'), t({ "", "" }),
    t('printf "\\n%smylist[@] (quoted) = " "\\"\\${"'), t({ "", "\t" }),
    t('printf "%q|" "${mylist[@]}"'), t({ "", "" }),
    t('printf "\\n%smylist[*] (quoted) = " "\\"\\${"'), t({ "", "\t" }),
    t('printf "%q|" "${mylist[*]}"'), t({ "", "" }),
    t({ "", "# 🔹 4. Join Functions" }),
    t("function join() {"), t({ "", "\t" }),
    t('local IFS="$1"; shift; printf "%s" "$*"'), t({ "", "}", "" }),
    t('printf "\\n🔗 Join \',\' \\${mylist[@]} = %s\\n" "$(join \',\' "${mylist[@]}")"'), t({ "", "" }),
    t("function string_join() {"), t({ "", "\t" }),
    t('local delim="$1"; shift; local first="$1"; shift'), t({ "", "\t" }),
    t('printf "%s" "$first" "${@/#/$delim}"'), t({ "", "}", "" }),
    t('printf "🧵 String_Join \'<>\' = %s\\n" "$(string_join "<>" "${mylist[@]}")"'), t({ "", "" }),
    t({ "", "# 🔹 5. Iteration: CORRECT vs INCORRECT" }),
    t('printf "\\n✅ Correct: for idx in \\"\\${!mylist[@]}\\"\\n"'), t({ "", "" }),
    t('for idx in "${!mylist[@]}"; do'), t({ "", "\t" }),
    t('printf "\\tIdx: %s; value: %s\\n" "$idx" "${mylist[$idx]}"'), t({ "", "done", "" }),
    t('printf "\\n❌ Incorrect: for val in \\${mylist[*]} (word-splitting!)\\n"'), t({ "", "" }),
    t('for val in ${mylist[*]}; do'), t({ "", "\t" }),
    t('printf "\\tValue (word-split): %s\\n" "$val"'), t({ "", "done", "" }),
    t({ "", "# 🔹 6. Slicing, Shift & Pop" }),
    t('printf "\\n🔪 Slice [5:2]: %s\\n" "$(printf "%q|" "${mylist[@]:5:2}")"'), t({ "", "" }),
    t({ "", "# Shift: remove first element (reassign slice)" }),
    t('printf "\\n🔄 Before shift:\\n"'), t({ "", "" }),
    t('declare -p mylist | $FORMAT'), t({ "", "" }),
    t('mylist=("${mylist[@]:1}")  # Reassign from index 1'), t({ "", "" }),
    t('printf "🔄 After shift:\\n"'), t({ "", "" }),
    t('declare -p mylist | $FORMAT'), t({ "", "" }),
    t({ "", "# Pop: remove last element (Bash 4.3+)" }),
    t('printf "\\n🗑️  Before pop:\\n"'), t({ "", "" }),
    t('declare -p mylist | $FORMAT'), t({ "", "" }),
    t("unset -v 'mylist[-1]'  # Bash 4.3+"), t({ "", "" }),
    t('# unset -v "mylist[${#mylist[@]}-1]"  # Older Bash fallback'), t({ "", "" }),
    t('printf "🗑️  After pop:\\n"'), t({ "", "" }),
    t('declare -p mylist | $FORMAT'), t({ "", "" }),
    t({ "", "# 🔹 7. Delete Single Element by Index" }),
    t('printf "\\n❌ Delete index 2:\\n"'), t({ "", "" }),
    t('declare -p mylist | $FORMAT'), t({ "", "" }),
    t("unset -v 'mylist[2]'"), t({ "", "" }),
    t('printf "After unset [2]:\\n"'), t({ "", "" }),
    t('declare -p mylist | $FORMAT'), t({ "", "" }),
    t({ "", "# 🔹 8. Delete Entire Array" }),
    t("unset -v mylist"), t({ "", "" }),
    t('printf "✅ Demo complete. Array deleted.\\n"'),
  }),

  s("bhash_word_count", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Word Frequency Counter using Associative Array"), t({ "", "" }),
    t('WORD_FILE="'), i(1, "/tmp/words.txt"), t('"'), t({ "", "" }),
    t(': > "$WORD_FILE"  # Truncate/create file safely'), t({ "", "" }),
    t('trap \'rm -f "$WORD_FILE"\' ABRT EXIT HUP INT QUIT TERM'), t({ "", "" }),
    t('echo "📝 Creating random word list in: $WORD_FILE"'), t({ "", "" }),
    t({ "", "# 🔹 1. Source word list" }),
    t('mylist=("'), i(2, "foo bar baz one two three four"), t('")'), t({ "", "" }),
    t('range=${#mylist[@]}'), t({ "", "" }),
    t({ "", "# 🔹 2. Generate 35 random words" }),
    t('for (( i=0; i<35; i++ )); do'), t({ "", "\t" }),
    t('\tidx=$(( RANDOM % range ))'), t({ "", "\t" }),
    t('\techo "${mylist[$idx]}" >> "$WORD_FILE"'), t({ "", "done", "" }),
    t({ "", "# 🔹 3. Read file into associative array (count frequencies)" }),
    t('declare -A myhash'), t({ "", "" }),
    t('while IFS= read -r word; do'), t({ "", "\t" }),
    t('[[ -n "$word" ]] && (( myhash[$word]++ ))'), t({ "", "done" }),
    t('  < "$WORD_FILE"'), t({ "", "" }),
    t({ "", "# 🔹 4. Output: Unique words (sorted)" }),
    t('printf "\\n🔤 Unique words:\\n"'), t({ "", "" }),
    t('for key in "${!myhash[@]}"; do'), t({ "", "\t" }),
    t('printf "%s\\n" "$key"'), t({ "", "done | sort" }), t({ "", "" }),
    t({ "", "# 🔹 5. Output: Counts sorted by word" }),
    t('printf "\\n📊 Counts (sorted by word):\\n"'), t({ "", "" }),
    t('for key in "${!myhash[@]}"; do'), t({ "", "\t" }),
    t('printf "%s\\t%d\\n" "$key" "${myhash[$key]}"'), t({ "", "done | sort" }), t({ "", "" }),
    t({ "", "# 🔹 6. Output: Counts sorted by frequency" }),
    t('printf "\\n📈 Counts (sorted by frequency):\\n"'), t({ "", "" }),
    t('for key in "${!myhash[@]}"; do'), t({ "", "\t" }),
    t('printf "%s\\t%d\\n" "$key" "${myhash[$key]}"'), t({ "", "done | sort -k2,2n" }),
  }),

  -- 🔹 1. Standard Short Options
  s("bgetopts_short", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Short options: -a, -o <file>, -v"), t({ "", "" }),
    t("# Leading ':' enables silent error reporting"), t({ "", "" }),
    t("while getopts ':ao:v' opt; do"), t({ "", "\t" }),
    t("case $opt in"), t({ "", "\t\t" }),
    t("a) AMODE=1 ;;"), t({ "", "\t\t" }),
    t("o) OFILE=\"$OPTARG\" ;;"), t({ "", "\t\t" }),
    t("v) VERBOSE=1 ;;"), t({ "", "\t\t" }),
    t(":)"), t({ "", "\t\t\t" }),
    t('echo "❌ Error: option -$OPTARG requires an argument" >&2'), t({ "", "\t\t\t" }),
    t("exit 1 ;;"), t({ "", "\t\t" }),
    t("*)"), t({ "", "\t\t\t" }),
    t('echo "❌ Error: unknown option -$opt" >&2'), t({ "", "\t\t\t" }),
    t('echo "   Valid options: -a -o <file> -v" >&2'), t({ "", "\t\t\t" }),
    t("exit 1 ;;"), t({ "", "\t" }),
    t("esac"), t({ "", "done", "" }),
    t("# 🔹 Remove parsed options from $@"), t({ "", "" }),
    t("shift $((OPTIND - 1))"), t({ "", "" }),
    t('echo "✅ Remaining args: $*"'),
  }),

  -- 🔹 2. Short + Long Options (Bash `:-:` trick)
  s("bgetopts_long", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Extended getopts: supports --long options"), t({ "", "" }),
    t("# ':-:' enables long option parsing in Bash"), t({ "", "" }),
    t("VERBOSE=0  # Default off"), t({ "", "" }),
    t("while getopts ':-:ao:v' opt; do"), t({ "", "\t" }),
    t("case $opt in"), t({ "", "\t\t" }),
    t("a) AMODE=1 ;;"), t({ "", "\t\t" }),
    t("o) OFILE=\"$OPTARG\" ;;"), t({ "", "\t\t" }),
    t("v) VERBOSE=1 ;;"), t({ "", "\t\t" }),
    t("-)  # Long option handler"), t({ "", "\t\t\t" }),
    t("case $OPTARG in"), t({ "", "\t\t\t\t" }),
    t("amode) AMODE=1 ;;"), t({ "", "\t\t\t\t" }),
    t("outfile=* ) OFILE=\"${OPTARG#*=}\" ;;"), t({ "", "\t\t\t\t" }),
    t("outfile)"), t({ "", "\t\t\t\t\t" }),
    t("OFILE=\"${!OPTIND}\""), t({ "", "\t\t\t\t\t" }),
    t("((OPTIND++))  # Skip next positional arg"), t({ "", "\t\t\t\t" }),
    t(";;"), t({ "", "\t\t\t\t" }),
    t("verbose) VERBOSE=1 ;;"), t({ "", "\t\t\t\t" }),
    t("* )"), t({ "", "\t\t\t\t\t" }),
    t('echo "❌ Unknown long option: --$OPTARG" >&2'), t({ "", "\t\t\t\t\t" }),
    t("exit 1 ;;"), t({ "", "\t\t\t\t" }),
    t("esac"), t({ "", "\t\t\t" }),
    t(";;"), t({ "", "\t\t" }),
    t(":)"), t({ "", "\t\t\t" }),
    t('echo "❌ Option -$OPTARG requires an argument" >&2'), t({ "", "\t\t\t" }),
    t("exit 1 ;;"), t({ "", "\t\t" }),
    t("*)"), t({ "", "\t\t\t" }),
    t('echo "❌ Unknown option: -$opt" >&2'), t({ "", "\t\t\t" }),
    t('echo "   Valid: -a, -o <file>, -v, --amode, --outfile[=val], --verbose" >&2'), t({ "", "\t\t\t" }),
    t("exit 1 ;;"), t({ "", "\t" }),
    t("esac"), t({ "", "done", "" }),
    t("# 🔹 Remove parsed options from $@"), t({ "", "" }),
    t("shift $((OPTIND - 1))"), t({ "", "" }),
    t('echo "✅ Parsed: AMODE=$AMODE | OFILE=$OFILE | VERBOSE=$VERBOSE"'), t({ "", "" }),
    t('echo "📦 Remaining args: $*"'),
  }),



    s("bbatch_processor", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Batch File Processor with mapfile (Bash 4.0+)"), t({ "", "" }),
    t('INPUT_FILE="'), i(1, "/tmp/nodes.txt"), t('"'), t({ "", "" }),
    t(": > \"$INPUT_FILE\"  # Create/truncate test file"), t({ "", "" }),
    t('for n in node{0..'), i(2, "9"), t('}; do echo "$n" >> "$INPUT_FILE"; done'), t({ "", "" }),
    t({ "", "# 🔹 Configuration" }),
    t('BATCH_SIZE="'), i(3, "4"), t('"'), t({ "", "" }),
    t('SLEEP_PER_NODE="'), i(4, "1"), t('"'), t({ "", "" }),
    t('SLEEP_PER_BATCH="'), i(5, "1"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Calculate metrics" }),
    t('NODE_COUNT="$(wc -l < "$INPUT_FILE")"'), t({ "", "" }),
    t('BATCH_COUNT="$(( NODE_COUNT / BATCH_SIZE ))"'), t({ "", "" }),
    t('echo "📊 Nodes to process:        $NODE_COUNT" >&2'), t({ "", "" }),
    t('echo "📦 Batch size / count:      $BATCH_SIZE / $BATCH_COUNT" >&2'), t({ "", "" }),
    t('echo "⏱️  Sleep per node:         $SLEEP_PER_NODE" >&2'), t({ "", "" }),
    t('echo "⏱️  Sleep per batch:        $SLEEP_PER_BATCH" >&2'), t({ "", "" }),
    t('echo "" >&2'), t({ "", "" }),
    t({ "", "# 🔹 Main batch loop" }),
    t("node_counter=0"), t({ "", "" }),
    t("batch_counter=0"), t({ "", "" }),
    t('while mapfile -t -n "$BATCH_SIZE" nodes && (( ${#nodes[@]} )); do'), t({ "", "\t" }),
    t('for node in "${nodes[@]}"; do'), t({ "", "\t\t" }),
    t('echo "🔹 node $(( node_counter++ )): $node"'), t({ "", "\t\t" }),
    t('[[ "$SLEEP_PER_NODE" -gt 0 ]] && sleep "$SLEEP_PER_NODE"'), t({ "", "\t" }),
    t("done"), t({ "", "\t" }),
    t("(( batch_counter++ ))"), t({ "", "\t" }),
    t('if [[ "$node_counter" -lt "$NODE_COUNT" ]]; then'), t({ "", "\t\t" }),
    t('echo "✅ Completed $node_counter/$NODE_COUNT nodes; batch $batch_counter/$BATCH_COUNT" >&2'), t({ "", "\t\t" }),
    t('echo "💤 Sleeping $SLEEP_PER_BATCH seconds before next batch..." >&2'), t({ "", "\t\t" }),
    t('[[ "$SLEEP_PER_BATCH" -gt 0 ]] && sleep "$SLEEP_PER_BATCH"'), t({ "", "\t" }),
    t("fi"), t({ "", 'done < "$INPUT_FILE"' }), t({ "", "" }),
    t('echo "🎉 All nodes processed successfully!" >&2'),
  }),

    s("bbatch_processor", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Batch File Processor with mapfile (Bash 4.0+)"), t({ "", "" }),
    t('INPUT_FILE="'), i(1, "/tmp/nodes.txt"), t('"'), t({ "", "" }),
    t(": > \"$INPUT_FILE\"  # Create/truncate test file"), t({ "", "" }),
    t('for n in node{0..'), i(2, "9"), t('}; do echo "$n" >> "$INPUT_FILE"; done'), t({ "", "" }),
    t({ "", "# 🔹 Configuration" }),
    t('BATCH_SIZE="'), i(3, "4"), t('"'), t({ "", "" }),
    t('SLEEP_PER_NODE="'), i(4, "1"), t('"'), t({ "", "" }),
    t('SLEEP_PER_BATCH="'), i(5, "1"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Calculate metrics" }),
    t('NODE_COUNT="$(wc -l < "$INPUT_FILE")"'), t({ "", "" }),
    t('BATCH_COUNT="$(( NODE_COUNT / BATCH_SIZE ))"'), t({ "", "" }),
    t('echo "📊 Nodes to process:        $NODE_COUNT" >&2'), t({ "", "" }),
    t('echo "📦 Batch size / count:      $BATCH_SIZE / $BATCH_COUNT" >&2'), t({ "", "" }),
    t('echo "⏱️  Sleep per node:         $SLEEP_PER_NODE" >&2'), t({ "", "" }),
    t('echo "⏱️  Sleep per batch:        $SLEEP_PER_BATCH" >&2'), t({ "", "" }),
    t('echo "" >&2'), t({ "", "" }),
    t({ "", "# 🔹 Main batch loop" }),
    t("node_counter=0"), t({ "", "" }),
    t("batch_counter=0"), t({ "", "" }),
    t('while mapfile -t -n "$BATCH_SIZE" nodes && (( ${#nodes[@]} )); do'), t({ "", "\t" }),
    t('for node in "${nodes[@]}"; do'), t({ "", "\t\t" }),
    t('echo "🔹 node $(( node_counter++ )): $node"'), t({ "", "\t\t" }),
    t('[[ "$SLEEP_PER_NODE" -gt 0 ]] && sleep "$SLEEP_PER_NODE"'), t({ "", "\t" }),
    t("done"), t({ "", "\t" }),
    t("(( batch_counter++ ))"), t({ "", "\t" }),
    t('if [[ "$node_counter" -lt "$NODE_COUNT" ]]; then'), t({ "", "\t\t" }),
    t('echo "✅ Completed $node_counter/$NODE_COUNT nodes; batch $batch_counter/$BATCH_COUNT" >&2'), t({ "", "\t\t" }),
    t('echo "💤 Sleeping $SLEEP_PER_BATCH seconds before next batch..." >&2'), t({ "", "\t\t" }),
    t('[[ "$SLEEP_PER_BATCH" -gt 0 ]] && sleep "$SLEEP_PER_BATCH"'), t({ "", "\t" }),
    t("fi"), t({ "", "" }),
    t('done < "$INPUT_FILE"'), t({ "", "" }),
    t('echo "🎉 All nodes processed successfully!" >&2'),
  }),


  s("bifs_demo", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 IFS & read Behavior Demonstration"), t({ "", "" }),
    t('IFS_TEST_FILE="'), i(1, "/tmp/ifs-test.txt"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Create test file" }),
    t('cat > "$IFS_TEST_FILE" <<\'EOF\''),
    t("line1 wd1 wd2 wd3"),
    t("line2 wd1 wd2 wd3"),
    t("line3 wd1 wd2 wd3"),
    t("EOF"), t({ "", "" }),
    t({ "", "# ──────────────────────────────────────────────────────────" }),
    t("# 🔹 1. Normal $IFS and `read` operation; split into words"), t({ "", "" }),
    t('printf \'$IFS before: %q\\n\' "$IFS"'), t({ "", "" }),
    t('while read line w1 w2 w3; do'), t({ "", "\t" }),
    t('printf \'IFS during: %q\\tline = %q, w1 = %q, w2 = %q, w3 = %q\\n\' \\'), t({ "", "\t\t" }),
    t('"$IFS" "$line" "$w1" "$w2" "$w3"'), t({ "", "done < \"$IFS_TEST_FILE\"" }),
    t('printf \'IFS after:  %q\\n\' "$IFS"'), t({ "", "" }),
    t({ "", "# ──────────────────────────────────────────────────────────" }),
    t("# 🔹 2. Temporary $IFS change for `read` inline"), t({ "", "" }),
    t('printf \'IFS before: %q\\n\' "$IFS"'), t({ "", "" }),
    t('while IFS= read line w1 w2 w3; do'), t({ "", "\t" }),
    t('printf \'IFS during: %q\\tln = %q, w1 = %q, w2 = %q, w3 = %q\\n\' \\'), t({ "", "\t\t" }),
    t('"$IFS" "$line" "$w1" "$w2" "$w3"'), t({ "", "done < \"$IFS_TEST_FILE\"" }),
    t('printf \'IFS after:  %q\\n\' "$IFS"'), t({ "", "" }),
    t({ "", "# ──────────────────────────────────────────────────────────" }),
    t("function read_a_file() {"), t({ "", "\t" }),
    t('local file="$1"'), t({ "", "\t" }),
    t("local IFS=''"), t({ "", "" }),
    t('while read line w1 w2 w3; do'), t({ "", "\t\t" }),
    t('printf \'IFS during: %q\\tline = %q, w1 = %q, w2 = %q, w3 = %q\\n\' \\'), t({ "", "\t\t\t" }),
    t('"$IFS" "$line" "$w1" "$w2" "$w3"'), t({ "", "\t" }),
    t('done < "$file"'), t({ "", "}", "" }),
    t({ "", "# 🔹 3. Temporary $IFS change inside a function" }),
    t('printf \'IFS before: %q\\n\' "$IFS"'), t({ "", "" }),
    t('read_a_file "$IFS_TEST_FILE"'), t({ "", "" }),
    t('printf \'IFS after:  %q\\n\' "$IFS"'), t({ "", "" }),
    t({ "", "# ──────────────────────────────────────────────────────────" }),
    t("# 🔹 4. No $IFS change needed (single variable captures whole line)"), t({ "", "" }),
    t('printf \'IFS before: %q\\n\' "$IFS"'), t({ "", "" }),
    t('while read line; do'), t({ "", "\t" }),
    t('printf \'IFS during: %q\\tline = %q\\n\' "$IFS" "$line"'), t({ "", "done < \"$IFS_TEST_FILE\"" }),
    t('printf \'IFS after:  %q\\n\' "$IFS"'),
  }),

  s("bifs_demo", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 IFS & read Behavior Demonstration"), t({ "", "" }),
    t('IFS_TEST_FILE="'), i(1, "/tmp/ifs-test.txt"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Create test file" }),
    t('cat > "$IFS_TEST_FILE" <<\'EOF\''),
    t("line1 wd1 wd2 wd3"),
    t("line2 wd1 wd2 wd3"),
    t("line3 wd1 wd2 wd3"),
    t("EOF"), t({ "", "" }),
    t({ "", "# ──────────────────────────────────────────────────────────" }),
    t("# 🔹 1. Normal $IFS and `read` operation; split into words"), t({ "", "" }),
    t('printf \'$IFS before: %q\\n\' "$IFS"'), t({ "", "" }),
    t('while read line w1 w2 w3; do'), t({ "", "\t" }),
    t('printf \'IFS during: %q\\tline = %q, w1 = %q, w2 = %q, w3 = %q\\n\' \\'), t({ "", "\t\t" }),
    t('"$IFS" "$line" "$w1" "$w2" "$w3"'), t({ "", "done < \"$IFS_TEST_FILE\"" }),
    t('printf \'IFS after:  %q\\n\' "$IFS"'), t({ "", "" }),
    t({ "", "# ──────────────────────────────────────────────────────────" }),
    t("# 🔹 2. Temporary $IFS change for `read` inline"), t({ "", "" }),
    t('printf \'IFS before: %q\\n\' "$IFS"'), t({ "", "" }),
    t('while IFS= read line w1 w2 w3; do'), t({ "", "\t" }),
    t('printf \'IFS during: %q\\tln = %q, w1 = %q, w2 = %q, w3 = %q\\n\' \\'), t({ "", "\t\t" }),
    t('"$IFS" "$line" "$w1" "$w2" "$w3"'), t({ "", "done < \"$IFS_TEST_FILE\"" }),
    t('printf \'IFS after:  %q\\n\' "$IFS"'), t({ "", "" }),
    t({ "", "# ──────────────────────────────────────────────────────────" }),
    t("function read_a_file() {"), t({ "", "\t" }),
    t('local file="$1"'), t({ "", "\t" }),
    t("local IFS=''"), t({ "", "" }),
    t('while read line w1 w2 w3; do'), t({ "", "\t\t" }),
    t('printf \'IFS during: %q\\tline = %q, w1 = %q, w2 = %q, w3 = %q\\n\' \\'), t({ "", "\t\t\t" }),
    t('"$IFS" "$line" "$w1" "$w2" "$w3"'), t({ "", "\t" }),
    t('done < "$file"'), t({ "", "}", "" }),
    t({ "", "# 🔹 3. Temporary $IFS change inside a function" }),
    t('printf \'IFS before: %q\\n\' "$IFS"'), t({ "", "" }),
    t('read_a_file "$IFS_TEST_FILE"'), t({ "", "" }),
    t('printf \'IFS after:  %q\\n\' "$IFS"'), t({ "", "" }),
    t({ "", "# ──────────────────────────────────────────────────────────" }),
    t("# 🔹 4. No $IFS change needed (single variable captures whole line)"), t({ "", "" }),
    t('printf \'IFS before: %q\\n\' "$IFS"'), t({ "", "" }),
    t('while read line; do'), t({ "", "\t" }),
    t('printf \'IFS during: %q\\tline = %q\\n\' "$IFS" "$line"'), t({ "", "done < \"$IFS_TEST_FILE\"" }),
    t('printf \'IFS after:  %q\\n\' "$IFS"'),
  }),


  s("brds_ssh_tunnel", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 SSH Tunnel to AWS RDS + MySQL Connection"), t({ "", "" }),
    t({ "", "# 🔹 RDS Configuration" }),
    t('RDS_USER="'), i(1, "test"), t('"'), t({ "", "" }),
    t('RDS_PASSWORD="'), i(2, "Qwerty123"), t('"'), t({ "", "" }),
    t('RDS_DATABASE="'), i(3, "testdb"), t('"'), t({ "", "" }),
    t('RDS_REMOTE_PORT="'), i(4, "3306"), t('"'), t({ "", "" }),
    t('RDS_LOCAL_PORT="'), i(5, "3333"), t('"'), t({ "", "" }),
    t('RDS_ENDPOINT="'), i(6, "test.cghny4jdtzuu.eu-central-1.rds.amazonaws.com"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Bastion/EC2 Configuration" }),
    t('EC2_USER="'), i(7, "ec2-user"), t('"'), t({ "", "" }),
    t('EC2_HOST="'), i(8, "ec2-18-196-155-195.eu-central-1.compute.amazonaws.com"), t('"'), t({ "", "" }),
    t('EC2_SSH="'), i(9, "/home/petro/Downloads/GA/code.pem"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Validate SSH key permissions" }),
    t('if [[ ! -f "$EC2_SSH" ]]; then'), t({ "", "\t" }),
    t('echo "❌ SSH key not found: $EC2_SSH" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('chmod 400 "$EC2_SSH" 2>/dev/null || true'), t({ "", "" }),
    t({ "", "# 🔹 Check if local port is already in use" }),
    t('if lsof -i :"$RDS_LOCAL_PORT" >/dev/null 2>&1; then'), t({ "", "\t" }),
    t('echo "⚠️  Port $RDS_LOCAL_PORT is already in use" >&2'), t({ "", "\t" }),
    t('read -rp "Kill existing process? [y/N] " -n 1 -r'), t({ "", "\t" }),
    t('echo'), t({ "", "\t" }),
    t('if [[ $REPLY =~ ^[Yy]$ ]]; then'), t({ "", "\t\t" }),
    t('kill $(lsof -t -i:"$RDS_LOCAL_PORT") 2>/dev/null || true'), t({ "", "\t" }),
    t("fi"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Establish SSH tunnel (background, no command)" }),
    t('echo "🔐 Establishing SSH tunnel to $RDS_ENDPOINT:$RDS_REMOTE_PORT..."'), t({ "", "" }),
    t('ssh -i "$EC2_SSH" -f -N -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes \\'), t({ "", "" }),
    t('  -L "$RDS_LOCAL_PORT:$RDS_ENDPOINT:$RDS_REMOTE_PORT" \\'), t({ "", "" }),
    t('  "$EC2_USER@$EC2_HOST"'), t({ "", "" }),
    t('TUNNEL_PID=$!', t({ "", "" })),
    t('sleep 2  # Wait for tunnel to establish'), t({ "", "" }),
    t({ "", "# 🔹 Verify tunnel is active" }),
    t('if ! lsof -i :"$RDS_LOCAL_PORT" >/dev/null 2>&1; then'), t({ "", "\t" }),
    t('echo "❌ Failed to establish tunnel" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('echo "✅ Tunnel established on port $RDS_LOCAL_PORT"'), t({ "", "" }),
    t({ "", "# 🔹 MySQL connection via tunnel" }),
    t('echo "🐬 Connecting to MySQL..."'), t({ "", "" }),
    t('mysql -u "$RDS_USER" -h 127.0.0.1 -P "$RDS_LOCAL_PORT" "$RDS_DATABASE" \\'), t({ "", "" }),
    t('  -p"$RDS_PASSWORD"'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup: kill tunnel on exit" }),
    t('trap \'echo "🧹 Closing tunnel..."; kill $TUNNEL_PID 2>/dev/null\' EXIT INT TERM'), t({ "", "" }),
    t('echo "🎉 Done. Tunnel will close on exit."'),
  }),


  s("ssh-local-forward", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 SSH Local Port Forwarding Template"), t({ "", "" }),
    t('LOCAL_BIND="'), i(1, "127.0.0.1"), t('"'), t({ "", "" }),
    t('LOCAL_PORT="'), i(2, "2022"), t('"'), t({ "", "" }),
    t('REMOTE_HOST="'), i(3, "10.150.35.74"), t('"'), t({ "", "" }),
    t('REMOTE_PORT="'), i(4, "22"), t('"'), t({ "", "" }),
    t('JUMP_USER="'), i(5, "tunneluser"), t('"'), t({ "", "" }),
    t('JUMP_HOST="'), i(6, "remotehost.example.com"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Establish tunnel (background, no remote command)" }),
    t('ssh -i "'), i(7, "~/.ssh/id_ed25519"), t('" -f -N \\'), t({ "", "" }),
    t('  -o ServerAliveInterval=60 \\'), t({ "", "" }),
    t('  -o ExitOnForwardFailure=yes \\'), t({ "", "" }),
    t('  -L "$LOCAL_BIND:$LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT" \\'), t({ "", "" }),
    t('  "$JUMP_USER@$JUMP_HOST"'), t({ "", "" }),
    t({ "", "# 🔹 Usage example (in another terminal):" }),
    t("# ssh -p $LOCAL_PORT user@127.0.0.1"), t({ "", "" }),
    t('echo "✅ Tunnel ready: $LOCAL_BIND:$LOCAL_PORT → $REMOTE_HOST:$REMOTE_PORT"'),
  }),

  s("ssh-web-tunnel", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 SSH Tunnel to Remote Web Server (localhost:80)"), t({ "", "" }),
    t('LOCAL_PORT="'), i(1, "8080"), t('"'), t({ "", "" }),
    t('REMOTE_WEB_PORT="'), i(2, "80"), t('"'), t({ "", "" }),
    t('SSH_USER="'), i(3, "tunneluser"), t('"'), t({ "", "" }),
    t('SSH_HOST="'), i(4, "remotehost.example.com"), t('"'), t({ "", "" }),
    t('SSH_KEY="'), i(5, "~/.ssh/id_ed25519"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Validate prerequisites" }),
    t('if ! command -v ssh >/dev/null; then'), t({ "", "\t" }),
    t('echo "❌ ssh not found" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('if [[ ! -f "$SSH_KEY" ]]; then'), t({ "", "\t" }),
    t('echo "⚠️  SSH key not found: $SSH_KEY" >&2'), t({ "", "fi", "" }),
    t({ "", "# 🔹 Check if local port is free" }),
    t('if lsof -i :"$LOCAL_PORT" >/dev/null 2>&1; then'), t({ "", "\t" }),
    t('echo "❌ Port $LOCAL_PORT is already in use" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Establish tunnel (background, no remote command)" }),
    t('echo "🔐 Connecting to $SSH_HOST..."'), t({ "", "" }),
    t('ssh -i "$SSH_KEY" -f -N \\'), t({ "", "" }),
    t('  -o ServerAliveInterval=60 \\'), t({ "", "" }),
    t('  -o ExitOnForwardFailure=yes \\'), t({ "", "" }),
    t('  -L "$LOCAL_PORT:localhost:$REMOTE_WEB_PORT" \\'), t({ "", "" }),
    t('  "$SSH_USER@$SSH_HOST"'), t({ "", "" }),
    t({ "", "# 🔹 Verify tunnel" }),
    t('sleep 2'), t({ "", "" }),
    t('if ! lsof -i :"$LOCAL_PORT" >/dev/null 2>&1; then'), t({ "", "\t" }),
    t('echo "❌ Failed to establish tunnel" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('echo "✅ Tunnel ready: http://localhost:$LOCAL_PORT"'), t({ "", "" }),
    t('echo "🌐 Open in browser: http://localhost:$LOCAL_PORT"'), t({ "", "" }),
    t({ "", "# 🔹 Optional: auto-open browser (Linux/macOS)" }),
    t('# command -v xdg-open >/dev/null && xdg-open "http://localhost:$LOCAL_PORT" &'), t({ "", "" }),
    t('# command -v open >/dev/null && open "http://localhost:$LOCAL_PORT" &'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup on exit" }),
    t('trap \'echo "🧹 Closing tunnel..."; pkill -f "ssh.*-L.*$LOCAL_PORT"\' EXIT INT TERM'),
  }),

 s("ssh-interface-tunnel", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 SSH Tunnel: Bind to Specific Local Interface"), t({ "", "" }),
    t('LOCAL_IP="'), i(1, "192.168.3.45"), t('"  # Your local interface IP'), t({ "", "" }),
    t('LOCAL_PORT="'), i(2, "8080"), t('"  # Unprivileged port (>1023)'), t({ "", "" }),
    t('TARGET_HOST="'), i(3, "web01.example.com"), t('"'), t({ "", "" }),
    t('TARGET_PORT="'), i(4, "80"), t('"'), t({ "", "" }),
    t('SSH_USER="'), i(5, "tunneluser"), t('"'), t({ "", "" }),
    t('SSH_HOST="'), i(6, "remotehost.example.com"), t('"'), t({ "", "" }),
    t('SSH_KEY="'), i(7, "~/.ssh/id_ed25519"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Validate local IP exists on this machine" }),
    t('if ! ip addr show | grep -q "$LOCAL_IP"; then'), t({ "", "\t" }),
    t('echo "❌ Local IP $LOCAL_IP not found on this machine" >&2'), t({ "", "\t" }),
    t('echo "💡 Check with: ip addr show"'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Check if local port is free on specific interface" }),
    t('if ss -ltn | grep -q "$LOCAL_IP:$LOCAL_PORT"; then'), t({ "", "\t" }),
    t('echo "❌ Port $LOCAL_PORT on $LOCAL_IP is already in use" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Establish tunnel" }),
    t('echo "🔐 Connecting to $SSH_HOST..."'), t({ "", "" }),
    t('ssh -i "$SSH_KEY" -f -N \\'), t({ "", "" }),
    t('  -o ServerAliveInterval=60 \\'), t({ "", "" }),
    t('  -o ExitOnForwardFailure=yes \\'), t({ "", "" }),
    t('  -L "$LOCAL_IP:$LOCAL_PORT:$TARGET_HOST:$TARGET_PORT" \\'), t({ "", "" }),
    t('  "$SSH_USER@$SSH_HOST"'), t({ "", "" }),
    t({ "", "# 🔹 Verify tunnel" }),
    t('sleep 2'), t({ "", "" }),
    t('if ! ss -ltn | grep -q "$LOCAL_IP:$LOCAL_PORT"; then'), t({ "", "\t" }),
    t('echo "❌ Failed to bind tunnel on $LOCAL_IP:$LOCAL_PORT" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('echo "✅ Tunnel ready: http://$LOCAL_IP:$LOCAL_PORT"'), t({ "", "" }),
    t('echo "🌐 Share this URL with colleagues in your subnet:"'), t({ "", "" }),
    t('echo "   http://$LOCAL_IP:$LOCAL_PORT"'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup on exit" }),
    t('trap \'echo "🧹 Closing tunnel..."; pkill -f "ssh.*-L.*$LOCAL_PORT"\' EXIT INT TERM'),
  }),

   s("ssh-transparent-tunnel", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Transparent SSH Tunnel for Absolute-URL Web Servers"), t({ "", "" }),
    t('TARGET_IP="'), i(1, "192.168.1.120"), t('"  # Must match remote server IP'), t({ "", "" }),
    t('TARGET_PORT="'), i(2, "80"), t('"  # Privileged port → requires sudo'), t({ "", "" }),
    t('TAP_DEV="'), i(3, "tap0"), t('"  # Virtual interface name'), t({ "", "" }),
    t('SSH_USER="'), i(4, "tunneluser"), t('"'), t({ "", "" }),
    t('SSH_HOST="'), i(5, "remotehost.example.com"), t('"'), t({ "", "" }),
    t('SSH_KEY="'), i(6, "~/.ssh/id_ed25519"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 1. Create virtual interface (Linux)" }),
    t('if ! ip addr show 2>/dev/null | grep -q "$TARGET_IP"; then'), t({ "", "\t" }),
    t('echo "🔧 Creating $TAP_DEV with $TARGET_IP..."'), t({ "", "\t" }),
    t('sudo ip tuntap add dev "$TAP_DEV" mode tap user "$USER" 2>/dev/null || true'), t({ "", "\t" }),
    t('sudo ip addr add "$TARGET_IP/24" dev "$TAP_DEV"'), t({ "", "\t" }),
    t('sudo ip link set "$TAP_DEV" up'), t({ "", "fi", "" }),
    t({ "", "# 🔹 2. Check if port is free" }),
    t('if ss -ltn 2>/dev/null | grep -q "$TARGET_IP:$TARGET_PORT"; then'), t({ "", "\t" }),
    t('echo "❌ Port $TARGET_PORT on $TARGET_IP is in use" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 3. Establish tunnel (sudo required for port <1023)" }),
    t('echo "🔐 Establishing transparent tunnel..."'), t({ "", "" }),
    t('sudo ssh -i "$SSH_KEY" -f -N \\'), t({ "", "" }),
    t('  -o ServerAliveInterval=60 \\'), t({ "", "" }),
    t('  -o ExitOnForwardFailure=yes \\'), t({ "", "" }),
    t('  -L "$TARGET_IP:$TARGET_PORT:$TARGET_IP:$TARGET_PORT" \\'), t({ "", "" }),
    t('  "$SSH_USER@$SSH_HOST"'), t({ "", "" }),
    t({ "", "# 🔹 4. Verify" }),
    t('sleep 2'), t({ "", "" }),
    t('if ! ss -ltn 2>/dev/null | grep -q "$TARGET_IP:$TARGET_PORT"; then'), t({ "", "\t" }),
    t('echo "❌ Tunnel failed" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('echo "✅ Transparent tunnel ready: http://$TARGET_IP/"'), t({ "", "" }),
    t('echo "💡 Absolute URLs will work correctly"'), t({ "", "" }),
    t({ "", "# 🔹 5. Cleanup" }),
    t('trap \'echo "🧹 Closing..."; sudo pkill -f "ssh.*-L.*$TARGET_PORT"; sudo ip link set "$TAP_DEV" down 2>/dev/null\' EXIT INT TERM'),
  }),


  s("ssh-remote-forward", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 SSH Remote Port Forwarding: Expose Local Service via Bastion"), t({ "", "" }),
    t('LOCAL_PORT="'), i(1, "22"), t('"  # Local service port (e.g., SSH)'), t({ "", "" }),
    t('REMOTE_BIND="'), i(2, "localhost"), t('"  # Bind on bastion: localhost / 0.0.0.0'), t({ "", "" }),
    t('REMOTE_PORT="'), i(3, "2022"), t('"  # Port on bastion to listen'), t({ "", "" }),
    t('BASTION_USER="'), i(4, "tunneluser"), t('"'), t({ "", "" }),
    t('BASTION_HOST="'), i(5, "bastionhost.example.com"), t('"'), t({ "", "" }),
    t('SSH_KEY="'), i(6, "~/.ssh/id_ed25519"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Validate prerequisites" }),
    t('if [[ "$REMOTE_BIND" != "localhost" && "$REMOTE_BIND" != "127.0.0.1" ]]; then'), t({ "", "\t" }),
    t('echo "⚠️  Warning: Binding to $REMOTE_BIND exposes port to network!" >&2'), t({ "", "\t" }),
    t('read -rp "Continue? [y/N] " -n 1 -r; echo'), t({ "", "\t" }),
    t('[[ $REPLY =~ ^[Yy]$ ]] || exit 1'), t({ "", "fi", "" }),
    t({ "", "# 🔹 Establish remote forward (background, keep-alive)" }),
    t('echo "🔐 Connecting to $BASTION_HOST..."'), t({ "", "" }),
    t('ssh -i "$SSH_KEY" -f -N \\'), t({ "", "" }),
    t('  -o ServerAliveInterval=60 \\'), t({ "", "" }),
    t('  -o ExitOnForwardFailure=yes \\'), t({ "", "" }),
    t('  -o GatewayPorts=no \\'), t({ "", "\t# Prevent remote binding to 0.0.0.0" }), t({ "", "" }),
    t('  -R "$REMOTE_BIND:$REMOTE_PORT:localhost:$LOCAL_PORT" \\'), t({ "", "" }),
    t('  "$BASTION_USER@$BASTION_HOST"'), t({ "", "" }),
    t({ "", "# 🔹 Verify tunnel is active" }),
    t('sleep 2'), t({ "", "" }),
    t('echo "✅ Remote forward ready:"'), t({ "", "" }),
    t('echo "   On bastion: $REMOTE_BIND:$REMOTE_PORT → your localhost:$LOCAL_PORT"'), t({ "", "" }),
    t('echo "   From bastion shell: ssh -p $REMOTE_PORT user@localhost"'), t({ "", "" }),
    t({ "", "# 🔹 Optional: Double-tunnel for extra security (run from home)" }),
    t('# ssh -L 2022:localhost:2022 joeuser@bastionhost.example.com'), t({ "", "" }),
    t('# ssh -p 2022 laptopuser@localhost'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup on exit" }),
    t('trap \'echo "🧹 Closing tunnel..."; pkill -f "ssh.*-R.*$REMOTE_PORT"\' EXIT INT TERM'),
  }),


  s("ssh-public-remote-forward", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Public SSH Remote Forward: Expose Local Web to Internet"), t({ "", "" }),
    t("# ⚠️  WARNING: This creates a PUBLIC backdoor! Use with extreme caution."), t({ "", "" }),
    t('LOCAL_PORT="'), i(1, "80"), t('"  # Local web server port'), t({ "", "" }),
    t('PUBLIC_HOST="'), i(2, "web99.example.com"), t('"  # Public hostname/IP'), t({ "", "" }),
    t('PUBLIC_PORT="'), i(3, "80"), t('"  # Public port (privileged <1023 → root required)'), t({ "", "" }),
    t('REMOTE_USER="'), i(4, "root"), t('"  # Must be root for port <1023'), t({ "", "" }),
    t('SSH_KEY="'), i(5, "~/.ssh/id_ed25519"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Security: Confirm intentional public exposure" }),
    t('echo "⚠️  This will expose your localhost:$LOCAL_PORT to the PUBLIC internet via $PUBLIC_HOST:$PUBLIC_PORT"'), t({ "", "" }),
    t('read -rp "Type YES to confirm: " -r'), t({ "", "" }),
    t('[[ "$REPLY" == "YES" ]] || { echo "❌ Aborted" >&2; exit 1; }'), t({ "", "" }),
    t({ "", "# 🔹 Validate prerequisites on REMOTE host (manual check)" }),
    t('echo "✅ Ensure on $PUBLIC_HOST:"'), t({ "", "" }),
    t('echo "   • AllowTcpForwarding yes"'), t({ "", "" }),
    t('echo "   • GatewayPorts yes (or clientspecified)"'), t({ "", "" }),
    t('echo "   • Port $PUBLIC_PORT not blocked by firewall"'), t({ "", "" }),
    t('echo "   • Running as root (for port <1023)"'), t({ "", "" }),
    t({ "", "# 🔹 Establish public remote forward" }),
    t('echo "🔐 Connecting to $REMOTE_USER@$PUBLIC_HOST..."'), t({ "", "" }),
    t('ssh -i "$SSH_KEY" -f -N \\'), t({ "", "" }),
    t('  -o ServerAliveInterval=60 \\'), t({ "", "" }),
    t('  -o ExitOnForwardFailure=yes \\'), t({ "", "" }),
    t('  -R "$PUBLIC_HOST:$PUBLIC_PORT:localhost:$LOCAL_PORT" \\'), t({ "", "" }),
    t('  "$REMOTE_USER@$PUBLIC_HOST"'), t({ "", "" }),
    t({ "", "# 🔹 Verify tunnel" }),
    t('sleep 3'), t({ "", "" }),
    t('echo "✅ Public tunnel ready!"'), t({ "", "" }),
    t('echo "🌐 Access from anywhere: http://$PUBLIC_HOST/"'), t({ "", "" }),
    t('echo "⏰ Reminder: This is a TEMPORARY exposure. Kill tunnel when done:"'), t({ "", "" }),
    t('echo "   pkill -f \\"ssh.*-R.*$PUBLIC_PORT\\""', "", ""),
    t({ "", "# 🔹 Auto-cleanup after timeout (optional)" }),
    t('# TIMEOUT=3600  # 1 hour'), t({ "", "" }),
    t('# (sleep $TIMEOUT; pkill -f "ssh.*-R.*$PUBLIC_PORT") &'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup on exit" }),
    t('trap \'echo "🧹 Closing public tunnel..."; pkill -f "ssh.*-R.*$PUBLIC_PORT"\' EXIT INT TERM'),
  }),

  s("ssh-vpn", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Layer-3 SSH VPN Tunnel via tun devices (TCP/UDP/ICMP only)"), t({ "", "" }),
    t("# ⚠️  Requires: root on BOTH ends + PermitTunnel yes in sshd_config"), t({ "", "" }),
    t({ "", "# 🔹 Configuration" }),
    t('LOCAL_TUN_IP="'), i(1, "192.168.1.101"), t('"  # Local tun0 IP'), t({ "", "" }),
    t('REMOTE_TUN_IP="'), i(2, "192.168.1.102"), t('"  # Remote tun0 IP'), t({ "", "" }),
    t('SUBNET_MASK="'), i(3, "255.255.255.0"), t('"'), t({ "", "" }),
    t('REMOTE_HOST="'), i(4, "remotehost.example.com"), t('"'), t({ "", "" }),
    t('SSH_KEY="'), i(5, "~/.ssh/id_ed25519"), t('"'), t({ "", "" }),
    t('TUN_LOCAL="'), i(6, "0"), t('"  # Local tun device index'), t({ "", "" }),
    t('TUN_REMOTE="'), i(7, "0"), t('"  # Remote tun device index'), t({ "", "" }),
    t({ "", "# 🔹 Prerequisites check (LOCAL)" }),
    t('if [[ $EUID -ne 0 ]]; then'), t({ "", "\t" }),
    t('echo "❌ Must run as root (sudo) on local machine" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('if ! command -v ssh >/dev/null; then'), t({ "", "\t" }),
    t('echo "❌ ssh not found" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Prerequisites check (REMOTE) — manual validation" }),
    t('echo "✅ Ensure on $REMOTE_HOST (as root):"'), t({ "", "" }),
    t('echo "   • PermitTunnel yes in /etc/ssh/sshd_config"'), t({ "", "" }),
    t('echo "   • PermitRootLogin yes or without-password"'), t({ "", "" }),
    t('echo "   • IPTables allows tun0 traffic"'), t({ "", "" }),
    t('echo "   • Restart sshd if config changed: systemctl restart sshd"'), t({ "", "" }),
    t('read -rp "Press ENTER after verifying remote prerequisites..."'), t({ "", "" }),
    t({ "", "# 🔹 Establish Layer-3 VPN tunnel" }),
    t('echo "🔐 Creating SSH VPN tunnel: tun$TUN_LOCAL ↔ tun$TUN_REMOTE"'), t({ "", "" }),
    t('ssh -i "$SSH_KEY" -f -w "$TUN_LOCAL:$TUN_REMOTE" \\'), t({ "", "" }),
    t('  -o PermitLocalCommand=yes \\'), t({ "", "" }),
    t('  -o ServerAliveInterval=60 \\'), t({ "", "" }),
    t('  "root@$REMOTE_HOST" true'), t({ "", "" }),
    t({ "", "# 🔹 Configure LOCAL tun0 interface" }),
    t('sleep 2  # Wait for tun device creation'), t({ "", "" }),
    t('if ! ip link show tun'), rep(6), t(' >/dev/null 2>&1; then'), t({ "", "\t" }),
    t('echo "❌ Failed to create local tun'), rep(6), t('" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('ip link set tun'), rep(6), t(' up'), t({ "", "" }),
    t('ip addr add "$LOCAL_TUN_IP/$SUBNET_MASK" peer "$REMOTE_TUN_IP" dev tun'), rep(6), t({ "", "" }),
    t('echo "✅ Local tun'), rep(6), t(' configured: $LOCAL_TUN_IP → $REMOTE_TUN_IP"'), t({ "", "" }),
    t({ "", "# 🔹 Configure REMOTE tun0 (via ssh one-liner)" }),
    t('ssh -i "$SSH_KEY" -o PermitLocalCommand=yes "root@$REMOTE_HOST" \\'), t({ "", "" }),
    t('  "ip link set tun'), rep(7), t(' up && \\'), t({ "", "" }),
    t('   ip addr add \\"$REMOTE_TUN_IP/$SUBNET_MASK\\" peer \\"$LOCAL_TUN_IP\\" dev tun'), rep(7), t('"'), t({ "", "" }),
    t('echo "✅ Remote tun'), rep(7), t(' configured: $REMOTE_TUN_IP → $LOCAL_TUN_IP"'), t({ "", "" }),
    t({ "", "# 🔹 Test connectivity" }),
    t('echo "🧪 Testing tunnel with ping..."'), t({ "", "" }),
    t('if ping -c 3 -W 2 "$REMOTE_TUN_IP" >/dev/null 2>&1; then'), t({ "", "\t" }),
    t('echo "✅ Tunnel OK: $LOCAL_TUN_IP ↔ $REMOTE_TUN_IP"'), t({ "", "else", "\t" }),
    t('echo "❌ Ping failed. Check:" >&2'), t({ "", "\t\t" }),
    t('echo "   • IPTables rules on both ends" >&2'), t({ "", "\t\t" }),
    t('echo "   • PermitTunnel/PermitRootLogin on remote" >&2'), t({ "", "\t\t" }),
    t('echo "   • ssh process still running: ps aux | grep \\"ssh.*-w\\""', "", "\t"),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Usage examples" }),
    t('echo "📦 Tunnel ready. Example usage:"'), t({ "", "" }),
    t('echo "   • DNS: dig @$REMOTE_TUN_IP example.com"'), t({ "", "" }),
    t('echo "   • HTTP: curl http://$REMOTE_TUN_IP:80"'), t({ "", "" }),
    t('echo "   • SSH: ssh user@$REMOTE_TUN_IP"'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup on exit" }),
    t('trap \'echo "🧹 Cleaning up..."; \\'), t({ "", "" }),
    t('  pkill -f "ssh.*-w.*$TUN_REMOTE"; \\'), t({ "", "" }),
    t('  ip link set tun'), rep(6), t(' down 2>/dev/null; \\'), t({ "", "" }),
    t('  ip addr del "$LOCAL_TUN_IP/$SUBNET_MASK" peer "$REMOTE_TUN_IP" dev tun'), rep(6), t(' 2>/dev/null; \\'), t({ "", "" }),
    t('  echo "✅ VPN tunnel closed"\' EXIT INT TERM'),
  }),


  s("ssh-vpn", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Layer-2 SSH VPN Tunnel via tap devices (Ethernet frames: DHCP, ARP, STP)"), t({ "", "" }),
    t("# ⚠️  Requires: root on BOTH ends + PermitTunnel ethernet in sshd_config"), t({ "", "" }),
    t({ "", "# 🔹 Configuration" }),
    t('LOCAL_TAP_IP="'), i(1, "192.168.1.101"), t('"  # Local tap0 IP (for management)'), t({ "", "" }),
    t('REMOTE_TAP_IP="'), i(2, "192.168.1.102"), t('"  # Remote tap0 IP (for management)'), t({ "", "" }),
    t('SUBNET_MASK="'), i(3, "255.255.255.0"), t('"'), t({ "", "" }),
    t('REMOTE_HOST="'), i(4, "remotehost.example.com"), t('"'), t({ "", "" }),
    t('SSH_KEY="'), i(5, "~/.ssh/id_ed25519"), t('"'), t({ "", "" }),
    t('TAP_LOCAL="'), i(6, "tap0"), t('"  # Local tap device name'), t({ "", "" }),
    t('TAP_REMOTE="'), i(7, "tap0"), t('"  # Remote tap device name'), t({ "", "" }),
    t('BRIDGE_NAME="'), i(8, "br-kick"), t('"  # Optional bridge name (empty to skip)'), t({ "", "" }),
    t({ "", "# 🔹 Prerequisites check (LOCAL)" }),
    t('if [[ $EUID -ne 0 ]]; then'), t({ "", "\t" }),
    t('echo "❌ Must run as root (sudo) on local machine" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t('if ! command -v ip >/dev/null; then'), t({ "", "\t" }),
    t('echo "❌ iproute2 not found (install iproute2 package)" >&2'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Prerequisites check (REMOTE) — manual validation" }),
    t('echo "✅ Ensure on $REMOTE_HOST (as root):"'), t({ "", "" }),
    t('echo "   • PermitTunnel ethernet in /etc/ssh/sshd_config"'), t({ "", "" }),
    t('echo "   • PermitRootLogin yes or without-password"'), t({ "", "" }),
    t('echo "   • IPTables allows tap0/bridge traffic"'), t({ "", "" }),
    t('echo "   • Restart sshd if config changed: systemctl restart sshd"'), t({ "", "" }),
    t('read -rp "Press ENTER after verifying remote prerequisites..."'), t({ "", "" }),
    t({ "", "# 🔹 Create tap devices on BOTH ends" }),
    t('echo "🔧 Creating local $TAP_LOCAL..."'), t({ "", "" }),
    t('ip tuntap add dev "$TAP_LOCAL" mode tap user root 2>/dev/null || true'), t({ "", "" }),
    t('ip link set "$TAP_LOCAL" up'), t({ "", "" }),
    t('echo "🔧 Creating remote $TAP_REMOTE via SSH..."'), t({ "", "" }),
    t('ssh -i "$SSH_KEY" -o PermitLocalCommand=yes "root@$REMOTE_HOST" \\'), t({ "", "" }),
    t('  "ip tuntap add dev \\"$TAP_REMOTE\\" mode tap user root 2>/dev/null || true; \\'), t({ "", "" }),
    t('   ip link set \\"$TAP_REMOTE\\" up"'), t({ "", "" }),
    t({ "", "# 🔹 Establish Layer-2 VPN tunnel (ethernet mode)" }),
    t('echo "🔐 Creating SSH L2 VPN: $TAP_LOCAL ↔ $TAP_REMOTE"'), t({ "", "" }),
    t('ssh -i "$SSH_KEY" -f -w "$TAP_LOCAL:$TAP_REMOTE" \\'), t({ "", "" }),
    t('  -o Tunnel=ethernet \\'), t({ "", "" }),
    t('  -o ServerAliveInterval=30 \\'), t({ "", "\t# Keep-alive to prevent idle disconnect" }), t({ "", "" }),
    t('  -o ExitOnForwardFailure=yes \\'), t({ "", "" }),
    t('  "root@$REMOTE_HOST" true'), t({ "", "" }),
    t({ "", "# 🔹 Optional: Configure IP addresses (for management/testing only)" }),
    t('# L2 tunnel works WITHOUT IP config — IPs are optional for ping/SSH management'), t({ "", "" }),
    t('if [[ -n "$LOCAL_TAP_IP" ]]; then'), t({ "", "\t" }),
    t('ip addr add "$LOCAL_TAP_IP/$SUBNET_MASK" dev "$TAP_LOCAL"'), t({ "", "\t" }),
    t('echo "✅ Local $TAP_LOCAL: $LOCAL_TAP_IP"'), t({ "", "fi", "" }),
    t('if [[ -n "$REMOTE_TAP_IP" ]]; then'), t({ "", "\t" }),
    t('ssh -i "$SSH_KEY" "root@$REMOTE_HOST" \\'), t({ "", "\t\t" }),
    t('"ip addr add \\"$REMOTE_TAP_IP/$SUBNET_MASK\\" dev \\"$TAP_REMOTE\\""', "", "\t"),
    t('echo "✅ Remote $TAP_REMOTE: $REMOTE_TAP_IP"'), t({ "", "fi", "" }),
    t({ "", "# 🔹 Optional: Bridge mode (for DHCP/broadcast support)" }),
    t('if [[ -n "$BRIDGE_NAME" ]]; then'), t({ "", "\t" }),
    t('echo "🌉 Creating bridge $BRIDGE_NAME..."'), t({ "", "\t" }),
    t('# Install bridge-utils if needed: apt install bridge-utils'), t({ "", "\t" }),
    t('brctl addbr "$BRIDGE_NAME" 2>/dev/null || true'), t({ "", "\t" }),
    t('brctl addif "$BRIDGE_NAME" "$TAP_LOCAL"'), t({ "", "\t" }),
    t('brctl addif "$BRIDGE_NAME" '), i(9, "eth1"), t('  # Physical interface to bridge'), t({ "", "\t" }),
    t('brctl stp "$BRIDGE_NAME" on  # Enable Spanning Tree Protocol'), t({ "", "\t" }),
    t('# Clear IPs from member interfaces'), t({ "", "\t" }),
    t('ip addr flush dev "$TAP_LOCAL" 2>/dev/null || true'), t({ "", "\t" }),
    t('ip addr flush dev '), rep(9), t(' 2>/dev/null || true'), t({ "", "\t" }),
    t('# Assign IP to bridge (not to members)'), t({ "", "\t" }),
    t('ip link set "$BRIDGE_NAME" up'), t({ "", "\t" }),
    t('ip addr add "$LOCAL_TAP_IP/$SUBNET_MASK" dev "$BRIDGE_NAME"'), t({ "", "\t" }),
    t('echo "✅ Bridge $BRIDGE_NAME ready: $LOCAL_TAP_IP"'), t({ "", "fi", "" }),
    t({ "", "# 🔹 Test connectivity" }),
    t('sleep 3  # Wait for link negotiation'), t({ "", "" }),
    t('echo "🧪 Testing tunnel with ping..."'), t({ "", "" }),
    t('if ping -c 3 -W 2 "$REMOTE_TAP_IP" >/dev/null 2>&1; then'), t({ "", "\t" }),
    t('echo "✅ L2 VPN OK: $LOCAL_TAP_IP ↔ $REMOTE_TAP_IP"'), t({ "", "else", "\t" }),
    t('echo "❌ Ping failed. Check:" >&2'), t({ "", "\t\t" }),
    t('echo "   • PermitTunnel ethernet on remote" >&2'), t({ "", "\t\t" }),
    t('echo "   • tap devices exist: ip link show type tap" >&2'), t({ "", "\t\t" }),
    t('echo "   • Link status: ethtool $TAP_LOCAL | grep \\"Link detected\\""', "", "\t"),
    t("exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Usage examples (L2 features)" }),
    t('echo "📦 L2 VPN ready. Example usage:"'), t({ "", "" }),
    t('echo "   • DHCP: dhclient -v $TAP_LOCAL  # Get IP from remote DHCP server"'), t({ "", "" }),
    t('echo "   • ARP: arp -a  # See devices on remote L2 segment"'), t({ "", "" }),
    t('echo "   • PXE boot: Connect client to remote ethX bridged with tap0"'), t({ "", "" }),
    t('echo "   • Broadcast: tcpdump -i $TAP_LOCAL -n broadcast"'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup on exit" }),
    t('trap \'echo "🧹 Cleaning up..."; \\'), t({ "", "" }),
    t('  pkill -f "ssh.*-w.*$TAP_REMOTE"; \\'), t({ "", "" }),
    t('  [[ -n "$BRIDGE_NAME" ]] && brctl delif "$BRIDGE_NAME" "$TAP_LOCAL" 2>/dev/null; \\'), t({ "", "" }),
    t('  [[ -n "$BRIDGE_NAME" ]] && brctl delbr "$BRIDGE_NAME" 2>/dev/null; \\'), t({ "", "" }),
    t('  ip link set "$TAP_LOCAL" down 2>/dev/null; \\'), t({ "", "" }),
    t('  ip tuntap del dev "$TAP_LOCAL" mode tap 2>/dev/null; \\'), t({ "", "" }),
    t('  echo "✅ L2 VPN tunnel closed"\' EXIT INT TERM'),
  }),


  s("bitwise-ops", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Bash Bitwise & Arithmetic Operators Demo"), t({ "", "" }),
    t({ "", "# === BIT SHIFT OPERATORS ===" }),
    t("# 🔹 Left shift (<<): multiply by 2^n"), t({ "", "" }),
    t('x="'), i(1, "10"), t('"'), t({ "", "" }),
    t('echo "x = $x (binary: $(printf \\"%08d\\" $(echo "obase=2;$x" | bc)))"'), t({ "", "" }),
    t('echo "x << 1 = $(( x << 1 ))  # ×2  = $(( x * 2 ))"'), t({ "", "" }),
    t('echo "x << 2 = $(( x << 2 ))  # ×4  = $(( x * 4 ))"'), t({ "", "" }),
    t('echo "x << 3 = $(( x << 3 ))  # ×8  = $(( x * 8 ))"'), t({ "", "" }),
    t('echo "x << 4 = $(( x << 4 ))  # ×16 = $(( x * 16 ))"'), t({ "", "" }),
    t({ "", 'echo "------------"' }),
    t({ "", "# 🔹 Right shift (>>): divide by 2^n (integer)" }), t({ "", "" }),
    t('x="'), i(2, "160"), t('"'), t({ "", "" }),
    t('echo "x = $x (binary: $(printf \\"%08d\\" $(echo "obase=2;$x" | bc)))"'), t({ "", "" }),
    t('echo "x >> 1 = $(( x >> 1 ))  # ÷2  = $(( x / 2 ))"'), t({ "", "" }),
    t('echo "x >> 2 = $(( x >> 2 ))  # ÷4  = $(( x / 4 ))"'), t({ "", "" }),
    t('echo "x >> 3 = $(( x >> 3 ))  # ÷8  = $(( x / 8 ))"'), t({ "", "" }),
    t('echo "x >> 4 = $(( x >> 4 ))  # ÷16 = $(( x / 16 ))"'), t({ "", "" }),
    t({ "", "# === BITWISE LOGICAL OPERATORS ===" }),
    t("# 🔹 AND (&), OR (|), XOR (^), NOT (~)"), t({ "", "" }),
    t('x="'), i(3, "50"), t('"  # binary: 00110010'), t({ "", "" }),
    t('y="'), i(4, "20"), t('"  # binary: 00010100'), t({ "", "" }),
    t('echo "x = $x, y = $y"'), t({ "", "" }),
    t('echo "x & y = $(( x & y ))  # AND: 00010000 = 16"'), t({ "", "" }),
    t('echo "x | y = $(( x | y ))  # OR:  00110110 = 54"'), t({ "", "" }),
    t('echo "x ^ y = $(( x ^ y ))  # XOR: 00100110 = 38"'), t({ "", "" }),
    t('echo "~x    = $(( ~x ))     # NOT: two\'s complement (negative)"'), t({ "", "" }),
    t('echo "~30   = $(( ~30 ))    # NOT: -31 (because ~n = -(n+1))"'), t({ "", "" }),
    t({ "", "# === INCREMENT OPERATORS ===" }),
    t("# 🔹 Post-increment (a++) vs Pre-increment (++a)"), t({ "", "" }),
    t('a="'), i(5, "15"), t('"'), t({ "", "" }),
    t('echo "a = $a"'), t({ "", "" }),
    t('echo "a++ (post) returns: $(( a++ )), then a = $a"'), t({ "", "" }),
    t('a="'), rep(5), t('"  # Reset'), t({ "", "" }),
    t('echo "++a (pre) returns: $(( ++a )), then a = $a"'), t({ "", "" }),
    t({ "", "# 💡 Key difference:" }),
    t('#   a++ : use value FIRST, then increment'), t({ "", "" }),
    t('#   ++a : increment FIRST, then use value'), t({ "", "" }),
    t({ "", "# 🔹 Practical use: flags & masks" }),
    t('FLAG_READ=1'), t({ "", "" }),
    t('FLAG_WRITE=2'), t({ "", "" }),
    t('FLAG_EXEC=4'), t({ "", "" }),
    t('perms=0'), t({ "", "" }),
    t('(( perms |= FLAG_READ | FLAG_WRITE ))  # Add read+write'), t({ "", "" }),
    t('echo "Permissions: $perms (binary: $(printf \\"%03d\\" $(echo "obase=2;$perms" | bc)))"'), t({ "", "" }),
    t('(( perms & FLAG_EXEC )) && echo "✅ Executable" || echo "❌ Not executable"'),
  }),


  s("ssh-reverse-watchdog", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Reverse SSH Tunnel Watchdog (Auto-restart & Health Check)"), t({ "", "" }),
    t("# 💡 Recommended cron: */5 * * * * /path/to/script.sh >/dev/null 2>&1"), t({ "", "" }),
    t('REMOTE_USER="'), i(1, "user"), t('"'), t({ "", "" }),
    t('REMOTE_HOST="'), i(2, "domain.example.com"), t('"'), t({ "", "" }),
    t('SSH_KEY="'), i(3, "~/.ssh/id_ed25519"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Port Mappings: REMOTE_PORT:DEST_HOST:DEST_PORT" }),
    t('declare -a TUNNELS=('), t({ "", "\t" }),
    t('"'), i(4, "12222:localhost:22"), t('"'), t({ "", "\t" }),
    t('"'), i(5, "12223:localhost:5901"), t('"'), t({ "", ")", "" }),
    t({ "", "# 🔹 Build SSH arguments array" }),
    t('SSH_OPTS=( -i "$SSH_KEY" -f -N -T'), t({ "", "\t" }),
    t('  -o ServerAliveInterval=30'), t({ "", "\t" }),
    t('  -o ServerAliveCountMax=3'), t({ "", "\t" }),
    t('  -o ExitOnForwardFailure=yes'), t({ "", "\t" }),
    t('  -o StrictHostKeyChecking=accept-new'), t({ "", "\t" }),
    t('  -o UserKnownHostsFile=/dev/null  # ⚠️ Pre-add keys in production!)'), t({ "", "" }),
    t('for mapping in "${TUNNELS[@]}"; do'), t({ "", "\t" }),
    t('  SSH_OPTS+=( -R "$mapping" )'), t({ "", "done", "" }),
    t('SSH_OPTS+=( "${REMOTE_USER}@${REMOTE_HOST}" )'), t({ "", "" }),
    t({ "", "# 🔹 Helper: Check if tunnel process exists" }),
    t('is_tunnel_alive() {'), t({ "", "\t" }),
    t('  pgrep -f "ssh.*-R.*${REMOTE_HOST}" >/dev/null 2>&1'), t({ "", "}", "" }),
    t({ "", "# 🔹 Helper: Quick connectivity & socket verification" }),
    t('can_reach_remote() {'), t({ "", "\t" }),
    t('  ssh -i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=5 \\'), t({ "", "\t\t" }),
    t('    "${REMOTE_USER}@${REMOTE_HOST}" "echo pong" >/dev/null 2>&1'), t({ "", "}", "" }),
    t({ "", "# 🔹 Main Logic" }),
    t('if is_tunnel_alive; then'), t({ "", "\t" }),
    t('  # Process exists, but connection might be stale (NAT timeout, etc.)"'), t({ "", "\t" }),
    t('  if ! can_reach_remote; then'), t({ "", "\t\t" }),
    t('    echo "⚠️  SSH connection dead. Killing stale PID..."'), t({ "", "\t\t" }),
    t('    pkill -f "ssh.*-R.*${REMOTE_HOST}" 2>/dev/null || true'), t({ "", "\t\t" }),
    t('    sleep 1'), t({ "", "\t" }),
    t('  else'), t({ "", "\t\t" }),
    t('    exit 0  # Tunnel healthy, do nothing'), t({ "", "\t" }),
    t('  fi'), t({ "", "fi", "" }),
    t({ "", "# 🔹 Start New Tunnel" }),
    t('echo "🔐 Establishing reverse SSH tunnel to ${REMOTE_HOST}..."'), t({ "", "" }),
    t('ssh "${SSH_OPTS[@]}" &'), t({ "", "" }),
    t('sleep 2'), t({ "", "" }),
    t('if is_tunnel_alive; then'), t({ "", "\t" }),
    t('  echo "✅ Tunnel started. PID: $(pgrep -f \\"ssh.*-R.*${REMOTE_HOST}\\")"'), t({ "", "\t" }),
    t('  echo "📡 Remote bindings:"'), t({ "", "\t" }),
    t('  for m in "${TUNNELS[@]}"; do echo "   - $m"; done'), t({ "", "else", "\t" }),
    t('  echo "❌ Failed to start tunnel. Check SSH config & keys." >&2'), t({ "", "\t" }),
    t('  exit 1'), t({ "", "fi" }),
  }),



  s("ssh-socks-proxy", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 SSH SOCKS5 Proxy Tunnel (Dynamic Port Forwarding)"), t({ "", "" }),
    t("# 🌐 Routes ALL traffic through remote server via encrypted SSH channel"), t({ "", "" }),
    t({ "", "# 🔹 Configuration" }),
    t('REMOTE_USER="'), i(1, "bogotob1"), t('"'), t({ "", "" }),
    t('REMOTE_HOST="'), i(2, "bogotobogo.com"), t('"'), t({ "", "" }),
    t('SOCKS_PORT="'), i(3, "9001"), t('"  # Local SOCKS proxy port'), t({ "", "" }),
    t('SSH_KEY="'), i(4, "~/.ssh/id_ed25519"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Connection Options" }),
    t('# -D  : Dynamic port forwarding (SOCKS5 proxy)'), t({ "", "" }),
    t('# -4  : Force IPv4 (prevents "Cannot assign requested address")'), t({ "", "" }),
    t('# -N  : No remote command (just forwarding)'), t({ "", "" }),
    t('# -f  : Go to background after authentication'), t({ "", "" }),
    t('# -C  : Enable compression (faster for slow connections)'), t({ "", "" }),
    t('# -v  : Verbose mode (debugging)'), t({ "", "" }),
    t({ "", "# 🔹 Create SOCKS Proxy Tunnel" }),
    t('echo "🔐 Creating SOCKS5 proxy on localhost:$SOCKS_PORT..."'), t({ "", "" }),
    t('ssh -i "$SSH_KEY" \\'), t({ "", "" }),
    t('  -4 \\'), t({ "", "\t# Force IPv4" }), t({ "", "" }),
    t('  -D "$SOCKS_PORT" \\'), t({ "", "\t# SOCKS proxy port" }), t({ "", "" }),
    t('  -N \\'), t({ "", "\t# No remote shell" }), t({ "", "" }),
    t('  -f \\'), t({ "", "\t# Background mode" }), t({ "", "" }),
    t('  -C \\'), t({ "", "\t# Compression" }), t({ "", "" }),
    t('  -o ServerAliveInterval=30 \\'), t({ "", "" }),
    t('  "$REMOTE_USER@$REMOTE_HOST"'), t({ "", "" }),
    t({ "", "# 🔹 Verify tunnel is running" }),
    t('sleep 2'), t({ "", "" }),
    t('if pgrep -f "ssh.*-D.*$SOCKS_PORT" >/dev/null; then'), t({ "", "\t" }),
    t('  echo "✅ SOCKS5 proxy active on localhost:$SOCKS_PORT"'), t({ "", "\t" }),
    t('  echo "📋 PID: $(pgrep -f \\"ssh.*-D.*$SOCKS_PORT\\")"'), t({ "", "else", "\t" }),
    t('  echo "❌ Failed to create SOCKS proxy" >&2'), t({ "", "\t" }),
    t("  exit 1"), t({ "", "fi", "" }),
    t({ "", "# 🔹 Test proxy (optional)" }),
    t('# curl --socks5 localhost:$SOCKS_PORT https://api.ipify.org', "", ""),
    t({ "", "# 🔹 Browser Configuration" }),
    t('echo ""'), t({ "", "" }),
    t('echo "🌐 Configure your browser to use SOCKS5 proxy:"'), t({ "", "" }),
    t('echo "   Host: localhost"'), t({ "", "" }),
    t('echo "   Port: $SOCKS_PORT"'), t({ "", "" }),
    t('echo "   Type: SOCKS5"'), t({ "", "" }),
    t('echo ""'), t({ "", "" }),
    t('echo " Firefox: Settings => Network Settings => Manual proxy"'), t({ "", "" }),
    t('echo "🌐 Chrome: Use proxy extension or system settings"'), t({ "", "" }),
    t({ "", "# 🔹 Cleanup on exit" }),
    t('trap \'echo "🧹 Closing SOCKS proxy..."; pkill -f "ssh.*-D.*$SOCKS_PORT"\' EXIT INT TERM'),
  }),

  -- 🔹 Quick SOCKS proxy (one-liner version)
  s("ssh-socks-quick", {
    t("# Quick SOCKS5 proxy via SSH"), t({ "", "" }),
    t('ssh -4 -D '), i(1, "9001"), t(' -N -f \\'), t({ "", "" }),
    t('  -o ServerAliveInterval=30 \\'), t({ "", "" }),
    t('  '), i(2, "user@remote.host"), t({ "", "" }),
    t({ "", "# Then configure browser: localhost:", rep(1), "" }),
  }),

  -- 🔹 Kill SOCKS proxy
  s("ssh-socks-kill", {
    t("# Kill SOCKS proxy by port"), t({ "", "" }),
    t('SOCKS_PORT="'), i(1, "9001"), t('"'), t({ "", "" }),
    t('pkill -f "ssh.*-D.*$SOCKS_PORT" && echo "✅ SOCKS proxy on port $SOCKS_PORT stopped"'),
  }),

  -- 🔹 1. Basic rsync over SSH
  s("rsync-ssh", {
    t("# 🔹 Rsync over SSH: Basic Sync"), t({ "", "" }),
    t("# Flags: -a (archive), -v (verbose), -e ssh (use SSH)"), t({ "", "" }),
    t('rsync -av -e ssh \\'), t({ "", "" }),
    t('  "'), i(1, "/src/"), t('" \\'), t({ "", "" }),
    t('  "'), i(2, "user@remote"), t(':'), i(3, "/path/to/dst"), t('"'),
    t({ "", "# 💡 Note: Trailing slash on /src/ means 'copy contents'" }),
    t('# Without slash: copies the directory itself'),
  }),

  -- 🔹 2. Rsync over SSH with custom port
  s("rsync-ssh-port", {
    t("# 🔹 Rsync over SSH: Custom Port"), t({ "", "" }),
    t("# Flags: -p 2200 (custom SSH port)"), t({ "", "" }),
    t('rsync -av -e \'ssh -p '), i(1, "2200"), t('\' \\'), t({ "", "" }),
    t('  "'), i(2, "/src/"), t('" \\'), t({ "", "" }),
    t('  "'), i(3, "user@remote"), t(':'), i(4, "/path/to/dst"), t('"'),
  }),

  -- 🔹 3. Rsync with resume & progress support
  s("rsync-resume", {
    t("# 🔹 Rsync with Resume & Progress"), t({ "", "" }),
    t("# Flags: -P = --partial + --progress (resume + show progress)"), t({ "", "" }),
    t('rsync -avP -e ssh \\'), t({ "", "" }),
    t('  "'), i(1, "/src/"), t('" \\'), t({ "", "" }),
    t('  "'), i(2, "user@remote"), t(':'), i(3, "/path/to/dst"), t('"'),
    t({ "", "# 💡 Use this for large files or unstable connections" }),
  }),

  -- 🔹 4. Rsync with compression (good for slow networks)
  s("rsync-compress", {
    t("# 🔹 Rsync with Compression (-z)"), t({ "", "" }),
    t("# Flags: -z (compress data during transfer)"), t({ "", "" }),
    t('rsync -avPz -e ssh \\'), t({ "", "" }),
    t('  "'), i(1, "/src/"), t('" \\'), t({ "", "" }),
    t('  "'), i(2, "user@remote"), t(':'), i(3, "/path/to/dst"), t('"'),
    t({ "", "# 💡 -z reduces bandwidth but increases CPU usage" }),
  }),

  -- 🔹 5. Rsync with delete (mirror mode)
  s("rsync-mirror", {
    t("# 🔹 Rsync Mirror Mode (--delete)"), t({ "", "" }),
    t("# ⚠️  WARNING: Deletes files in dest that don't exist in src!"), t({ "", "" }),
    t('rsync -av --delete -e ssh \\'), t({ "", "" }),
    t('  "'), i(1, "/src/"), t('" \\'), t({ "", "" }),
    t('  "'), i(2, "user@remote"), t(':'), i(3, "/path/to/dst"), t('"'),
    t({ "", "# 💡 Use --dry-run first to preview changes:" }),
    t('# rsync -av --delete --dry-run -e ssh ...'),
  }),

  -- 🔹 6. Full backup script template
  s("rsync_backup_script", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Automated Backup Script with rsync + SSH"), t({ "", "" }),
    t('SRC="'), i(1, "/home/user/data"), t('"'), t({ "", "" }),
    t('DEST_USER="'), i(2, "backup"), t('"'), t({ "", "" }),
    t('DEST_HOST="'), i(3, "backup.example.com"), t('"'), t({ "", "" }),
    t('DEST_PATH="'), i(4, "/backups/daily"), t('"'), t({ "", "" }),
    t('SSH_PORT="'), i(5, "22"), t('"'), t({ "", "" }),
    t('LOG_FILE="'), i(6, "/var/log/rsync-backup.log"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Create destination if needed" }),
    t('ssh -p "$SSH_PORT" "$DEST_USER@$DEST_HOST" \\'), t({ "", "" }),
    t('  "mkdir -p \\"$DEST_PATH\\""', "", ""),
    t({ "", "# 🔹 Run rsync with logging" }),
    t('rsync -avPz --delete \\'), t({ "", "" }),
    t('  -e "ssh -p $SSH_PORT" \\'), t({ "", "" }),
    t('  "$SRC/" \\'), t({ "", "" }),
    t('  "$DEST_USER@$DEST_HOST:$DEST_PATH/" \\'), t({ "", "" }),
    t('  2>&1 | tee -a "$LOG_FILE"'), t({ "", "" }),
    t({ "", "# 🔹 Check exit status" }),
    t('if [[ ${PIPESTATUS[0]} -eq 0 ]]; then'), t({ "", "\t" }),
    t('echo "✅ Backup completed: $(date)" >> "$LOG_FILE"'), t({ "", "else", "\t" }),
    t('echo "❌ Backup FAILED: $(date)" >> "$LOG_FILE"'), t({ "", "\t" }),
    t("exit 1"), t({ "", "fi" }),
  }),

    -- 🔹 1. Multi-hop via ProxyJump (-J) — Modern & Recommended
  s("ssh-multihop-jump", {
    t("# 🔹 Multi-hop SSH via ProxyJump (-J) — HTTP Forwarding"), t({ "", "" }),
    t("# 🌐 Client → Jumphost → Server1 → Server2(HTTP)"), t({ "", "" }),
    t('CLIENT_LOCAL_PORT="'), i(1, "65535"), t('"  # Local port on your machine'), t({ "", "" }),
    t('TARGET_HOST="'), i(2, "192.168.3.12"), t('"  # Final destination (Server2)'), t({ "", "" }),
    t('TARGET_PORT="'), i(3, "80"), t('"  # Service port on Server2 (HTTP)'), t({ "", "" }),
    t('JUMP_USER="'), i(4, "user"), t('"'), t({ "", "" }),
    t('JUMP_HOST="'), i(5, "192.168.1.179"), t('"  # Bastion/Jumphost'), t({ "", "" }),
    t('MIDDLE_USER="'), i(6, "user"), t('"'), t({ "", "" }),
    t('MIDDLE_HOST="'), i(7, "192.168.2.229"), t('"  # Server1 (middle hop)'), t({ "", "" }),
    t({ "", "# 🔹 Command: -J for jump, -L for local forward" }),
    t('ssh -v -N \\'), t({ "", "" }),
    t('  -J "$JUMP_USER@$JUMP_HOST" \\'), t({ "", "\t# First hop: client → jumphost" }), t({ "", "" }),
    t('  -L "$CLIENT_LOCAL_PORT:$TARGET_HOST:$TARGET_PORT" \\'), t({ "", "\t# Forward to Server2:80" }), t({ "", "" }),
    t('  "$MIDDLE_USER@$MIDDLE_HOST"'), t({ "", "\t# Second hop: jumphost → Server1" }), t({ "", "" }),
    t({ "", "# 🔹 Usage: Open browser to http://localhost:$CLIENT_LOCAL_PORT" }),
    t('echo "✅ Tunnel ready: http://localhost:$CLIENT_LOCAL_PORT → $TARGET_HOST:$TARGET_PORT"'),
  }),

  -- 🔹 2. Chained SSH with -t (Legacy multi-hop port forwarding)
  s("ssh-multihop_t", {
    t("# 🔹 Legacy Multi-hop via -t (forced TTY) + chained SSH"), t({ "", "" }),
    t("# ⚠️  Only use if -J is not available (old SSH versions)"), t({ "", "" }),
    t('LOCAL_PORT="'), i(1, "6010"), t('"'), t({ "", "" }),
    t('HOP1_USER="'), i(2, "user1"), t('"'), t({ "", "" }),
    t('HOP1_HOST="'), i(3, "host1"), t('"'), t({ "", "" }),
    t('HOP2_USER="'), i(4, "user2"), t('"'), t({ "", "" }),
    t('HOP2_HOST="'), i(5, "host2"), t('"'), t({ "", "" }),
    t('HOP3_USER="'), i(6, "user3"), t('"'), t({ "", "" }),
    t('HOP3_HOST="'), i(7, "host3"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Chained command: -t -t for nested PTY, -L at each hop" }),
    t('ssh -L "$LOCAL_PORT:localhost:$LOCAL_PORT" \\'), t({ "", "" }),
    t('  -t "$HOP1_USER@$HOP1_HOST" \\'), t({ "", "\t# Hop 1" }), t({ "", "" }),
    t('  ssh -L "$LOCAL_PORT:localhost:$LOCAL_PORT" \\'), t({ "", "" }),
    t('    -t "$HOP2_USER@$HOP2_HOST" \\'), t({ "", "\t# Hop 2" }), t({ "", "" }),
    t('    ssh -L "$LOCAL_PORT:localhost:$LOCAL_PORT" \\'), t({ "", "" }),
    t('      "$HOP3_USER@$HOP3_HOST"'), t({ "", "\t# Hop 3 (final)" }), t({ "", "" }),
    t({ "", "# 💡 Note: Each -L forwards localhost:PORT → next hop's localhost:PORT" }),
  }),

  -- 🔹 3. Nested SSH with explicit -L at each level (most flexible)
  s("ssh-nested-forward", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Nested SSH: Explicit -L at each hop (max control)"), t({ "", "" }),
    t('LOCAL_PORT="'), i(1, "8081"), t('"  # Your machine'), t({ "", "" }),
    t('MIDDLE_PORT="'), i(2, "10000"), t('"  # Intermediate forward port'), t({ "", "" }),
    t('TARGET_PORT="'), i(3, "80"), t('"  # Final service port'), t({ "", "" }),
    t('SERVER_A_USER="'), i(4, "mvriel"), t('"'), t({ "", "" }),
    t('SERVER_A_HOST="'), i(5, "a.server.example.com"), t('"'), t({ "", "" }),
    t('SERVER_B_USER="'), i(6, "mvriel"), t('"'), t({ "", "" }),
    t('SERVER_B_HOST="'), i(7, "b.server.example.com"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Two-level forwarding: Client → ServerA → ServerB → Service" }),
    t({ "", "# 🔹 Build the nested command safely" }),
    t('CMD_INNER="ssh -L $MIDDLE_PORT:localhost:$TARGET_PORT $SERVER_B_USER@$SERVER_B_HOST"'), t({ "", "" }),
    t('ssh -t -t \\'), t({ "", "" }),
    t('  -L "$LOCAL_PORT:localhost:$MIDDLE_PORT" \\'), t({ "", "\t# Client:8081 → ServerA:10000" }), t({ "", "" }),
    t('  "$SERVER_A_USER@$SERVER_A_HOST" \\'), t({ "", "" }),
    t('  "$CMD_INNER"'), t({ "", "\t# ServerA:10000 → ServerB:80" }), t({ "", "" }),
    t({ "", "# 🔹 Result: http://localhost:$LOCAL_PORT on your machine → ServerB:$TARGET_PORT" }),
    t('echo "✅ Nested tunnel: localhost:$LOCAL_PORT → $SERVER_B_HOST:$TARGET_PORT"'),
  }), 

  -- 🔹 4. Simple jump with agent forwarding (-A)
  s("ssh-jumpagent", {
    t("# 🔹 SSH via Jump Host with Agent Forwarding (-A)"), t({ "", "" }),
    t("# 🔐 Allows using your local SSH keys on the target server"), t({ "", "" }),
    t('JUMP_USER="'), i(1, "user"), t('"'), t({ "", "" }),
    t('JUMP_HOST="'), i(2, "192.168.1.179"), t('"'), t({ "", "" }),
    t('TARGET_USER="'), i(3, "user"), t('"'), t({ "", "" }),
    t('TARGET_HOST="'), i(4, "192.168.2.229"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Command: -J for jump, -A for agent forwarding" }),
    t('ssh -A -J "$JUMP_USER@$JUMP_HOST" "$TARGET_USER@$TARGET_HOST"'), t({ "", "" }),
    t({ "", "# ⚠️  Security note: -A forwards your agent — only use with trusted hosts!" }),
    t('# Check forwarded keys on target: ssh-add -l'),
  }),

  -- 🔹 5. SSH Config template for multi-hop (cleanest long-term solution)
  s("ssh-multihop", {
    t("# 🔹 ~/.ssh/config snippet for multi-hop (persistent setup)"), t({ "", "" }),
    t("# ✅ Add this to ~/.ssh/config for reusable aliases"), t({ "", "" }),
    t('Host jumphost'), t({ "", "\t" }),
    t('  HostName '), i(1, "192.168.1.179"), t({ "", "\t" }),
    t('  User '), i(2, "user"), t({ "", "\t" }),
    t('  IdentityFile ~/.ssh/id_ed25519'), t({ "", "" }),
    t({ "", 'Host server1' }), t({ "", "\t" }),
    t('  HostName '), i(3, "192.168.2.229"), t({ "", "\t" }),
    t('  User '), i(4, "user"), t({ "", "\t" }),
    t('  ProxyJump jumphost  # ← Auto-hop via jumphost'), t({ "", "" }),
    t({ "", 'Host server2' }), t({ "", "\t" }),
    t('  HostName '), i(5, "192.168.3.12"), t({ "", "\t" }),
    t('  User '), i(6, "user"), t({ "", "\t" }),
    t('  ProxyJump jumphost,server1  # ← Chain: jumphost → server1 → server2'), t({ "", "" }),
    t({ "", "# 🔹 Usage after config:" }),
    t('# ssh server2  # Automatically hops through jumphost & server1'), t({ "", "" }),
    t('# ssh -L 65535:localhost:80 server2  # Add local forward'),
  }),

  s("nested-function", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Nested Functions in Bash: Scope & Visibility"), t({ "", "" }),
    t("# ⚠️  Nested functions are ONLY visible inside the parent!"), t({ "", "" }),
    t({ "", "function countdown() {" }),
    t('\tlocal count="$1"  # ✅ Modern: use "local" instead of "typeset"'), t({ "", "" }),
    t('\t# 🔹 Nested function: ONLY accessible within countdown()'), t({ "", "\t" }),
    t('\tfunction print_msg() {'), t({ "", "\t\t" }),
    t('\t\tlocal msg="$1"'), t({ "", "\t\t" }),
    t('\t\techo "⏳ $msg"'), t({ "", "\t" }),
    t('\t}'), t({ "", "" }),
    t('\t# 🔹 Main loop'), t({ "", "\t" }),
    t('\twhile [[ $count -gt 0 ]]; do'), t({ "", "\t\t" }),
    t('\t\tprint_msg "Counting down: $count"'), t({ "", "\t\t" }),
    t('\t\t((count--))  # ✅ Modern: use (( )) instead of "let"'), t({ "", "\t" }),
    t('\tdone'), t({ "", "\t" }),
    t('\tprint_msg "🚀 Liftoff!"'), t({ "", "}", "" }),
    t({ "", "# 🔹 Usage Example" }),
    t('countdown '), i(1, "5"), t({ "", "" }),
    t({ "", "# ❌ This would FAIL: print_msg is not visible here!" }),
    t('# print_msg "Test"  # → bash: print_msg: command not found'), t({ "", "" }),
    t({ "", "# 💡 Tip: For reusable helpers, define functions at TOP LEVEL instead:" }),
    t('# function global_helper() { ... }  # Accessible everywhere'),
  }),

    -- 🔹 1. Indexed Arrays: Basic Operations
  s("array-indexed", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Indexed Arrays: Creation, Access, Modify"), t({ "", "" }),
    t({ "", "# 🔹 Method 1: Individual assignment" }),
    t('friend_1="'), i(1, "Anthony"), t('"'), t({ "", "" }),
    t('friend_2="'), i(2, "Mike"), t('"'), t({ "", "" }),
    t({ "", "# 🔹 Method 2: Array literal (recommended)" }),
    t('friends=("'), i(3, "Anthony Mike Noel Tarek Dionysios"), t('")'), t({ "", "" }),
    t({ "", "# 🔹 Access elements (0-based index)" }),
    t('echo "👤 First: ${friends[0]}"'), t({ "", "" }),
    t('echo "👤 Fifth: ${friends[4]}"'), t({ "", "" }),
    t('echo "👤 Sixth (empty): \"${friends[5]:-<not set>}\""'), t({ "", "" }),
    t({ "", "# 🔹 Modify/Add elements" }),
    t('friends[5]="'), i(4, "Claudia"), t('"  # Add new element'), t({ "", "" }),
    t('echo "✅ Added: ${friends[5]}"'), t({ "", "" }),
    t('friends[0]="'), i(5, "Anna"), t('"  # Replace existing'), t({ "", "" }),
    t('echo "✅ Replaced: ${friends[0]}"'), t({ "", "" }),
    t({ "", "# 🔹 Append with +=" }),
    t('friends+=("'), i(6, "Ilaria"), t('")'), t({ "", "" }),
    t('echo "📦 All friends: ${friends[*]}"'), t({ "", "" }),
    t({ "", "# 🔹 Sparse arrays (gaps allowed)" }),
    t('sparse[2]="'), i(7, "Here I am!"), t('"'), t({ "", "" }),
    t('for idx in {0..5}; do'), t({ "", "\t" }),
    t('echo "[$idx] = \"${sparse[$idx]:-<empty>}\""'), t({ "", "done" }),
  }),

  -- 🔹 2. Associative Arrays (Hashes)
  s("array-associative", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Associative Arrays: String Keys → Values"), t({ "", "" }),
    t("# ⚠️  Requires: declare -A (Bash 4.0+)"), t({ "", "" }),
    t({ "", "# 🔹 Declaration & Initialization" }),
    t('declare -A friends'), t({ "", "" }),
    t('friends=(['), i(1, "Mike"), t(']="'), i(2, "is a friend"), t('" ['), i(3, "Anthony"), t(']="'), i(4, "is another friend"), t('")'), t({ "", "" }),
    t({ "", "# 🔹 Alternative: One-by-one assignment" }),
    t('# friends[John]="Doe"'), t({ "", "" }),
    t('# friends[Jane]="Doe"'), t({ "", "" }),
    t({ "", "# 🔹 Access values" }),
    t('echo "👤 Mike: ${friends[Mike]}"'), t({ "", "" }),
    t('echo "👤 Anthony: ${friends[Anthony]}"'), t({ "", "" }),
    t({ "", "# 🔹 Check if key exists" }),
    t('[[ -v friends[Mike] ]] && echo "✅ Mike exists" || echo "❌ Mike missing"'), t({ "", "" }),
    t({ "", "# 🔹 Modify value" }),
    t('friends[Mike]="'), i(5, "is a BEST friend"), t('"'), t({ "", "" }),
    t('echo "✅ Updated: ${friends[Mike]}"'), t({ "", "" }),
    t({ "", "# 🔹 Delete key" }),
    t('unset "friends[Anthony]"'), t({ "", "" }),
    t('echo "🗑️  After unset: ${friends[Anthony]:-<deleted>}"'), t({ "", "" }),
    t({ "", "# 🔹 Empty vs Unset" }),
    t('friends[Mike]=""  # Empty string, but key EXISTS'), t({ "", "" }),
    t('[[ -z "${friends[Mike]}" ]] && echo "⚠️  Value is empty (but key exists)"'), t({ "", "" }),
    t({ "", "# 🔹 Clear entire array" }),
    t('friends=()  # Remove all key-value pairs'), t({ "", "" }),
    t('echo "🧹 Array cleared. Mike: ${friends[Mike]:-<gone>}"'),
  }),

  -- 🔹 3. Iteration Patterns
  s("array-iterate", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Iterating Over Arrays"), t({ "", "" }),
    t({ "", "# 🔹 Indexed Array: By Index" }),
    t('friends=("'), i(1, "Alice Bob Charlie"), t('")'), t({ "", "" }),
    t('echo "📋 By index:"'), t({ "", "" }),
    t('for (( i=0; i<${#friends[@]}; i++ )); do'), t({ "", "\t" }),
    t('echo "  [$i] = ${friends[$i]}"'), t({ "", "done", "" }),
    t({ "", "# 🔹 Indexed Array: By Value (simpler)" }),
    t('echo "📋 By value:"'), t({ "", "" }),
    t('for name in "${friends[@]}"; do'), t({ "", "\t" }),
    t('echo "  👤 $name"'), t({ "", "done", "" }),
    t({ "", "# 🔹 Associative Array: Keys + Values" }),
    t('declare -A roles=([admin]="root" [user]="guest")'), t({ "", "" }),
    t('echo "🔑 Keys + Values:"'), t({ "", "" }),
    t('for key in "${!roles[@]}"; do'), t({ "", "\t" }),
    t('echo "  $key → ${roles[$key]}"'), t({ "", "done", "" }),
    t({ "", "# 🔹 Associative Array: Sorted Keys" }),
    t('echo "🔑 Sorted keys:"'), t({ "", "" }),
    t('for key in $(printf "%s\\n" "${!roles[@]}" | sort); do'), t({ "", "\t" }),
    t('echo "  $key → ${roles[$key]}"'), t({ "", "done" }),
  }),

  -- 🔹 4. Advanced Array Operations
  s("array-advanced", {
    t("#!/usr/bin/env bash"), t({ "", "" }),
    t("# 🔹 Advanced Array Operations"), t({ "", "" }),
    t({ "", "# 🔹 Arithmetic Index (dynamic)" }),
    t('my_array[$((3 * 2))]="'), i(1, "my_value"), t('"'), t({ "", "" }),
    t('echo "🔢 Index 6: ${my_array[6]}"'), t({ "", "" }),
    t({ "", "# 🔹 Negative Index (Bash 4.3+) — from end" }),
    t('friends=("'), i(2, "A B C D E"), t('")'), t({ "", "" }),
    t('echo "🔙 Last: ${friends[-1]}"'), t({ "", "" }),
    t('echo "🔙 Second-last: ${friends[-2]}"'), t({ "", "" }),
    t({ "", "# 🔹 Array Length" }),
    t('echo "📏 Total elements: ${#friends[@]}"'), t({ "", "" }),
    t('echo "📏 Length of friends[0]: ${#friends[0]}"'), t({ "", "" }),
    t({ "", "# 🔹 Slice/Subset" }),
    t('echo "🔪 Slice [1:3]: ${friends[@]:1:3}"'), t({ "", "" }),
    t({ "", "# 🔹 Pattern Substitution" }),
    t('echo "🔄 Replace A→X: ${friends[@]/A/X}"'), t({ "", "" }),
    t('echo "🔄 Remove B: ${friends[@]/B/}"'), t({ "", "" }),
    t({ "", "# 🔹 Unset element (creates sparse array)" }),
    t('unset "friends[1]"'), t({ "", "" }),
    t('echo "🗑️  After unset [1]: ${friends[*]:-<empty>}"'), t({ "", "" }),
    t({ "", "# 🔹 Check if array is empty" }),
    t('[[ ${#friends[@]} -eq 0 ]] && echo "✅ Array is empty" || echo "❌ Array has data"'),
  }),

  -- 🔹 5. Quick Reference Cheat Sheet
  s("array-cheat", {
    t("# 🔹 Bash Array Cheat Sheet"), t({ "", "" }),
    t({ "", "# === INDEXED ARRAYS ===" }),
    t('# Create: arr=("a" "b" "c")'), t({ "", "" }),
    t('# Access: ${arr[0]}, ${arr[@]} (all), ${arr[*]} (joined)'), t({ "", "" }),
    t('# Length: ${#arr[@]} (count), ${#arr[0]} (string length)'), t({ "", "" }),
    t('# Append: arr+=("new")'), t({ "", "" }),
    t('# Delete: unset "arr[1]"'), t({ "", "" }),
    t({ "", "# === ASSOCIATIVE ARRAYS ===" }),
    t('# Declare: declare -A hash'), t({ "", "" }),
    t('# Assign: hash[key]="value"'), t({ "", "" }),
    t('# Keys: "${!hash[@]}"'), t({ "", "" }),
    t('# Exists: [[ -v hash[key] ]]'), t({ "", "" }),
    t('# Delete: unset "hash[key]"'), t({ "", "" }),
    t({ "", "# === SAFE ITERATION ===" }),
    t('# Indexed: for val in "${arr[@]}"; do ... done'), t({ "", "" }),
    t('# Assoc: for key in "${!hash[@]}"; do echo "$key → ${hash[$key]}"; done'), t({ "", "" }),
    t({ "", "# ⚠️  Always quote: \"${arr[@]}\" not ${arr[@]}" }),
    t('# Unquoted: word splitting breaks "hello world" → "hello" "world"'),
  }),

}









