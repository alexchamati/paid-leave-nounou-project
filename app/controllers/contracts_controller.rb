class ContractsController < ApplicationController
  def new
    @contract = Contract.new
    @last_contract = Contract.last
  end

  def create
    @contract = Contract.new(clean_params)
    if @contract.save
      redirect_to new_contract_path, notice: "Contract Loaded"
    else
      @last_contract = Contract.last
      render :new, status: :unprocessable_entity
    end
  end

  private

  def clean_params
    params.require(:contract).permit(:start_date, :end_date, :salary)
  end
end
