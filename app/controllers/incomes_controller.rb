# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomesController < ApplicationController
  before_filter :set_income, only: [:approve, :null]

  # GET /incomes
  def index
    set_index_params
    search_incomes
  end

  # GET /incomes/1
  # GET /incomes/1.xml
  def show
    @income = present Income.find(params[:id])
  end

  # GET /incomes/new
  def new
    @is = Incomes::Form.new_income
  end

  # GET /incomes/1/edit
  def edit
    @is = Incomes::Form.find(params[:id])
  end

  # POST /incomes
  def create
    @is = Incomes::Form.new_income(income_params)

    if create_or_approve
      redirect_to @is.income, notice: 'Se ha creado un Ingreso.'
    else
      render 'new'
    end
  end

  # PUT /incomes/:id
  def update
    @is = Incomes::Form.find(params[:id])

    if update_or_approve
      redirect_to @is.income, notice: 'El Ingreso fue actualizado!.'
    else
      render 'edit'
    end
  end

  # POST /incomes/quick_income
  def quick_income
    @quick_income = Incomes::QuickForm.new(quick_income_params)

    if @quick_income.create
      flash[:notice] = "El ingreso fue creado."
    else
      flash[:error] = "Existio errores al crear el ingreso."
    end

    redirect_to incomes_path
  end

  # DELETE /incomes/:id
  def destroy
    if @income.approved?
      flash[:warning] = "No es posible anular la nota #{@transaction}."
      redirect_transaction
    else
      @transaction.null_transaction
      flash[:notice] = "Se ha anulado la nota #{@transaction}."
      redirect_to @transaction
    end
  end

  # PUT /incomes/:id/approve
  # Method to approve an income
  def approve
    redirect_to(@income, alert: 'El Ingreso ya esta aprovado') and return unless @income.is_draft?

    @income.approve!
    if @income.save
      flash[:notice] = "El Ingreso fue aprobado."
    else
      flash[:error] = "Existio un problema con la aprobación."
    end

    redirect_to income_path(@income)
  end

  # PUT /incomes/:id/null
  def null
    if @income.null!
      redirect_to income_path(@income), notice: 'Se anulo correctamente el ingreso.'
    else
      redirect_to income_path(@income), error: 'Existio un error al anular el ingreso.'
    end
  end

private
  # Creates or approves a ExpenseService instance
  def create_or_approve
    if params[:commit_approve]
      @is.create_and_approve 
    else
      @is.create
    end
  end

  def update_or_approve
    if params[:commit_approve]
      @is.update_and_approve(income_params)
    else
      @is.update(income_params)
    end
  end

  def quick_income_params
   params.require(:incomes_quick_form).permit(*transaction_params.quick_income)
  end

  def income_params
    params.require(:incomes_form).permit(*transaction_params.income)
  end

  def transaction_params
    @transaction_params ||= TransactionParams.new
  end

  def set_income
    @income = Income.find_by_id(params[:id])
  end

  # Method to search incomes on the index
  def search_incomes
    @incomes = case
               when params[:contact_id].present?
                 Income.contact(params[:contact_id]).order('date desc').page(@page)
               when params[:search].present?
                 Incomes::Query.new.search(params[:search])
               else
                 Income.order('date desc').page(@page)
               end
    @incomes = @incomes.includes(:contact, transaction: [:creator, :approver, :nuller]).order('date desc, accounts.id desc')

    set_incomes_filters
  end

  def set_incomes_filters
    case
    when params[:approved].present?
      @incomes = @incomes.approved
    when params[:error].present?
      @incomes = @incomes.error
    when params[:due].present?
      @incomes = @incomes.due
    when params[:nulled].present?
      @incomes = @incomes.nulled
    end
  end

  def set_index_params
    params[:all] = true unless params[:approved] || params[:error] || params[:nulled] || params[:due]
  end
end
