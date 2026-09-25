pi() {
	case "$1" in
		install|remove|uninstall|update|list|config|--version|-v|--help|-h)
			command pi "$@"
			return
			;;
	esac
	case " $* " in
		*" -p "*|*" --print "*|*" --mode "*)
			command pi "$@"
			return
			;;
	esac
	if [ -n "$TMUX" ]; then
		command pi "$@"
		return
	fi
	if ! command -v tmux >/dev/null 2>&1; then
		command pi "$@"
		return
	fi
	local base session esc_args n
	base="pi-$(basename "$PWD" | tr -c 'a-zA-Z0-9_' '-')"
	session="$base"
	n=2
	while tmux has-session -t "$session" 2>/dev/null; do
		session="$base-$n"
		n=$((n + 1))
	done
	printf -v esc_args '%q ' "$@"
	tmux new-session -s "$session" "command pi $esc_args"
}
