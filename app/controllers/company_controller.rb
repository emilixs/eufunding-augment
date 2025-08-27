class CompanyController < ApplicationController
  def lookup
    cui = params[:cui]&.strip

    if cui.blank?
      flash[:error] = "CUI-ul este obligatoriu"
      redirect_to root_path
      return
    end

    # Validate CUI format (should be numeric)
    unless cui.match?(/\A\d+\z/)
      flash[:error] = "CUI-ul trebuie să conțină doar cifre"
      redirect_to root_path
      return
    end

    redirect_to company_show_path(cui: cui)
  end

  def show
    @cui = params[:cui]

    Rails.logger.info "🏢 Company lookup request for CUI: #{@cui}"
    Rails.logger.info "🌐 Request from IP: #{request.remote_ip}"
    Rails.logger.info "🕐 Request time: #{Time.current}"

    begin
      start_time = Time.current
      @company_data = CompanyService.fetch_company_info(@cui)
      duration = Time.current - start_time

      Rails.logger.info "⏱️ Company lookup completed in #{duration.round(2)}s"

      if @company_data.nil?
        Rails.logger.warn "⚠️ No company data found for CUI: #{@cui}"
        flash.now[:error] = "Nu s-au găsit informații pentru CUI-ul #{@cui}"
      else
        Rails.logger.info "✅ Successfully retrieved company data for: #{@company_data[:company_name]}"
      end
    rescue StandardError => e
      Rails.logger.error "💥 Error in CompanyController#show for CUI #{@cui}:"
      Rails.logger.error "🔍 Error class: #{e.class}"
      Rails.logger.error "📝 Error message: #{e.message}"
      Rails.logger.error "📍 Backtrace: #{e.backtrace.first(10).join("\n")}"

      flash.now[:error] = "A apărut o eroare la căutarea companiei. Vă rugăm să încercați din nou."
      @company_data = nil
    end
  end
end
