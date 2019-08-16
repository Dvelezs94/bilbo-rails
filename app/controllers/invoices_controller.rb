class InvoicesController < ApplicationController
  access user: :all
  before_action :get_invoices, on: [:index]

  def index
  end

  def new
  end

  def create
  end

  private

  def get_invoices
    @invoices = current_user.invoices.order(created_at: :desc)
  end

  def get_invoice
    @invoice = Invoice.includes(:payment).friendly.find(params[:id])
  end

  def verify_identity
    redirect_to invoices_path if @invoice.user != current_user
  end
end
