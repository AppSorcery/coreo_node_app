#!/bin/bash

echo "forever-service install $APP_NAME --script app.js -o \" $APP_STARTUP_ARGS\""
forever-service install $APP_NAME --script app.js -o " $APP_STARTUP_ARGS"
service $APP_NAME start
