#!/bin/bash
for i in $(cat .env); do
	export $i
done

mkdir -p custom
mkdir -p config/traefik 
touch config/traefik/acme.json
chmod 600 config/traefik/acme.json

if [ ! -f .env ] && [ -f example.env]; then
        cp example.env .env
fi;

if [ ! -f config/traefik/traefik.toml ] && [ -f traefik.toml]; then
	cp traefik.toml config/traefik/traefik.toml
fi;

CMD_ARGS='-f docker-compose.yml'
for filename in services/*.yml; do
	base=${filename%.*}
	base=${base#services/*}
	if [ ${!base:-0} -eq 1 ] ; then
#		echo "including $base in compose"
		CMD_ARGS="${CMD_ARGS} -f ${filename}"
		if [ -f "custom/${filename}" ] ; then
			CMD_ARGS="${CMD_ARGS} -f custom/${filename}"
		fi
#	else 
#		echo "$base not enabled"
	fi
done;

echo ${CMD_ARGS}


