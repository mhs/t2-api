class ReportsController < ApplicationController

  before_filter :get_window

  def revenue
    revenue = Reports::Revenue.new(@start_date, @end_date)
    render_report(revenue)
  end

  def staff
    @staff = Reports::Staff.new(@start_date, @end_date)
    render_report(@staff)
  end


  private

  def get_window
    @start_date = Date.parse(params[:start_date]) if params[:start_date]
    @end_date = Date.parse(params[:end_date]) if params[:end_date]
  end

  def render_report(report)
    respond_to do |format|
      format.html
      format.csv do
        send_data(report.to_csv_string, :filename => report.filename)
      end
    end
  end

end
