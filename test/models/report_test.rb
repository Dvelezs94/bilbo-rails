require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  setup do
    @name = "Report"
    @project =  create(:project, name: @name)
    @user = create(:user,role: "provider", name: @name)
    @campaign = create(:campaign, name: @name,project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?)
    @report = create(:report, name: @name, project: @user.projects.first)
  end
  test 'report exists' do
    assert 1, @project.reports.count
  end
  test "report has name"do
    assert @name, @report.name
  end
end
