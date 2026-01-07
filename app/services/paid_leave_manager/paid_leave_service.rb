class PaidLeaveManager::PaidLeaveService
  attr_accessor :contract, :paid_leave

  def initialize(contract)
    @contract = contract
    @paid_leave = {
      periods: nil,
      spreadings: nil
    }
  end

  def call
    @paid_leave[:periods] = PaidLeaveManager::PeriodsService.new(@contract).call
    @paid_leave[:spreadings] = PaidLeaveManager::SpreadingsService.new(@contract, @paid_leave[:periods]).call

    @paid_leave
  end
end
