require "test_helper"

class ContractTest < ActiveSupport::TestCase
  test "should have start_date filled" do
    contract = Contract.new(start_date: nil, end_date: Time.zone.now, salary: 300)

    assert_not contract.save, "contract is not supposed to be saved"
    assert_equal [ "can't be blank" ], contract.errors.messages[:start_date], "start_date field must be specified"
  end

  test "should have start_end filled" do
    contract = Contract.new(start_date: Time.zone.now - 1.month, end_date: nil, salary: 300)

    assert_not contract.save, "contract is not supposed to be saved"
    assert_equal [ "can't be blank" ], contract.errors.messages[:end_date], "end_date field must be specified"
  end

  test "should have salary filled" do
    contract = Contract.new(start_date: Time.zone.now - 1.month, end_date: Time.zone.now, salary: nil)

    assert_not contract.save, "contract is not supposed to be saved"
    assert_equal [ "can't be blank", "is not a number" ], contract.errors.messages[:salary], "salary field must be specified"
  end

  test "should start_end cannot be greater than end_date" do
    contract = Contract.new(start_date: Time.zone.now, end_date: Time.zone.now - 1.day, salary: 300)

    assert_not contract.save, "contract is not supposed to be saved"
    assert_equal [ "start_date cannot be greater than or equal to end_date" ], contract.errors.messages[:end_date], "start_date cannot be greater than end_date"
  end

  test "should start_end cannot be equal to end_date" do
    contract = Contract.new(start_date: Time.zone.now, end_date: Time.zone.now, salary: 300)

    assert_not contract.save, "contract is not supposed to be saved"
    assert_equal [ "start_date cannot be greater than or equal to end_date" ], contract.errors.messages[:end_date], "start_date cannot be equal to end_date"
  end
end
