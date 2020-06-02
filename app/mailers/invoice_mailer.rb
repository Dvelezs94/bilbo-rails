class InvoiceMailer < ApplicationMailer
  include MailerHelper

  def new_invoice(invoice:)
    @recipient_email = invoice.user.email
    @recipient_name  = invoice.user.name
    @subject  = t("provider_invoices.mailer.invoice_subject", campaign_name: invoice.campaign.name)
    @title    = @subject
    @greeting = @subject
    @link     = provider_invoices_url
    @link_text = t("provider_invoices.mailer.go_to_invoices")
    @message   = t("provider_invoices.mailer.invoice_message", campaign_name: invoice.campaign.name, project_name: invoice.campaign.project.name)

    generic_mail(subject=@subject, title=@title, greeting=@greeting, message=@message, receiver=@recipient_email, link=@link, link_text=@link_text)
  end
end
