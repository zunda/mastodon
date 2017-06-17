web: [ "$RUN_STREAMING" != "true" ] && puma -C config/puma.rb & [ "$RUN_WORKER" == "true" ] && sidekiq -c ${SIDEKIQ_THREADS:-5} & [ "$RUN_STREAMING" == "true" ] && npm start & wait
worker: sidekiq -c ${SIDEKIQ_THREADS:-5}
release: if [ "$RUN_STREAMING" != "true" ]; then rake db:migrate; else echo Not migrating on this app; fi
