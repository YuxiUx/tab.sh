

accords=(A Am D D7 Dm G G7 F E E7 H)

while :; do 
	echo ${accords[$[$RANDOM % ${#accords[@]}]]}
	sleep $1
done
