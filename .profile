LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/.apt/lib/x86_64-linux-gnu:/app/.apt/usr/lib/x86_64-linux-gnu/mesa:/app/.apt/usr/lib/x86_64-linux-gnu/pulseaudio

# Enable SSL when connecting to Postgres
if [ -n "$DB_SSLMODE" ]; then
  export DB_SSLMODE=true
fi

# Full text search
# run `heroku run:detached rails chewy:deploy` to create index
# run `heroku config:set ES_ENABLED=true` to enable Elasticsearch

# Obtain info from BONSAI_URL for Bonsai Elasticsearch
if [ -n "$BONSAI_URL" ]; then
	export ES_HOST=$BONSAI_URL
	export ES_PREFIX=
	export ES_PORT=
fi

# Obtain info from SEARCHBOX_SSL_URL for Searchbox Elasticsearch
if [ -n "$SEARCHBOX_SSL_URL" ]; then
	export ES_HOST=$SEARCHBOX_SSL_URL
	export ES_PREFIX=
	export ES_PORT=
fi
