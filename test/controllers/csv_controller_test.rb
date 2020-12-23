class CsvControllerTest < ActionDispatch::IntegrationTest
    i_suck_and_my_tests_are_order_dependent!
    setup do
      @campaign_name = "Zoro"
      @user = create(:user, name: @campaign_name )
      @project =  create(:project, name: @campaign_name)
      @campaign = create(:campaign, name: @campaign_name,project: @user.projects.first, project_id: @project.id, state: true, provider_campaign: @user.is_provider?)
      @report = create(:report, name: @name, project: @user.projects.first)
      sign_in @user
    end
    test "report present"do
        get generate_provider_report_csv_index_url
        assert 1, @project.reports.count
    end
    test "campaign provider report" do
        get generate_campaign_provider_report_csv_index_url(@campaign.id)
        assert 1, @project.reports.count
    end
    test "board report" do
      get generate_board_provider_report_csv_index_url
      assert 1, @project.reports.count
    end
    test "provider report" do
      get generate_provider_report_csv_index_url
      assert 1, @project.reports.count
    end
    #test "campaign report" do
    #  get generate_campaign_report_csv_index_url(@campaign.id)
    #  assert_response redirect_to analytics_campaign_path(Campaign.find(@campaign.id).slug)
    #end
  end
