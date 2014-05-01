require 'csv'

class OfficeCounts
  attr_accessor :office, :start_date, :end_date,
    :hired_billable, :left_billable, :fired_billable, :total_billable,
    :hired_unbillable, :left_unbillable, :fired_unbillable, :total_unbillable,
    :billable_change, :unbillable_change

  def initialize office, start_date, end_date
    @office, @start_date, @end_date = office, start_date, end_date
    @hired_billable = @left_billable = @fired_billable = @total_billable =
      @hired_unbillable = @left_unbillable = @fired_unbillable = @total_unbillable =
      @billable_change = @unbillable_change = 0
  end

  def considerPerson person
    person_start_date = person.start_date || (@start_date - 1.day)
    if person.percent_billable > 0
      if !person.end_date || (person.end_date && person.end_date >= @start_date)
        @total_billable += 1
      end
      if person_start_date >= @start_date && person_start_date <= @end_date
        @hired_billable += 1
        @billable_change += 1
      end
      if person.end_date
        if person.end_date >= @start_date && person.end_date <= @end_date
          @billable_change -= 1
          if person.voluntary_termination
            @left_billable += 1
          else
            @fired_billable += 1
          end
          @total_billable -= 1
        end
      end
    else
      if !person.end_date || (person.end_date && person.end_date >= @start_date)
        @total_unbillable += 1
      end
      if person_start_date >= @start_date && person_start_date <= @end_date
        @hired_unbillable += 1
        @unbillable_change += 1
      end
      if person.end_date
        if person.end_date >= @start_date && person.end_date <= @end_date
          @unbillable_change -= 1
          if person.voluntary_termination
            @left_unbillable += 1
          else
            @fired_unbillable += 1
          end
          @total_unbillable -= 1
        end
      end
    end
  end

  def self.column_names
    ["Office",
     "New Billable", "Lost Billable - Voluntary", "Lost Billable - Involuntary",
     "Total Billable", "Billable Change",
     "New Non-Billable", "Lost Non-Billable - Voluntary", "Lost Non-Billable - Involuntary",
     "Total Non-Billable", "Non-Billable Change",
     "Total Employees", "Total Change"]
  end

  def column_values
    [ @office.name,
      @hired_billable, @left_billable, @fired_billable, @total_billable, @billable_change,
      @hired_unbillable, @left_unbillable, @fired_unbillable, @total_unbillable, @unbillable_change,
      @total_billable+@total_unbillable, @billable_change+@unbillable_change]
  end
end


class ReportsController < ApplicationController

  def staff params={}
    now = Time.new
    @end_date = params[:end_date] || now
    @start_date = params[:start_date] || now.day.days.ago.beginning_of_month
    @counts = Office.all.collect { |office| office_staff_report(office,@start_date,@end_date) }
    respond_to do |format|
      format.html
      format.csv { send_data staff_csv }
    end
  end

  def staff_csv
    CSV.generate(col_sep: ", ") do |csv|
      csv << csv_line(["Staffing Delta Report",
                       @start_date.strftime("%m/%d/%Y"),@end_date.strftime("%m/%d/%Y")])
      csv << csv_line(OfficeCounts.column_names)
      @counts.each do |count|
        csv << csv_line(count.column_values)
      end
    end
  end

  def csv_line column_items
    column_items.map { |item| item.to_s }
  end

  def office_staff_report office, start_date, end_date
    counts = OfficeCounts.new office, start_date, end_date
    office.people.each {|person| counts.considerPerson person}
    counts
  end

end
