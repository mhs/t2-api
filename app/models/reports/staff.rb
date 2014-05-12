require 'csv'

class OfficeCounts
  attr_accessor :office, :start_date, :end_date,
    :hired_billable, :left_billable, :fired_billable, :total_billable,
    :hired_unbillable, :left_unbillable, :fired_unbillable, :total_unbillable,
    :billable_change, :unbillable_change

  def initialize(office, start_date, end_date)
    @office, @start_date, @end_date = office, start_date, end_date
    @hired_billable = @left_billable = @fired_billable = @total_billable =
      @hired_unbillable = @left_unbillable = @fired_unbillable = @total_unbillable =
      @billable_change = @unbillable_change = 0
  end

  def consider_person(person)
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

  def column_values
    [ @office.name,
      @hired_billable, @left_billable, @fired_billable, @total_billable, @billable_change,
      @hired_unbillable, @left_unbillable, @fired_unbillable, @total_unbillable, @unbillable_change,
      @total_billable+@total_unbillable, @billable_change+@unbillable_change]
  end
end

class Reports::Staff < Reports::Base

  attr_reader :start_date, :end_date, :counts

  def initialize(start_date, end_date)
    @start_date = start_date || Date.today.beginning_of_month
    @end_date = end_date || Date.today
    @counts = Office.all.collect { |office| office_staff_report(office, @start_date, @end_date) }
  end

  def self.column_names
    [
      "Office",
      "New Billable",
      "Lost Billable - Voluntary",
      "Lost Billable - Involuntary",
      "Total Billable",
      "Billable Change",
      "New Non-Billable",
      "Lost Non-Billable - Voluntary",
      "Lost Non-Billable - Involuntary",
      "Total Non-Billable",
      "Non-Billable Change",
      "Total Employees",
      "Total Change"
    ]
  end

  def filename
    "staffing_delta_#{start_date}-#{end_date}.csv"
  end

  def rows
    @counts
  end

  def to_csv_string
    CSV.generate do |csv|
      csv << self.class.column_names
      rows.each do |count|
        csv << csv_line(count.column_values)
      end
    end
  end


  private

  def office_staff_report office, start_date, end_date
    counts = OfficeCounts.new(office, start_date, end_date)
    office.people.each {|person| counts.consider_person person}
    counts
  end

end
