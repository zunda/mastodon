web: if [ "$RUN_STREAMING" != "true" ]; then puma -C config/puma.rb & fi; if [ "$RUN_WORKER" == "true" ]; then sidekiq -c ${SIDEKIQ_THREADS:-5} & fi; if [ "$RUN_STREAMING" == "true" ]; then npm start & fi; wait -n
worker: sidekiq -c ${SIDEKIQ_THREADS:-5}
#release: if [ "$RUN_STREAMING" != "true" ]; then rake db:migrate; else echo Not migrating on this app; fi
