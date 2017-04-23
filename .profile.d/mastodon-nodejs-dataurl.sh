# Obtain info from DATABASE_URL
set -- `echo $DATABASE_URL | sed 's/[:/@]/ /g'`
export DB_USER=$2
export DB_PASS=$3
export DB_NAME=$6
export DB_HOST=$4
export DB_PORT=$5

# Obtain info from REDIS_URL
set -- `echo $REDIS_URL | sed 's/[:/@]/ /g'`
export REDIS_HOST=$4
export REDIS_PORT=$5
export REDIS_PASSWORD=$3
