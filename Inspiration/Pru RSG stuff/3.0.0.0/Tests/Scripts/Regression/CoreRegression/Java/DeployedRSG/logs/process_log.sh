#!/usr/bin/env bash
file=$1

if [ ! -e "$file" ]; then
	echo "File '$file' dioes not exist!"
	exit 1
fi

#awk '/Configuring system for test/ { gsub("\047", ""); gsub(":", "_"); file_name=$1$6; getline; }{ print > (file_name); }' $file

awk '/Setup/ {x="F"++i;next}{print > x;}' $file


