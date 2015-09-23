export FZF_DEFAULT_OPTS='
--extended
--bind ctrl-f:page-down,ctrl-b:page-up
--color fg:252,bg:233,hl:220,fg+:252,bg+:235,hl+:226
--color info:144,prompt:161,spinner:135,pointer:135,marker:118
'

# fzf quickly access to emacs buffer
febf() 
{
	local EMACSCLIENT=$(which emacsclient)
	buffers=$($EMACSCLIENT -e "(mapcar #'(lambda(x) (buffer-name x)) (buffer-list))")
	local SYSTEM_TYPE=$(uname -a | awk '{print $1}')
	local sed_regex_opt="-E"
	if [[ $SYSTEM_TYPE == Linux ]]; then
		sed_regex_opt="-r"
	fi

	buffers=$(echo $buffers |sed $sed_regex_opt -e "s/\(//g" \
		-e "s/\)//g" \
		-e "s/\" \"/,/g" \
		-e "s/\"//g" \
		-e "s/[\ ]?\*([^,])*\*[-_a-zA-Z0-9]*[,]?//g" \
		-e "s/[^,]*mode,//g" \
		-e "s/,$//g")

	bname_arra=()
	if [[ $SHELL == *zsh ]]; then
		IFS=', ' read -A bname_arr <<< "$buffers"
	elif [[ $SHELL == *bash ]]; then
		IFS=', ' read -a bname_arr <<< "$buffers"
	fi
	target_buffer=$( \
	for b in ${bname_arr[@]}
	do
		echo $b
	done | fzf-tmux --query="$1" --select-1) && \
		$EMACSCLIENT -t -e "(switch-to-buffer \"${target_buffer}\")"

}

