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
  task :transfer_staging_db_from_t2 do
    puts "creating backup of t2-production..."
    sysputs "heroku pgbackups:capture -a t2-production --expire"
    puts "creating backup of t2api-staging..."
    sysputs "heroku pgbackups:capture -a t2api-staging --expire"
    restore_url = `heroku pgbackups:url -a t2-production`
    puts "copying data..."
    sysputs "heroku pgbackups:restore HEROKU_POSTGRESQL_ORANGE -a t2api-staging --confirm t2api-staging '#{restore_url}'"
    puts "obscuring project names..."
    sysputs "heroku run rake obscure_projects -a t2api-staging"
  end

  desc "Copy database instance from t2api.herokuapp.com to t2api-staging.herokuapp.com"
  task :transfer_staging_db_from_prod do
    puts "creating backup of t2api..."
    sysputs "heroku pgbackups:capture -a t2api --expire"
    puts "creating backup of t2api-staging..."
    sysputs "heroku pgbackups:capture -a t2api-staging --expire"
    restore_url = `heroku pgbackups:url -a t2api`
    puts "copying data..."
    sysputs "heroku pgbackups:restore HEROKU_POSTGRESQL_ORANGE -a t2api-staging --confirm t2api-staging '#{restore_url}'"
    puts "obscuring project names..."
    sysputs "heroku run rake obscure_projects -a t2api-staging"
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
  task :refresh_from_production => [ :drop, :create, :pull_prod, :seed ]

  desc "Links people records to users via matching emails"
  task :link_people_to_users => :environment do
    Person.find_each do |person|
      person.send(:create_or_associate_user)
      if person.save
        p "Linked #{person.name} to user record."
      end
    end
  end

  desc "Eliminates duplicate User and Person records"
  task :clean_users_and_people => :environment do
    puts "Cleaning Users and Person records that do not have an email"
    User.delete_all(email: '')
    User.delete_all(email: nil)
    Person.delete_all!(email: '')
    Person.delete_all!(email: nil)

    puts "Cleaning User duplicates..."
    all_email = User.all.map(&:email)
    dup_emails = all_email.select{|e| all_email.count(e) > 1}.sort
    suspicious_users = User.where(email: dup_emails)
    puts "#{dup_emails.size} duplicates detected:"
    dup_emails.each{|e| puts e}
    people = Person.with_deleted.where(email: dup_emails).all
    good_user_ids = people.map(&:user_id)
    users_to_delete = suspicious_users.reject{|u| good_user_ids.include?(u.id)}
    users_to_delete.each {|u| u.destroy }

    puts "\n"
    puts "Cleaning Person duplicates..."
    all_email = Person.with_deleted.all.map(&:email)
    dup_emails = all_email.select{|e| all_email.count(e) > 1}.sort
    suspicious_people = Person.only_deleted.where(email: dup_emails)
    puts "#{dup_emails.size} duplicates detected:"
    dup_emails.each{|e| puts e}
    people_to_delete = suspicious_people.reject{|p| User.where(id: p.user_id).size > 0}
    puts "\n"
    people_to_delete.each{|p| p.destroy!}

    puts "\n"
    puts "Fixing people that need to be relinked to users..."
    Person.where(user_id: nil).find_each do |person|
      person.send(:create_or_associate_user)
      if person.save
        p "Linked #{person.name} to user record."
      end
    end
    
  end
end
