namespace :utilization do
  desc "recalculate all future snapshots"
  task :recalculate => :environment do
    Snapshot.future.each do |s|
      s.recalculate!
    end
  end

  desc "recalculate all snapshots"
  task :recalculate_all => :environment do
    Snapshot.all.find_each(batch_size: 100) do |s|
      print "."
      s.recalculate!
    end
  end
end
