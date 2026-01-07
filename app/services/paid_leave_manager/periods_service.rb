class PaidLeaveManager::PeriodsService
  attr_accessor :contract, :periods

  PERIOD_LINE_MODEL = {
    start_date_period: nil,
    end_date_period: nil,
    number_of_months_of_acquisition:  nil,
    number_of_days_acquired: nil,
    salary_maintenance_method: nil,
    ten_percent_method: nil,
    final_value: nil
  }.freeze
  MAINTENANCE_SALARY_DELTA = 22

  def initialize(contract)
    @contract = contract
    @periods = []
  end

  def call
    set_periods()
    set_numbers_of_months_of_acquisition()
    set_number_of_days_acquired()
    set_salary_maintenance_method()
    set_ten_percent_method()
    set_final_value()

    @periods
  end

  def set_final_value(periods = @periods)
    periods.each do |period|
      raise "salary_maintenance_method or ten_percent_method is invalid" if period[:salary_maintenance_method].blank? || period[:ten_percent_method].blank?
      period[:final_value] = [ period[:salary_maintenance_method], period[:ten_percent_method] ].max
    end

    periods
  end

  def set_ten_percent_method(periods = @periods)
    periods.each do |period|
      raise "number_of_months_of_acquisition is invalid" if period[:number_of_months_of_acquisition].blank?
      period[:ten_percent_method] = period[:number_of_months_of_acquisition] * @contract.salary.to_f * 0.1
    end

    periods
  end

  def set_salary_maintenance_method(periods = @periods)
    periods.each do |period|
      raise "number_of_months_of_acquisition is invalid" if period[:number_of_months_of_acquisition].blank?
      period[:salary_maintenance_method] = @contract.salary.to_f / MAINTENANCE_SALARY_DELTA * period[:number_of_days_acquired]
    end

    periods
  end

  def set_number_of_days_acquired(periods = @periods)
    periods.each do |period|
      raise "number_of_months_of_acquisition is invalid" if period[:number_of_months_of_acquisition].blank?
      period[:number_of_days_acquired] = period[:number_of_months_of_acquisition] * 2.5
    end

    periods
  end

  def set_numbers_of_months_of_acquisition(periods = @periods)
    periods.each do |period|
      raise "start_date period is invalid" if period[:start_date_period].blank?
      raise "end_date period is invalid" if period[:end_date_period].blank?
      nb_months = get_number_of_month_with_prorata(start_date: period[:start_date_period], end_date: period[:end_date_period])
      period[:number_of_months_of_acquisition] = nb_months
    end

    periods
  end

  def get_number_of_month_with_prorata(start_date: nil, end_date: nil)
    raise "dates are invalid" if start_date.blank? || end_date.blank?
    raise "start_date is greather than end_date" if start_date > end_date

    total_month = 0.0

    # set cursor to the first day of the month of the start date to begin the iteration
    cursor_date = Date.new(start_date.year, start_date.month, 1)

    # As long as the month of the cursor is earlier than or equal to the month of the end date
    # (We compare year * 12 + month to handle changes in the year)
    while (cursor_date.year * 12 + cursor_date.month) <= (end_date.year * 12 + end_date.month)

      # set the limits for the month
      debut_mois_calendaire = cursor_date
      # get number day in the month
      last_day_month_date = Date.new(cursor_date.year, cursor_date.month, -1)
      nb_days_month = last_day_month_date.day

      # set start and end period in this month
      ## set last limit between start_date of contract and start of the month
      start_period_month = [ start_date, debut_mois_calendaire ].max
      ## set the earliest limit between end_date of contracr and end of the month
      end_period_month = [ end_date, last_day_month_date ].min

      # set number of days with prorata
      if start_period_month <= end_period_month
        nb_days = (end_period_month - start_period_month).to_i + 1

        prorata = nb_days.to_f / nb_days_month
        total_month += prorata
      end

        cursor_date = cursor_date + 1.month
    end

    total_month
  end

  def set_periods(periods = @periods)
    start_date = @contract.start_date
    end_date = @contract.end_date

    raise "dates are invalid" if start_date.blank? || end_date.blank?
    raise "start_date is greather than end_date" if start_date > end_date

    cursor_date = start_date.dup

    while cursor_date <= end_date
      # initialize period with the period model
      period = PERIOD_LINE_MODEL.dup

      # determine the end of the current reference year

      ## if it is June or later (>= 6), the end of the period is May 31 of the following year
      ## else the end of the period is May 31 of the current year
      end_of_cycle_year = cursor_date.month >= 6 ? cursor_date.year + 1 : cursor_date.year
      end_cycle_ref = Date.new(end_of_cycle_year, 5, 31)

      # the effective end of this segment is either the end of the cycle (May 31)

      ## or the overall end date if it occurs earlier
      end_segment = [ end_cycle_ref, end_date ].min

      # push in datas
      period[:start_date_period] = cursor_date
      period[:end_date_period] = end_segment
      periods.push(period)

      # move the cursor forward to the day after the end of the segment
      cursor_date = end_segment + 1
    end

    periods
  end
end
