# Obtain info from REDIS_URL
export REDIS_HOST=`echo $REDIS_URL | cut -d: -f3 | cut -d@ -f2`
export REDIS_PORT=`echo $REDIS_URL | cut -d: -f4`
export REDIS_PASSWORD=`echo $REDIS_URL | cut -d: -f3 | cut -d@ -f1`
