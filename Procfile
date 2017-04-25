web: [ -n "$RUN_WEB" ] && puma -C config/puma.rb & [ -n "$RUN_WORKER" ] && sidekiq -q default -q push -q pull -q mailers & [ -n "$RUN_STREAMING" ] && npm start & wait
worker: sidekiq -q default -q push -q pull -q mailers
release: rake db:migrate
