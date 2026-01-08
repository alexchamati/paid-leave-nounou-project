require "test_helper"

class UserFlowTest < ActionDispatch::IntegrationTest
  test "hould get some tabs for the contract simulation" do
    # what is doing
    assert_difference("Contract.count", 1) do
      post contracts_url, params: {
        contract: {
          start_date: Time.zone.parse("24/04/2023"),
          end_date: Time.zone.parse("08/08/2025"),
          salary: CONTRACT_CONFIG[:salary][:min]
        }
      }
    end

    last_contract = Contract.last
    assert_equal last_contract.start_date, Time.zone.parse("24/04/2023"), "after create, should have same start_date value"
    assert_equal last_contract.end_date, Time.zone.parse("08/08/2025"), "after create, should have same end_date value"
    assert_equal last_contract.salary, CONTRACT_CONFIG[:salary][:min], "after create, should have same salary value"

    # orchestration
    assert_response :redirect
    assert_redirected_to new_contract_url

    # observable result, html
    follow_redirect!
    assert_equal "new", @controller.action_name
  end
end
