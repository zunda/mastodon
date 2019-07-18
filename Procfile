web: if [ "$RUN_STREAMING" != "true" ]; then jemalloc.sh BIND=0.0.0.0 puma -C config/puma.rb & fi; if [ "$RUN_WORKER" == "true" ]; then jemalloc.sh sidekiq -c ${SIDEKIQ_THREADS:-5} & fi; if [ "$RUN_STREAMING" == "true" ]; then BIND=0.0.0.0 npm start & fi; wait -n
worker: jemalloc.sh sidekiq -c ${SIDEKIQ_THREADS:-5}
release: if [ "$RUN_STREAMING" != "true" ]; then rake db:migrate; else echo Not migrating on this app; fi
