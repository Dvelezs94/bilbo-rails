class CsvController < ApplicationController
  access provider: :all
  before_action :validate_daily_generation

  def generate_provider_report
    ProviderImpressionsCsvWorker.perform_async(current_user.id)
    redirect_to root_path
  end

  def validate_daily_generation
    if current_user.reports.where(created_at: 1.day.ago..Time.now).present?
      flash[:error] = I18n.t('dashboards.reports.failed_to_generate_report')
    else
      flash[:success] = I18n.t('dashboards.reports.report_created')
    end
  end

end
