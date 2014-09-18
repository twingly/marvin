# Marvin the Paranoid Android

Our [hubot](http://hubot.github.com/).

## Getting started

After cloning this repo, add the Heroku remote which makes it easier to work with the `heroku` command (`brew install heroku` if you don't have it).

    git remote add heroku git@heroku.com:twinglybot.git

## Environment variables

Environment variables in use by the bot (`heroku config`).

    HEROKU_URL
    HUBOT_GIPHY_API_KEY
    HUBOT_HIPCHAT_JID
    HUBOT_HIPCHAT_PASSWORD
    HUBOT_PINGDOM_USERNAME
    HUBOT_PINGDOM_PASSWORD
    HUBOT_PINGDOM_APP_KEY
    HUBOT_PINGDOM_WEBHOOK_SECRET
    PINGDOM_HIPCHAT_AUTH_TOKEN
    PINGDOM_HIPCHAT_ROOM_TOKEN
    REDISTOGO_URL
    HUBOT_URL_TITLE_IGNORE_URLS
    HUBOT_URL_TITLE_IGNORE_USERS

## Deployment

    git push heroku master
