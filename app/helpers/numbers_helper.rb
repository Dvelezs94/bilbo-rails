module NumbersHelper
  # compares 2 values and returns the % of difference between them
  # example, it will give you
  def get_percentage(previous_value, current_value)
    h = current_value / previous_value
    h-=1
    (h * 100).round(1)
  end
end
