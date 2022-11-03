#!/bin/sh
echo "> Testing Kong readiness at prefix $KONG_PREFIX" >> /tmp/readiness.log

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8100/status)
RESULT=$?

echo "> /status response code is $STATUS_CODE and curl return code is $RESULT" >> /tmp/readiness.log

if [ "$RESULT" == "0" ] && [ "$STATUS_CODE" == "200" ]
then
  echo "> /status endpoint is up - now checking Konnect cache" >> /tmp/readiness.log

  CACHE_SIZE=$(stat -c %s "$KONG_PREFIX/config.cache.json.gz")
  if [ "$CACHE_SIZE" -gt "1" ]
  then
    echo "> Konnect cache is OK with size $CACHE_SIZE - returning 0" >> /tmp/readiness.log
  else
    echo "! Konnect cache is NOT OK - returning 1" >> /tmp/readiness.log
    echo "Konnect cache is NOT OK"
    exit 1
  fi
else
  echo "! /status endpoint is NOT OK - returning 1" >> /tmp/readiness.log
  echo "/status endpoint is NOT OK"
  exit 1
fi
