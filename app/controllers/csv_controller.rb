class CsvController < ApplicationController
  access provider: :all
  before_action :validate_daily_generation

  def generate_provider_report
    ProviderImpressionsCsvWorker.perform_async(@project.slug)
    redirect_to root_path
  end

  def validate_daily_generation
    if @project.reports.where(created_at: 2.day.ago..Time.now).present?
      flash[:error] = I18n.t('dashboards.reports.failed_to_generate_report')
      redirect_to root_path
    else
      flash[:success] = I18n.t('dashboards.reports.report_created')
      generate_provider_report
    end
  end

end
