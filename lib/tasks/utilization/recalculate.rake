namespace :utilization do
  desc "recalculate future snapshots"
  task :recalculate => :environment do
    Snapshot.where('snap_date >= ?', Time.now).find_each do |snap|
      snap.recalculate!
    end
  end
end
