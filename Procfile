web: if [ "$RUN_STREAMING" != "true" ]; then BIND=0.0.0.0 puma -C config/puma.rb & fi; if [ "$RUN_WORKER" == "true" ]; then sidekiq -c ${SIDEKIQ_THREADS:-5} & fi; if [ "$RUN_STREAMING" == "true" ]; then BIND=0.0.0.0 node ./streaming & fi; wait -n
worker: sidekiq -c ${SIDEKIQ_THREADS:-5}
release: if [ "$RUN_STREAMING" != "true" ]; then rake db:migrate; else echo Not migrating on this app; fi

# For the streaming API, you need a separate app that shares Postgres and Redis:
#
# heroku create
# heroku buildpacks:add heroku/nodejs
# heroku config:set RUN_STREAMING=true
# heroku addons:attach <main-app>::DATABASE
# heroku addons:attach <main-app>::REDIS
#
# and let the main app use the separate app:
#
# heroku config:set STREAMING_API_BASE_URL=wss://<streaming-app>.herokuapp.com -a <main-app>
