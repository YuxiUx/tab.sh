#!/usr/bin/env bash

CHORD=(A Am D D7 Dm G G7 F E E7 H)
#DELIM=unset
time=2
sep=" "
VAR=0
ISEP=1

HELP_SPC="       $(tr "[:print:]" ' ' <<< "$0")"
HELP="\
usage: $0 [-h] [-t DELAY] [-i  CHORD_FILE] [-c CHORDS] [-d DELIM]
$HELP_SPC [-s SEP] [-v MAX] [-V]

  -h, --help		  print this help
  -t, --time      delay between updates
  -i, --input		  chord set from file
  -c, --chords		chord set from string
  -d, --delimiter	(default: -i newline, -c space)
  -s, --separator	Separator between chords
  -v, --var-speed random delay variation (1..v)times delay
  -V, --var-isep  ignore separator in variable time
Random \"song\" generator
"

usage() {
	printf "%s\n" "$HELP"
	exit 2
}
invalid() {
	echo "Unknown option: $1"
	usage
}

# convert long flags to short so they can be processed by getopts
for arg in "$@"; do
	shift
	case "$arg" in
		"--help")      set -- "$@" "-h";;
		"--input")     set -- "$@" "-i";;
		"--chords")    set -- "$@" "-c";;
		"--delimiter") set -- "$@" "-d";;
		"--time")      set -- "$@" "-t";;
		"--separator") set -- "$@" "-s";;
		"--var-speed") set -- "$@" "-v";;
		"--var-isep")  set -- "$@" "-V";;
		"--"*)         invalid "$arg"  ;;
		*)             set -- "$@" "$arg";;
	esac
done

# process -d flag first
grep -wq "\-d" <<< "$@" && {
	DELIM="${*:$((
	    $(printf "%s\n" "$@" | grep -m1 -xn "\-d" | cut -d: -f1) + 1
	  )):1
	}"
}

while getopts hd:i:c:t:s:v:V arg; do
	case "${arg}" in
		h) printf %s "$HELP"; exit;;
		d) continue;;
		i) [[ "$DELIM" ]] || DELIM='\n'
		   mapfile -t CHORD <<< "$(tr "$DELIM" '\n' < "$OPTARG")";;
		c) [[ "$DELIM" ]] || DELIM=' '
		   mapfile -t CHORD <<< "$(tr "$DELIM" '\n' <<< "$OPTARG")";;
		t) time="$OPTARG";;
		s) sep="$OPTARG";;
		v) VAR="$OPTARG";;
		V) ISEP=0;;
		*) invalid "$arg";;
	esac
done

getChord() {
	printf %b "${CHORD[$((RANDOM % ${#CHORD[@]}))]}"
}
timer() {
	[ "$2" -eq 0 ] && return;
	for i in $(seq $((RANDOM%$2))); do
		sleep "$1"
		printf %b "$3"
	done
}

while :; do
	getChord
	timer "$time" "$VAR" "$([ $ISEP -ne 0 ] && echo "$sep")"
	sleep "$time"
	printf %b "$sep"
done

