# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DevolutionsController < ApplicationController
  before_filter :check_income_or_expense

  # POST /devolutions/:id/income
  def income
    p = Incomes::Devolution.new(income_params)

    if p.pay_back
      flash[:notice] = 'La devolución realizo correctamente.'
    else
      flash[:error] = 'Exisitio un error al salvar la devolucion.'
    end

    redirect_to income_path(p.income, anchor: 'payments')
  end

  # POST /devolutions/:id/expense
  def expense
    p = Expenses::Devolution.new(expense_params)

    if p.pay_back
      flash[:notice] = 'La devolución se realizo correctamente.'
    else
      flash[:error] = 'Existió un error al salvar la devolución.'
    end

    redirect_to expense_path(p.expense, anchor: 'payments')
  end

private
  def income_params
    params.require(:incomes_devolution).permit(*allowed_params)
  end

  def expense_params
    params.require(:expenses_devolution).permit(*allowed_params)
  end

  def allowed_params
    [:account_id, :account_to_id, :exchange_rate, :amount, :reference, :verification, :date]
  end

  def check_income_or_expense
    if params.fetch(:action) == 'income'
      check_income
    else
      check_expense
    end
  end

  def check_income
    if Income.where(id: params[:id]).empty?
      flash[:error] = 'No se puede realizar el cobro, el ingreso no existe.'
      redirect_to :back and return
    end
  end

  def check_expense
    if Expense.where(id: params[:id]).empty?
      flash[:error] = 'No se puede realizar el pago, el egreso no existe.'
      redirect_to :back and return
    end
  end
end

