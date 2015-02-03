desc "Give detailed monthly utilization stats for Shelley"
task :shelley_report => :environment do
  class Fixnum
    def round_to(x)
      (self * 10**x).round.to_f / 10**x
    end
  end
  class Float
    def round_to(x)
      (self * 10**x).round.to_f / 10**x
    end
  end

  this_month = Date.today.month
  prior_month = this_month == 1 ? 12 : (this_month - 1).to_s
  this_year = Date.today.year
  prior_month_year = this_month == 1 ? (this_year - 1).to_s : this_year.to_s

  start_of_period = "#{prior_month_year}-#{prior_month}-1"
  end_of_period = "#{this_year}-#{this_month}-1"

  puts "Monthy Per Office Utilization Detail between #{start_of_period} and #{end_of_period}"
  ['Columbus','New York','San Francisco','Singapore'].each do |office_name|
    office = Office.find_by name: office_name
    snapshots = Snapshot.where(office_id: office.id)
      .where("snap_date >= '#{start_of_period}'")
      .where("snap_date < '#{end_of_period}'")
      .where(includes_speculative: false)
      .reject{|s| [0,6].include?(s.snap_date.wday)}

    billable = snapshots.map(&:billable).map(&:total).map{|t| t/100}.sum
    billing = snapshots.map(&:billing).map(&:total).map{|t| t/100}.sum
    util = 100.0 * (billing / billable)
    puts "#{office_name}:  #{billing.round_to(2)} / #{billable.round_to(2)} = #{util.round_to(2)}"
  end
end
