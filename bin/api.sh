#!/bin/bash

if [ ! -e ~/remnux-tools/config.cfg ]; then
    echo "Can't find ~/remnux-tools/config.cfg."
    exit 1
fi

# shellcheck disable=SC1090
. ~/remnux-tools/config.cfg

if [[ ! -e ~/.shodan/api_key && ! -z "$SHODAN_API_KEY" ]]; then
    echo -n "Initialize Shodan API (access via command shodan): "
    shodan init "$SHODAN_API_KEY"
fi

if [[ -e ~/src/python/tweets_analyzer/secrets.py ]]; then
    if grep xxxxxxxxxxxxxx ~/src/python/tweets_analyzer/secrets.py > /dev/null ; then
        if [[ ! -z "$TWITTER_CONSUMER_KEY" && ! -z "$TWITTER_CONSUMER_SECRET" \
            && ! -z "$TWITTER_ACCESS_TOKEN" && ! -z "$TWITTER_ACCESS_TOKEN_SECRET" ]]; then
            {
                echo 'consumer_key="'"$TWITTER_CONSUMER_KEY"'"'
                echo 'consumer_secret="'"$TWITTER_CONSUMER_SECRET"'"'
                echo 'access_token="'"$TWITTER_ACCESS_TOKEN"'"'
                echo 'access_token_secret="'"$TWITTER_ACCESS_TOKEN_SECRET"'"'
            } > ~/src/python/tweets_analyzer/secrets.py
            echo "Configured Twitter tokens for tweets_analyzer."
        else
            echo "No configuration for twitter in ~/remnux-tools/config.cfg"
        fi
    fi
fi
