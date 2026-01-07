class PaidLeaveManager::SpreadingsServiceTest < ActiveSupport::TestCase
  setup do
    @contract = contracts.first
    raise "fixture contracts is empty" if @contract.nil?

    @periods = PaidLeaveManager::PeriodsService.new(@contract).call
    @paid_lead_spreadings_service = PaidLeaveManager::SpreadingsService.new(@contract, @periods)
    @spreadings = @paid_lead_spreadings_service.set_number_work_day_of_month_date
  end

  test "should have valid numbers of number work day of month date" do
    assert_equal 35, @spreadings.length, "number of spreadings is invalid"

    start_date = @contract.start_date.to_date
    end_date = @contract.end_date.to_date
    cursor_date = start_date.dup

    index = 0
    while cursor_date <= @contract.end_date
      if cursor_date == start_date || cursor_date == end_date
        number_work_day_of_month_date = cursor_date
      else
        # get number day in the month
        nb_days_month = Date.new(cursor_date.year, cursor_date.month, -1).day
        number_work_day_of_month_date = Date.new(cursor_date.year, cursor_date.month, nb_days_month)
      end

      assert_equal number_work_day_of_month_date, @spreadings[index][:number_work_day_of_month_date], "number_work_day_of_month_date is invalid at index #{index}"
      cursor_date = cursor_date.next_month
      index += 1
    end
  end

  test "should valid salary" do
    assert_equal 35, @spreadings.length, "number of spreadings is invalid"

    @spreadings = @paid_lead_spreadings_service.set_salary(@spreadings)

    @spreadings.each_with_index do |spreading, index|
      # get number day in the month
      nb_days_month = Date.new(spreading[:number_work_day_of_month_date].year, spreading[:number_work_day_of_month_date].month, -1).day

      if spreading[:number_work_day_of_month_date].day == nb_days_month
        salary = @contract.salary.to_f
      else
        salary = (nb_days_month - spreading[:number_work_day_of_month_date].day + 1) * @contract.salary.to_f / nb_days_month * 1.0
      end

      assert_equal salary, spreading[:salary], "salary is invalid at index #{index}"
    end
  end

  test "should valid paid leave full june" do
    assert_equal 35, @spreadings.length, "number of spreadings is invalid"

    @spreadings = @paid_lead_spreadings_service.set_salary(@spreadings)
    @spreadings = @paid_lead_spreadings_service.set_paid_leave_full_june(@spreadings)

    index = 0
    @spreadings.each_with_index do |spreading, index_spreading|
      break if index == @periods.length
      # set two new dates to compare spreading time and end_date contract without compare day
      end_contract_date = Date.new(@contract.end_date.year, @contract.end_date.month, 1)
      spreading_date = Date.new(spreading[:number_work_day_of_month_date].to_date.year, spreading[:number_work_day_of_month_date].to_date.month, 1)

      # if is june or the last month, we set lead paid at this month
      if spreading[:number_work_day_of_month_date].to_date.month.to_i == 6 || end_contract_date == spreading_date
        assert_equal @periods[index][:final_value], spreading[:paid_leave_full_june], "paid_leave_full_june is invalid at index #{index_spreading}"
        index += 1
      end
    end
  end
end
