require "test_helper"

class CompanyControllerTest < ActionDispatch::IntegrationTest
  test "should post to lookup with valid CUI" do
    post company_lookup_path, params: { cui: "14837428" }
    assert_redirected_to company_show_path(cui: "14837428")
  end

  test "should redirect to root with blank CUI" do
    post company_lookup_path, params: { cui: "" }
    assert_redirected_to root_path
    assert_equal "CUI-ul este obligatoriu", flash[:error]
  end

  test "should redirect to root with invalid CUI format" do
    post company_lookup_path, params: { cui: "abc123" }
    assert_redirected_to root_path
    assert_equal "CUI-ul trebuie să conțină doar cifre", flash[:error]
  end

  test "should get show with valid CUI" do
    get company_show_path(cui: "14837428")
    assert_response :success
    assert_select "h1", text: "Informații Companie"
  end

  test "should get show with invalid CUI" do
    get company_show_path(cui: "99999999")
    assert_response :success
    assert_select "h3", text: "Nu s-au găsit informații"
  end
end
