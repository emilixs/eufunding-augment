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

    begin
      @company_data = CompanyService.fetch_company_info(@cui)

      if @company_data.nil?
        flash.now[:error] = "Nu s-au găsit informații pentru CUI-ul #{@cui}"
      end
    rescue StandardError => e
      Rails.logger.error "Error fetching company data for CUI #{@cui}: #{e.message}"
      flash.now[:error] = "A apărut o eroare la căutarea companiei. Vă rugăm să încercați din nou."
      @company_data = nil
    end
  end
end
