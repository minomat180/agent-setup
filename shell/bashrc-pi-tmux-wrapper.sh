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
	local session esc_args
	session="pi-$(basename "$PWD" | tr -c 'a-zA-Z0-9_' '-')"
	if tmux has-session -t "$session" 2>/dev/null; then
		exec tmux attach -t "$session"
	fi
	printf -v esc_args '%q ' "$@"
	exec tmux new-session -s "$session" "command pi $esc_args"
}
