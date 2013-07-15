namespace :db do
  desc "Copy database instance from t2.herokuapp.com to t2api.herokuapp.com"
  task :transfer_prod_db do
    def sysputs(s)
      puts s
      system s
    end
    puts "creating backup of t2-production..."
    sysputs "heroku pgbackups:capture -a t2-production --expire"
    puts "creating backup of t2api..."
    sysputs "heroku pgbackups:capture -a t2api --expire"
    restore_url = `heroku pgbackups:url -a t2-production`
    puts "copying data..."
    sysputs "heroku pgbackups:restore HEROKU_POSTGRESQL_WHITE -a t2api --confirm t2api '#{restore_url}'"
  end


  desc "Copy database from t2api to localhost"
  task :pull do
    system "heroku db:pull -a t2api --confirm t2api"
  end

  desc "Complete reset of local database from prod"
  task :refresh => [ :drop, :create, :pull ]
end
