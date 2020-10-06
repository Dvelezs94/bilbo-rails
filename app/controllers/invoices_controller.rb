class InvoicesController < ApplicationController
  access user: :all, admin: :all
  before_action :get_invoices, only: [:index]
  before_action :get_invoice, only: [:show]
  before_action :verify_identity, only: [:show]

  def index
  end

  def new
  end

  def show

  end

  def create
  end

  private

  def get_invoices
    @invoices = current_user.invoices.order(created_at: :desc)
  end

  def get_invoice
    @invoice = Invoice.includes(:payment).find(params[:id])
  end

  def verify_identity
    if current_user.is_user?
      redirect_to invoices_path if @invoice.user != current_user
    end
  end
end
