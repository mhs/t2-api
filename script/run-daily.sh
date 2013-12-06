#!/bin/bash
rake db:transfer_prod_db
heroku run rake utilization:today -a t2api > doc/daily
sed -i -e '/DEPRECATION/d' ./doc/daily
sed -i -e '/Running/d' ./doc/daily
rm doc/daily-e
cat doc/daily | pbcopy
heroku run rake db:migrate:up VERSION=20130821193648 -a t2api
heroku run rake db:migrate:up VERSION=20130823175015 -a t2api
heroku run rake db:migrate:up VERSION=20130904145751 -a t2api
heroku run rake db:migrate:up VERSION=20131015175419 -a t2api
heroku run rake db:migrate:up VERSION=20131101135609 -a t2api
heroku run rake db:migrate:up VERSION=20131120221416 -a t2api
heroku run rake db:migrate:up VERSION=20131121211844 -a t2api
heroku run rake db:migrate:up VERSION=20131202202359 -a t2api
heroku run rake db:link_people_to_users -a t2api
heroku run rake db:clean_users_and_people -a t2api
heroku run rake applications:set_default_for_all -a t2api
heroku run rake db:restore_deleted_from_snapshots -a t2api
heroku run rake db:set_initial_roles
