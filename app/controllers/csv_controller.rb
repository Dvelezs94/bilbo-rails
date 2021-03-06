class CsvController < ApplicationController
  include UserActivityHelper
  access provider: :all, user: :all
  before_action :validate_daily_generation, only:[:generate_provider_report]
  before_action :validate_daily_hour_generation, only:[:generate_campaign_report, :generate_board_provider_report, :generate_campaign_provider_report]

  def generate_provider_report
    ProviderImpressionsCsvWorker.perform_async(current_project.slug, current_user.id)
    flash[:success] = I18n.t('dashboards.reports.report_created')
    redirect_to root_path
  end

  def generate_campaign_provider_report
    @board = params[:board]
    @campaign = params[:campaign]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    ProviderImpressionsCsvWorker.perform_async(current_project.slug, current_user.id, @campaign, @board, @start_date, @end_date)
    flash[:success] = I18n.t('dashboards.reports.report_created')
    redirect_to impressions_path
  end

  def generate_campaign_report
    @campaign = params[:campaign]
    ProviderImpressionsCsvWorker.perform_async(current_project.slug, current_user.id, @campaign)
    flash[:success] = I18n.t('dashboards.reports.report_created')
    redirect_to analytics_campaign_path(Campaign.find(@campaign_id).slug)
  end

  def generate_board_provider_report
    @board = params[:board]
    ProviderImpressionsCsvWorker.perform_async(current_project.slug, current_user.id, nil, @board)
    flash[:success] = I18n.t('dashboards.reports.report_created')
    redirect_to owned_boards_path
  end

  def validate_daily_generation
    if current_project.reports.where(created_at: 1.day.ago..Time.zone.now, category: "project").exists?
      flash[:error] = I18n.t('dashboards.reports.failed_to_generate_report')
      redirect_to root_path
    end
  end

  def validate_daily_hour_generation
    @board_id = params[:board]
    @campaign_id = params[:campaign]

    if @board_id.present?
      if @campaign_id.present?
        if current_project.reports.where(created_at: 1.hour.ago..Time.zone.now, category: "board_campaign", board_id: @board_id, campaign_id: @campaign_id).exists?
          flash[:error] = I18n.t('dashboards.reports.failed_to_generate_report_bilbo_one_hour')
          redirect_to impressions_path
        end
      else
        if current_project.reports.where(created_at: 1.hour.ago..Time.zone.now, category: "board", board_id: @board_id).exists?
          flash[:error] = I18n.t('dashboards.reports.failed_to_generate_report_bilbo_one_hour')
          redirect_to owned_boards_path
        end
      end

    elsif @campaign_id.present?
      if current_project.reports.where(created_at: 1.hour.ago..Time.zone.now, category: "campaign", campaign_id: @campaign_id).exists?
        flash[:error] = I18n.t('dashboards.reports.failed_to_generate_report_campaign_one_hour')
        redirect_to analytics_campaign_path(Campaign.find(@campaign_id).slug)
      end
    end
  end

  def download_csv
    report = current_project.reports.find_by_name(params[:reference])
    if report.present?
      attachment = ActiveStorage::Attachment.find(report.attachment.id).blob
      data = attachment.download
      send_data data,
      type: 'text/csv',
      filename: report.attachment.blob.filename.to_s
    end
  end

end
