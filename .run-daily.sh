#!/bin/bash
rake db:transfer_prod_db
heroku run rake utilization_today -a t2api > doc/daily
sed -i -e '/DEPRECATION/d' ./doc/daily
sed -i -e '/Running/d' ./doc/daily
rm doc/daily-e
cat doc/daily | pbcopy
heroku run rake db:migrate:up VERSION=20130821193648 -a t2api
heroku run rake db:migrate:up VERSION=20130823175015 -a t2api
heroku run rake db:link_people_to_users -a t2api
git diff
