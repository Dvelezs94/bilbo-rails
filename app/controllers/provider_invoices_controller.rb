class ProviderInvoicesController < ApplicationController
  access user: :all
  before_action :get_provider_invoices, only: [:index]
  before_action :get_provider_invoice, only: [:show]
  before_action :verify_identity, only: [:show]

  def index
  end

  def new
  end

  def show
  end

  def create
    @new_invoice = ProviderInvoice.new(invoice_params)
    if @new_invoice.save
      @success_message = I18n.t("provider_invoices.invoice_created")
      InvoiceMailer.new_invoice(invoice: @new_invoice).deliver
    else
      @error_message = I18n.t("provider_invoices.invoice_error")
    end
  end

  private

  def invoice_params
    @invoice_params = params.require(:provider_invoice).permit(:comments, :uuid, documents: [])
    @invoice_params[:campaign] = Campaign.find(params[:campaign_id])
    @invoice_params[:user_id] = @invoice_params[:campaign].project.owner.id
    @invoice_params[:issuing_id] = current_project.id
    @invoice_params
  end

  def get_provider_invoices
    @provider_invoices = current_user.provider_invoices.order(id: :desc)
  end

  def get_invoice
    @provider_invoice = ProviderInvoice.includes(:payment).find(params[:id])
  end

  def verify_identity
    redirect_to provider_invoices_path if @provider_invoice.user != current_user
  end
end
