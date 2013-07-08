namespace :db do
  desc "Copy database instance from t2.herokuapp.com to t2api.herokuapp.com"
  task :copy_prod do
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
    puts "migrating database..."
    sysputs "heroku run rake db:migrate"
  end
end
