namespace :utilization do
  desc "recalculate all future snapshots"
  task :recalculate => :environment do
    Snapshot.future.each do |s|
      s.recalculate!
    end
  end
end
