desc 'Declare Company Holidays'
task :declare_holidays => :environment do

  all_offices = Office.all

  HOLIDAYS_2015 = {
    'New Years Day'    => ['2015-01-01'],
    'Memorial Day'     => ['2015-05-25'],
    'Independence Day' => ['2015-07-03'],
    'Labor Day'        => ['2015-09-07'],
    'Thanksgiving'     => ['2015-11-26', '2015-11-27'],
    'Christmas Eve'    => ['2015-12-24'],
    'Christmas'        => ['2015-12-25'],
  }

  HOLIDAYS_2015.each do |holiday_name, dates|
    Holiday.declare(holiday_name, all_offices, *dates)
  end

end
