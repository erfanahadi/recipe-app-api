#!/bin/sh

set -e

envsubst < /etc/nginx/default.conf.template > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'