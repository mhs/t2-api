namespace :db do
  def sysputs(s)
    puts s
    system s
  end
  desc "Copy database instance from t2.herokuapp.com to t2api.herokuapp.com"
  task :transfer_prod_db do
    puts "creating backup of t2-production..."
    sysputs "heroku pgbackups:capture -a t2-production --expire"
    puts "creating backup of t2api..."
    sysputs "heroku pgbackups:capture -a t2api --expire"
    restore_url = `heroku pgbackups:url -a t2-production`
    puts "copying data..."
    sysputs "heroku pgbackups:restore HEROKU_POSTGRESQL_WHITE -a t2api --confirm t2api '#{restore_url}'"
  end

  desc "Copy database instance from t2.herokuapp.com to t2api-staging.herokuapp.com"
  task :transfer_staging_db do
    puts "creating backup of t2-production..."
    sysputs "heroku pgbackups:capture -a t2-production --expire"
    puts "creating backup of t2api-staging..."
    sysputs "heroku pgbackups:capture -a t2api-staging --expire"
    restore_url = `heroku pgbackups:url -a t2-production`
    puts "copying data..."
    sysputs "heroku pgbackups:restore HEROKU_POSTGRESQL_ORANGE -a t2api-staging --confirm t2api-staging '#{restore_url}'"
  end


  desc "Copy database from t2api to localhost"
  task :pull_prod do
    system "heroku db:pull -a t2api --confirm t2api"
  end

  desc "Copy database from t2api to localhost"
  task :pull_staging do
    system "heroku db:pull -a t2api-staging --confirm t2api-staging"
  end

  desc "Complete reset of local database from staging"
  task :refresh => [ :drop, :create, :pull_staging ]

  desc "Complete reset of local database from production"
  task :refresh_from_production => [ :drop, :create, :pull_prod ]
end
