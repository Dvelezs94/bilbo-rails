class CsvController < ApplicationController
  include UserActivityHelper
  access provider: :all
  #before_action :validate_daily_generation

  def generate_provider_report
    ProviderImpressionsCsvWorker.perform_async(@project.slug, current_user.id)
    flash[:success] = I18n.t('dashboards.reports.report_created')
    redirect_to root_path
  end

  def validate_daily_generation
    if @project.reports.where(created_at: 2.day.ago..Time.now).present?
      flash[:error] = I18n.t('dashboards.reports.failed_to_generate_report')
      redirect_to root_path
    end
  end

  def download_csv
    send_file "public/csv/#{Project.first.reports.last.name}", type: 'image/jpeg'
  end

end
