class PaidLeaveManager::SpreadingsService
  attr_accessor :contract, :periods, :spreadings

  SPREADINGS_LINE_MODEL = {
    number_work_day_of_month_date: nil,
    salary: nil,
    paid_leave_full_june: nil,
    paid_leave_twelfth: nil,
    paid_leave_10_percent_monthly: nil,
    paid_leave_10_percent_regularization: nil,
    paid_leave_10_percent_total: nil,
  }.freeze

  def initialize(contract, periods)
    @contract = contract
    @periods = periods
    @spreadings = []
  end

  def call
    set_number_work_day_of_month_date()
    set_salary()
    set_paid_leave_full_june()

    @spreadings
  end

  def set_paid_leave_full_june(spreadings = @spreadings)
    index = 0
    spreadings.each do |spreading|
      break if index == @periods.length
      # set two new dates to compare spreading time and end_date contract without compare day
      end_contract_date = Date.new(@contract.end_date.year, @contract.end_date.month, 1)
      spreading_date = Date.new(spreading[:number_work_day_of_month_date].to_date.year, spreading[:number_work_day_of_month_date].to_date.month, 1)

      # if is june or the last month, we set lead paid at this month
      if spreading[:number_work_day_of_month_date].to_date.month.to_i == 6 || end_contract_date == spreading_date
        spreading[:paid_leave_full_june] = @periods[index][:final_value]
        index += 1
      end
    end

    spreadings
  end

  def set_salary(spreadings = @spreadings)
    spreadings.each do |spreading|
      raise "number_work_day_of_month_date is invalid" if spreading[:number_work_day_of_month_date].blank?

      # get number day in the month
      nb_days_month = Date.new(spreading[:number_work_day_of_month_date].year, spreading[:number_work_day_of_month_date].month, -1).day

      if spreading[:number_work_day_of_month_date].day == nb_days_month
        spreading[:salary] = @contract.salary.to_f
      else
        spreading[:salary] = (nb_days_month - spreading[:number_work_day_of_month_date].day + 1) * @contract.salary.to_f / nb_days_month * 1.0
      end
    end

    spreadings
  end

  def set_number_work_day_of_month_date(spreadings = @spreadings)
    start_date = @contract.start_date
    end_date = @contract.end_date

    raise "dates are invalid" if start_date.blank? || end_date.blank?
    raise "start_date is greather than end_date" if start_date > end_date

    cursor_date = start_date.dup

    while cursor_date <= end_date
      spreading = SPREADINGS_LINE_MODEL.dup

      # if it's the start or the end date of contract, get the day to have de number of work in this month
      # else get all day in the month, is a complete month work
      if cursor_date == start_date || cursor_date == end_date
        spreading[:number_work_day_of_month_date] = cursor_date
      else
        # get number day in the month
        nb_days_month = Date.new(cursor_date.year, cursor_date.month, -1).day

        spreading[:number_work_day_of_month_date] = Date.new(cursor_date.year, cursor_date.month, nb_days_month)
      end

      spreadings.push(spreading)
      cursor_date = cursor_date.next_month
    end

    spreadings
  end
end
