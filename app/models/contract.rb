class Contract < ApplicationRecord
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :salary, presence: true, numericality: {
    greater_than_or_equal_to: CONTRACT_CONFIG[:salary][:min],
    less_than_or_equal_to: CONTRACT_CONFIG[:salary][:max]
  }

  validate :end_date_after_start_date_validation

  after_commit :load_paid_leave_datas

  def paid_leave_datas
    Rails.cache.read("contract/#{id}/paid_leave/")
  end

  private

  def end_date_after_start_date_validation
    return if start_date.blank? || end_date.blank?

    errors.add(:end_date, message: "start_date cannot be greater than or equal to end_date") if start_date >= end_date
  end

  def load_paid_leave_datas
    Rails.cache.fetch("contract/#{id}/paid_leave/", expires_in: 1.hour) do
      ::PaidLeaveManager::PaidLeaveService.new(self).call
    end
  end
end
