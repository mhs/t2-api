namespace :db do
  def sysputs(s)
    puts s
    system s
  end

  desc "Copy database instance from t2api.herokuapp.com to t2-staging.herokuapp.com"
  task :transfer_staging_db_from_prod do
    puts "creating backup of t2api..."
    sysputs "heroku pgbackups:capture -a t2api --expire"
    puts "creating backup of t2-staging..."
    sysputs "heroku pgbackups:capture -a t2-staging --expire"
    restore_url = `heroku pgbackups:url -a t2api`
    puts "resetting staging database"
    sysputs "heroku pg:reset HEROKU_POSTGRESQL_OLIVE_URL -a t2-staging --confirm"
    puts "copying data..."
    sysputs "heroku pgbackups:restore HEROKU_POSTGRESQL_OLIVE_URL -a t2-staging --confirm t2-staging '#{restore_url}'"
    # puts "obscuring project names..."
    # sysputs "heroku run rake obscure_projects -a t2-staging"
  end


  desc "Copy database from production to localhost"
  task :pull_prod do
    system "heroku pg:pull HEROKU_POSTGRESQL_VIOLET_URL t2api -a t2api"
  end

  desc "Copy database from staging to localhost"
  task :pull_staging do
    system "heroku pg:pull HEROKU_POSTGRESQL_OLIVE_URL t2api -a t2-staging"
  end

  desc "Complete reset of local database from staging"
  task :refresh => [ :drop, :pull_staging, :seed ]

  desc "Complete reset of local database from production"
  task :refresh_from_production => [ :drop, :pull_prod, :seed ]

  if Rails.env == 'development'
    desc "Populate database with sample data"
    task :load_sample_data => [ :reset ] do
      require "#{Rails.root}/db/sample_data"
      SampleData.load
    end
  end

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

  desc "Remove duplicate snapshots"
  task :remove_duplicate_snapshots => :environment do
    puts "Removing duplicate snapshots"
    all_snaps = Snapshot.order('updated_at DESC').all
    latest_snaps = all_snaps.each_with_object({}) do |snap, list|
      key = [snap.snap_date, snap.office_id]
      list[key] ||= snap
    end
    snaps_to_delete = all_snaps - latest_snaps.values
    snaps_to_delete.each(&:destroy)
  end

  desc "Restore deleted people attached to snapshots"
  task :restore_deleted_from_snapshots => :environment do
    puts "Restoring deleted people attached to snapshots"
    Person.transaction do
      bad_ids = Snapshot.all.map { |s| s.attributes.slice(*Snapshot.serialized_attributes.keys).values.flatten.uniq }.flatten.sort.uniq - Person.pluck(:id)
      # there are three cases here:
      #
      # * people who no longer exist, even with deleted_at set. Remove them from the snapshots.
      # * people who are duplicates with different emails. Remove dupes from the snapshots.
      # * people who left the company and were deleted. Restore them.
      #
      ids_to_clean = bad_ids - Person.unscoped.pluck(:id)
      ids_to_check = bad_ids - ids_to_clean
      people_to_check = Person.unscoped.find(ids_to_check)
      people_to_restore = []
      people_to_check.each do |person|
        if Person.where(name: [person.name, I18n.transliterate(person.name)]).any?
          puts "Duplicate deleted person #{person.name} (ID=#{person.id})"
          ids_to_clean << person.id
        else
          people_to_restore << person
        end
      end
      people_to_restore.each do |person|
        puts "Restoring #{person.name} (ID=#{person.id})"
        person.deleted_at = nil
        user = User.find_by_email(person.email)
        user ||= User.find_by_name(person.name)
        user ||= User.find_by_name(I18n.transliterate(person.name))
        user ||= User.find_or_create_by_email!(person.email) do |u|
          u.name = person.name
        end
        person.user = user
        person.save!
      end
      Snapshot.all.each do |snapshot|
        puts "Scrubbing snapshot for #{snapshot.snap_date} (ID=#{snapshot.id})"
        snapshot.serialized_attributes.keys.each do |attr|
          snapshot.send("#{attr}=", snapshot.send(attr) - ids_to_clean)
        end
        snapshot.save!
      end
    end
  end
end
