web: if [ "$RUN_STREAMING" != "true" ]; then jemalloc.sh puma -b 0.0.0.0 -C config/puma.rb & fi; if [ "$RUN_WORKER" == "true" ]; then jemalloc.sh sidekiq -c ${SIDEKIQ_THREADS:-5} & fi; if [ "$RUN_STREAMING" == "true" ]; then npm start & fi; wait -n
worker: jemalloc.sh sidekiq -c ${SIDEKIQ_THREADS:-5}
release: if [ "$RUN_STREAMING" != "true" ]; then rake db:migrate; else echo Not migrating on this app; fi
