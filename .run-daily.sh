#!/bin/bash
rake db:transfer_prod_db
heroku run rake utilization_today -a t2api > doc/daily
sed '/DEPRECATION/d' ./doc/daily -i
cat doc/daily | pbcopy
git diff
