# Obtain info from DATABASE_URL
export DB_USER=`echo $DATABASE_URL | cut -d: -f2 | sed 's/\/\///'`
export DB_PASS=`echo $DATABASE_URL | cut -d: -f3 | cut -d@ -f1`
export DB_NAME=`echo $DATABASE_URL | cut -d/ -f4`
export DB_HOST=`echo $DATABASE_URL | cut -d: -f3 | cut -d@ -f2`
export DB_PORT=`echo $DATABASE_URL | cut -d: -f4 | cut -d/ -f1`

# Obtain info from REDIS_URL
export REDIS_HOST=`echo $REDIS_URL | cut -d: -f3 | cut -d@ -f2`
export REDIS_PORT=`echo $REDIS_URL | cut -d: -f4`
export REDIS_PASSWORD=`echo $REDIS_URL | cut -d: -f3 | cut -d@ -f1`
