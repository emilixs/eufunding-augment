# frozen_string_literal: true

class ApiLogsController < ApplicationController
  def index
    @api_logs = ApiLog.recent.limit(100)
    @total_requests = ApiLog.count
    @error_count = ApiLog.errors.count
    @success_count = ApiLog.successful.count
    @recent_errors = ApiLog.errors.recent.limit(10)
  end

  def show
    @api_log = ApiLog.find(params[:id])
  end

  def search
    @cui = params[:cui]
    if @cui.present?
      @api_logs = ApiLog.for_cui(@cui).recent.limit(50)
    else
      redirect_to api_logs_path, alert: "Please provide a CUI to search"
    end
  end

  def clear_old
    deleted_count = ApiLog.cleanup_old_logs(30)
    redirect_to api_logs_path, notice: "Deleted #{deleted_count} old log entries"
  end
end
