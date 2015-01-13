namespace :staging do
  desc 'change production urls for navigation to be staging friendly'
  task :stagify_urls => :environment do
    T2Application.all.each do |app|
      if !app.url.match('-staging')
        app.url = app.url.gsub('.neo.com','-staging.neo.com')
        app.save
      end
    end
  end
end
