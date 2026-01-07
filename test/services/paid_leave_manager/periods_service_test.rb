require "test_helper.rb"

class PaidLeaveManager::PeriodsServiceTest < ActiveSupport::TestCase
  setup do
    @contract = contracts.first
    raise "fixture contracts is empty" if @contract.nil?

    @paid_lead_periods_service = PaidLeaveManager::PeriodsService.new(@contract)
    @periods = @paid_lead_periods_service.set_periods
  end

  test "Sould have valid periods" do
    # to do
    # assert_raises

    period_dates = [
      {
        start_date_period: Date.parse("2020-03-15"),
        end_date_period: Date.parse("2020-05-31")
      }, {
        start_date_period: Date.parse("2020-06-01"),
        end_date_period: Date.parse("2021-05-31")
      }, {
        start_date_period: Date.parse("2021-06-01"),
        end_date_period: Date.parse("2022-05-31")
      }, {
        start_date_period: Date.parse("2022-06-01"),
        end_date_period: Date.parse("2023-01-31")
      }
    ]

    assert_equal 4, @periods.length, "number of periods is invalid"

    period_dates.each_with_index do |period_date, index|
      assert_equal @periods[index][:start_date_period], period_date[:start_date_period], "start_date_period is invalid at index #{index}"
      assert_equal period_date[:end_date_period], @periods[index][:end_date_period], "end_date_period is invalid at index #{index}"
    end
  end

  test "should have valid numbers of months of acquisition" do
    # to do
    # assert_raises

    periods_number_of_months = [
      { number_of_months_of_acquisition: 2.5483870967741935 },
      { number_of_months_of_acquisition: 12.0 },
      { number_of_months_of_acquisition: 12.0 },
      { number_of_months_of_acquisition: 8.0 }
    ]

    @periods = @paid_lead_periods_service.set_numbers_of_months_of_acquisition(@periods)

    periods_number_of_months.each_with_index do |period_number_of_months, index|
      assert_equal period_number_of_months[:number_of_months_of_acquisition], @periods[index][:number_of_months_of_acquisition], "number_of_months_of_acquisition is invalid at index #{index}"
    end
  end

  test "should have valid number of days acquired" do
    # to do
    # assert_raises

    periods_number_of_days_acquired = [
      { number_of_days_acquired: 6.370967741935484 },
      { number_of_days_acquired: 30.0 },
      { number_of_days_acquired: 30.0 },
      { number_of_days_acquired: 20.0 }
    ]

    @periods = @paid_lead_periods_service.set_numbers_of_months_of_acquisition(@periods)
    @periods = @paid_lead_periods_service.set_number_of_days_acquired(@periods)

    periods_number_of_days_acquired.each_with_index do |period_number_of_days_acquired, index|
      assert_equal period_number_of_days_acquired[:number_of_days_acquired], @periods[index][:number_of_days_acquired], "number_of_days_acquired is invalid at index #{index}"
    end
  end

  test "should have valid salary maintenance method" do
    # to do
    # assert_raises

    periods_salary_maintenance_method = [
      { salary_maintenance_method: 146.532258064516138 },
      { salary_maintenance_method: 690.0 },
      { salary_maintenance_method: 690.0 },
      { salary_maintenance_method: 460.0 }
    ]

    @periods = @paid_lead_periods_service.set_numbers_of_months_of_acquisition(@periods)
    @periods = @paid_lead_periods_service.set_number_of_days_acquired(@periods)
    @periods = @paid_lead_periods_service.set_salary_maintenance_method(@periods)

    periods_salary_maintenance_method.each_with_index do |period_salary_maintenance_method, index|
      assert_equal period_salary_maintenance_method[:salary_maintenance_method], @periods[index][:salary_maintenance_method], "salary_maintenance_method is invalid at index #{index}"
    end
  end

  test "should have valid ten percent method" do
    # to do
    # assert_raises

    periods_ten_percent_method = [
      { ten_percent_method: 128.9483870967742 },
      { ten_percent_method: 607.2 },
      { ten_percent_method: 607.2 },
      { ten_percent_method: 404.8 }
    ]

    @periods = @paid_lead_periods_service.set_numbers_of_months_of_acquisition(@periods)
    @periods = @paid_lead_periods_service.set_number_of_days_acquired(@periods)
    @periods = @paid_lead_periods_service.set_salary_maintenance_method(@periods)
    @periods = @paid_lead_periods_service.set_ten_percent_method(@periods)

    periods_ten_percent_method.each_with_index do |period_ten_percent_method, index|
      assert_equal period_ten_percent_method[:ten_percent_method], @periods[index][:ten_percent_method], "ten_percent_method is invalid at index #{index}"
    end
  end

  test "should have valid final value" do
    # to do
    # assert_raises

    periods_final_value = [
      { final_value: 146.53225806451613 },
      { final_value: 690.0 },
      { final_value: 690.0 },
      { final_value: 460.0 }
    ]

    @periods = @paid_lead_periods_service.set_numbers_of_months_of_acquisition(@periods)
    @periods = @paid_lead_periods_service.set_number_of_days_acquired(@periods)
    @periods = @paid_lead_periods_service.set_salary_maintenance_method(@periods)
    @periods = @paid_lead_periods_service.set_ten_percent_method(@periods)
    @periods = @paid_lead_periods_service.set_final_value(@periods)

    periods_final_value.each_with_index do |period_final_value, index|
      assert_equal period_final_value[:final_value], @periods[index][:final_value], "final_value is invalid at index #{index}"
    end
  end
end
