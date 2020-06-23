class CsvController < ApplicationController
  include UserActivityHelper
  access provider: :all, user: :all
  before_action :validate_daily_generation, only:[:generate_provider_report]

  def generate_provider_report
    ProviderImpressionsCsvWorker.perform_async( @project.slug, current_user.id)
    flash[:success] = I18n.t('dashboards.reports.report_created')
    redirect_to root_path
  end

  def generate_campaign_provider_report
    @board = params[:board]
    @campaign = params[:campaign]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    ProviderImpressionsCsvWorker.perform_async( @project.slug, current_user.id, @campaign, @board, @start_date, @end_date)
    flash[:success] = I18n.t('dashboards.reports.report_created')
    redirect_to root_path
  end

  def generate_campaign_report
    @campaign = params[:campaign]
    ProviderImpressionsCsvWorker.perform_async( @project.slug, current_user.id, @campaign)
    flash[:success] = I18n.t('dashboards.reports.report_created')
    redirect_to root_path
  end

  def generate_board_provider_report
    @board = params[:board]
    ProviderImpressionsCsvWorker.perform_async( @project.slug, current_user.id, nil, @board)
    flash[:success] = I18n.t('dashboards.reports.report_created')
    redirect_to root_path
  end

  def validate_daily_generation
    if @project.reports.where(created_at: 1.day.ago..Time.zone.now).present?
      flash[:error] = I18n.t('dashboards.reports.failed_to_generate_report')
      redirect_to root_path
    end
  end

  def download_csv
    if @project.reports.find_by_name(params[:reference]).present?
      send_file "tmp/#{params[:reference]}", type: 'text/csv'
    end
  end

end
