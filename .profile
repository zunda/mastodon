LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/.apt/lib/x86_64-linux-gnu:/app/.apt/usr/lib/x86_64-linux-gnu/mesa:/app/.apt/usr/lib/x86_64-linux-gnu/pulseaudio

# Obtain info from DATABASE_URL
if [ -n "$DATABASE_URL" ]; then
	set -- `echo $DATABASE_URL | sed 's/[:/@]/ /g'`
	export DB_USER=$2
	export DB_PASS=$3
	export DB_NAME=$6
	export DB_HOST=$4
	export DB_PORT=$5
fi

# Obtain info from REDIS_URL
if [ -n "$REDIS_URL" ]; then
	set -- `echo $REDIS_URL | sed 's/[:/@]/ /g'`
	export REDIS_HOST=$4
	export REDIS_PORT=$5
	export REDIS_PASSWORD=$3
fi

# Obtain info from BONSAI_URL for Bonsai Elasticsearch
# run `heroku config:set ES_ENABLED=true` to enable Elasticsearch
if [ -n "$BONSAI_URL" ]; then
	# it seems that we can put everything into ES_HOST
	export ES_HOST=$BONSAI_URL
	export ES_PREFIX=
	export ES_PORT=
fi
