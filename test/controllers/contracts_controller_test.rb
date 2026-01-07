require "test_helper"

class ContractsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    # what is doing
    get new_contract_url
    # orchestration
    assert_response :success
  end

  test "should not get create without values" do
    # what is doing
    assert_no_difference("Contract.count") do
      post contracts_url, params: { contract: {} }
    end

    # orchestration
    assert_response :bad_request

    # observable result, html
    assert_not_dom "section[id=content-section]"
  end

  test "should get create with values" do
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
    assert_dom "section[id=content-section]"
  end
end
