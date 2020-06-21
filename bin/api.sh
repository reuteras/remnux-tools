#!/bin/bash

if [ ! -e ~/remnux-tools/config.cfg ]; then
    echo "Can't find ~/remnux-tools/config.cfg."
    exit 1
fi

# shellcheck disable=SC1090
. ~/remnux-tools/config.cfg

if [[ ! -e ~/.shodan/api_key && -n "$SHODAN_API_KEY" ]]; then
    if type shodan > /dev/null 2>&1 ; then
        echo -n "Initialize Shodan API (access via command shodan): "
        shodan init "$SHODAN_API_KEY"
    fi
fi

if [[ -e ~/src/python/tweets_analyzer/secrets.py ]]; then
    if grep xxxxxxxxxxxxxx ~/src/python/tweets_analyzer/secrets.py > /dev/null ; then
        if [[ -n "$TWITTER_CONSUMER_KEY" && -n "$TWITTER_CONSUMER_SECRET" \
            && -n "$TWITTER_ACCESS_TOKEN" && -n "$TWITTER_ACCESS_TOKEN_SECRET" ]]; then
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

# Configure GIT
if [[ -n $REMNUX_EDITOR ]]; then
    if [[ $(git config --global --get core.editor) != "$REMNUX_EDITOR" ]]; then
        git config --global core.editor "$REMNUX_EDITOR"
    fi
fi

if [[ -n $REMNUX_EMAIL ]]; then
    if [[ $(git config --global --get user.email) != "$REMNUX_EMAIL" ]]; then
        git config --global user.email "$REMNUX_EMAIL"
    fi
fi

if [[ -n $REMNUX_NAME ]]; then
    if [[ $(git config --global --get user.name) != "$REMNUX_NAME" ]]; then
        git config --global user.name "$REMNUX_NAME"
    fi
fi

