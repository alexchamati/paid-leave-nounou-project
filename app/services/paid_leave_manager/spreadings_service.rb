class PaidLeaveManager::SpreadingsService
  attr_accessor :contract, :periods, :spreadings

  SPREADINGS_LINE_MODEL = {
    number_work_day_of_month_date: nil,
    salary: nil,
    paid_leave_full_june: nil,
    paid_leave_twelfth: nil,
    paid_leave_10_percent_monthly: nil,
    paid_leave_10_percent_regularization: nil,
    paid_leave_10_percent_total: nil
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
    set_paid_leave_twelfth()
    set_paid_leave_10_percent_monthly()
    set_paid_leave_10_percent_regularization()
    set_paid_leave_10_percent_total()

    @spreadings
  end

  def set_paid_leave_10_percent_total(spreadings = @spreadings)
    spreadings.each do |spreading|
      spreading[:paid_leave_10_percent_total] = (spreading[:paid_leave_10_percent_regularization] || 0.0) + (spreading[:paid_leave_10_percent_monthly] || 0.0)
    end

    spreadings
  end

  def set_paid_leave_10_percent_regularization(spreadings = @spreadings)
    @periods.each do |period|
      # we go through each month of the spreading
      # if it is part of the current period, we add the associated 10% amount
      total_paid_monthly = spreadings.select { |spreading| 
        number_work_day_of_month_date = spreading[:number_work_day_of_month_date]
        number_work_day_of_month_date >= period[:start_date_period] && number_work_day_of_month_date <= period[:end_date_period]
      }.sum { |number_work_day_of_month_date| number_work_day_of_month_date[:paid_leave_10_percent_monthly] }

      # we calculate the regularization_amount: the final_value - what we have already paid
      regularization_amount = period[:final_value] - total_paid_monthly

      # apply regularization if it's more than one cent
      if regularization_amount > 0.01

        # if we will begin a new cycle, regularization is paid next month
        # else during the end_date of the contract
        target_end_date = period[:end_date_period] == @contract.end_date ? period[:end_date_period] : period[:end_date_period] + 1.month

        # find spreading line to inject amount
        spreading = @spreadings.find do |spreading|
          number_work_day_of_month_date = spreading[:number_work_day_of_month_date]
          number_work_day_of_month_date.month == target_end_date.month && number_work_day_of_month_date.year == target_end_date.year
        end

        spreading[:paid_leave_10_percent_regularization] = regularization_amount if spreading
      end
    end

    spreadings
  end

  def set_paid_leave_10_percent_monthly(spreadings = @spreadings)
    spreadings.map do |spreading|
      raise "salary are invalid" if spreading[:salary].blank?

      spreading[:paid_leave_10_percent_monthly] = spreading[:salary] * 0.10
    end

    spreadings
  end

  def set_paid_leave_twelfth(spreadings = @spreadings)
    twelfth_value = 0.0
    # init count_month to count month number before the end_date of the contract
    # init last_paid_leave_full_june to keep the last amount before the last one
    ## count_month and last_paid_leave_full_june help to calculate the final twelfth_value
    count_month = 0
    last_paid_leave_full_june = nil
    spreadings.each_with_index do |spreading, index|
      # if it's a new cycle, we use paid_leave_full_june value to detect it
      # and get the current twelfth_value for the next cycle
      if spreading[:paid_leave_full_june] && spreading[:paid_leave_full_june] > 0
        twelfth_value = (spreading[:paid_leave_full_june] / 12.0)

        # set count_month and last_paid_leave_full_june before the end of contract
        if index < spreadings.length - 1
          count_month = 0
          last_paid_leave_full_june = spreading[:paid_leave_full_june]
        end
      end

      # set paid_leave_twelfth
      ## if it is the end of the contract, we accumulate the payment installments.
      ## else we simply set twelfth_value
      if index == spreadings.length - 1 && last_paid_leave_full_june && spreading[:paid_leave_full_june]
        spreading[:paid_leave_twelfth] = last_paid_leave_full_june - (last_paid_leave_full_june / 12 * count_month) + spreading[:paid_leave_full_june] # Simulation de solde
      else
        spreading[:paid_leave_twelfth] = twelfth_value > 0 ? twelfth_value : nil
        count_month += 1
      end
    end

    spreadings
  end

  def set_paid_leave_full_june(spreadings = @spreadings)
    index = 0
    spreadings.each do |spreading|
      raise "number_work_day_of_month_date are invalid" if spreading[:number_work_day_of_month_date].blank?

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
