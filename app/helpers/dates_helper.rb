module DatesHelper
  def get_month_cycle(date: Time.zone.now.beginning_of_month)
    beginning = date.beginning_of_month
    @start_date = beginning - 1.month + 25.days
    @end_date = beginning + 25.days
  end
end
