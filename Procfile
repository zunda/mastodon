web: [ -n "$RUN_WEB" ] && puma -C config/puma.rb & [ -n "$RUN_WORKER" ] && sidekiq -c ${SIDEKIQ_THREADS:-5} & [ -n "$RUN_STREAMING" ] && npm start & wait
worker: sidekiq
release: if [ -n "$RUN_WEB" ]; then rake db:migrate; else echo Not migrating on this app; fi
