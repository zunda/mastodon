web: if [ "$RUN_STREAMING" != "true" ]; then BIND=0.0.0.0 bundle exec puma -C config/puma.rb & else BIND=0.0.0.0 node ./streaming & fi; if [ "$RUN_WORKER" == "true" ]; then sleep 25; if [ "$RUN_SCHEDULE" == "true" ]; then bundle exec sidekiq -c ${SIDEKIQ_THREADS:-5} & else bundle exec sidekiq -c ${SIDEKIQ_THREADS:-5} -q default -q ingress -q mailers -q pull -q push -q fasp & fi; fi; trap '' SIGTERM; wait -n; kill -SIGTERM -$$; wait
worker: if [ "$RUN_SCHEDULE" == "true" ]; then bundle exec sidekiq -c ${SIDEKIQ_THREADS:-5}; else bundle exec sidekiq -c ${SIDEKIQ_THREADS:-5} -q default -q ingress -q mailers -q pull -q push -q fasp; fi
release: if [ "$RUN_STREAMING" != "true" ]; then bundle exec rake db:migrate && rails runner Rails.cache.clear; else echo Not migrating on this app; fi

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
# heroku config:set STREAMING_API_BASE_URL=wss://<streaming-app-random>.herokuapp.com -a <main-app>

