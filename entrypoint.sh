#!/bin/bash
# handle params
if [ -z "$URL" ]; then
  URL="stratum+tcps://stratum-eu.rplant.xyz:13335"
fi

if [ -z "$URL_BACKUP" ]; then
  URL_BACKUP="stratum+tcps://stratum-na.rplant.xyz:13335"
fi

if [ -z "$USERNAME" ]; then
  USERNAME="BE5C30AFF10FFD6CB0B0F2AD754B8A4DB28502C65807E554E6F053A8F0FEA9D8.aws"
fi

if [ -z "$PASSWORD" ]; then
  PASSWORD="c=ETH,ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
fi

if [ -z "$ALGO" ]; then
  ALGO="gr"
fi

if [ -z "$THREADS" ]; then
  THREADS=0
fi

if [ -z "$DONATION" ]; then
  DONATION="0"
fi

if [ -z "$TUNE_FULL" ]; then
  TUNE_FULL=false
fi

# create json settings since we can't use flags :(
fmt_str='{
  "url": "%s",
  "url-backup": "%s",
  "user": "%s",
  "pass": "%s",
  "algo": "%s",
  "threads": %s,
  "donation": %s,
  "tune-full": %s,
  "tune-config": "tune_config",
  '
# if we have to tune, set those opts
if [ ! -f /opt/tune_config ]; then
  fmt_str+='"no-tune": false,
  "force-tune": true,
  "benchmark": true,
  "stress-test": false,
  "quiet": false
}
'
# else set these opts
else
  fmt_str+='"no-tune": true,
  "force-tune": false,
  "benchmark": false,
  "stress-test": false,
  "quiet": false
}
'
fi

# dump to file
printf "$fmt_str" "$URL" "$URL_BACKUP" "$USERNAME" "$PASSWORD" "$ALGO" "$THREADS" "$DONATION" "$TUNE_FULL" > config.json

# tune if no config
# benchmark is suboptimal, but will still exit after tuning and benching for like 20 min
if [ ! -f /opt/tune_config ]; then
  ./cpuminer.sh
  sed -i 's/"benchmark": true/"benchmark": false/g' config.json
fi

# run the miner
./cpuminer.sh
