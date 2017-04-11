#!/bin/bash

session=GBot6
session2=ScriptGban
session3=RedisServer

if [ "$1" = "" ]; then
    sudo tmux new-session -s "$session3" -d 'service redis-server start'
	sudo tmux attach-session -t $session || sudo tmux new-session -s $session -d 'lua bot.lua' && sudo tmux attach-session -t $session
	sudo tmux attach -t "$session"
	clear
	sudo tmux kill-session -t $session
clear

while true
do
    lua bot.lua
	echo -e '\e[0;31mCRASH DETECTADO\e[0m'
	echo -e '\e[0;31mREINICIANDO\e[0m'
for i in 1
do
	echo "$i..."
done
	echo -e '\e[0;32m###########################################\e[0m'
	echo -e '\e[0;32m#             Bot reiniciado              #"\e[0m'
	echo -e '\e[0;32m###########################################"\e[0m'
done
fi

if [ "$1" = "attach" ]; then
	clear
	tmux kill-session -t $session
	clear
	tmux new-session -s $session -d 'lua bot.lua'
	tmux attach -t $session
fi

if [ "$1" = "attach-gbans" ]; then
	clear
	sudo tmux attach -t "$session2"
fi


if [ "$1" = "kill" ]; then
	clear
	sudo tmux kill-session -t $session
	sudo tmux kill-session -t $session2
fi
