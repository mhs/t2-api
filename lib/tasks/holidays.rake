desc 'Clean up 2014 holidays with full winter break'
task :winter_break_2014 => :environment do
  xmas_eve = Holiday.find_by start_date: '2014-12-24'
  xmas = Holiday.find_by start_date: '2014-12-25'
  ny_eve = Holiday.find_by start_date: '2014-12-31'
  ny_day = Holiday.find_by start_date: '2015-1-1'

  xmas_eve.destroy
  xmas.destroy
  ny_eve.destroy
  ny_day.destroy

  singapore = Office.find_by name: 'Singapore'
  columbus = Office.find_by name: 'Columbus'
  nyc = Office.find_by name: 'New York'
  sanfran = Office.find_by name: 'San Francisco'
  hq = Office.find_by name: 'Headquarters'

  Holiday.declare 'US Shutdown', [columbus, nyc, sanfran, hq], '2014-12-20', '2015-1-4'
  Holiday.declare 'Singapore Shutdown', [singapore], '2014-12-25', '2015-1-4'
end

desc 'Declare Company Holidays'
task :declare_holidays => :environment do
  singapore = Office.find_by name: 'Singapore'
  columbus = Office.find_by name: 'Columbus'
  nyc = Office.find_by name: 'New York'
  sanfran = Office.find_by name: 'San Francisco'
  hq = Office.find_by name: 'Headquarters'

  #Note that only holidays for US and Singapore have been provided thus far

  us_offices = [columbus, nyc, sanfran, hq]
  all_offices = [columbus, nyc, sanfran, hq]

  Holiday.declare 'New Years Day', all_offices, '2014-1-1'
  Holiday.declare 'Christmas', all_offices, '2014-12-25'

  #Memorial Day done manually via console before this script existed
  Holiday.declare 'Independence Day', us_offices, '2014-7-4'
  Holiday.declare 'Labor Day', us_offices, '2014-9-1'
  Holiday.declare 'Thanksgiving', us_offices, '2014-11-27', '2014-11-28'
  Holiday.declare 'Christmas Eve', us_offices, '2014-12-24'
  Holiday.declare 'New Years Eve', us_offices, '2014-12-31'

  singers = [singapore]
  Holiday.declare 'Chinese New Year', singers, '2014-1-31', '2014-2-3'
  Holiday.declare 'Good Friday', singers, '2014-4-18'
  Holiday.declare 'Labour Day', singers, '2014-5-1'
  Holiday.declare 'Vesak Day', singers, '2014-5-13'
  Holiday.declare 'Hari Raya Puasa (Eid al Fitr)', singers, '2014-7-28'
  Holiday.declare 'National Day', singers, '2014-8-9'
  Holiday.declare 'Hari Raya Haji', singers, '2014-10-5'
  Holiday.declare 'Deepavali', singers, '2014-10-22'


  Holiday.declare 'New Years Day', all_offices, '2015-1-1'
  Holiday.declare 'Christmas', all_offices, '2015-12-25'

  Holiday.declare 'Memorial Day', us_offices, '2015-5-25'
  Holiday.declare 'Independence Day', us_offices, '2015-7-3'
  Holiday.declare 'Labor Day', us_offices, '2015-9-7'
  Holiday.declare 'Thanksgiving', us_offices, '2015-11-26', '2015-11-27'
  Holiday.declare 'Christmas Eve', us_offices, '2015-12-24'
  Holiday.declare 'New Years Eve', us_offices, '2015-12-31'

  singers = [singapore]
  Holiday.declare 'Chinese New Year', singers, '2015-2-19', '2015-2-20'
  Holiday.declare 'Good Friday', singers, '2015-4-3'
  Holiday.declare 'Labour Day', singers, '2015-5-1'
  Holiday.declare 'Vesak Day', singers, '2015-6-1'
  Holiday.declare 'Hari Raya Puasa (Eid al Fitr)', singers, '2015-7-17'
  Holiday.declare 'National Day', singers, '2015-8-9'
  Holiday.declare 'Hari Raya Haji', singers, '2015-9-24'
  Holiday.declare 'Deepavali', singers, '2015-11-10'
end
