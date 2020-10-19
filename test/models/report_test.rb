require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  setup do
    @name = "Report"
    @project_id = "2"
    @project =  create(:project, name: @name, id: @project_id)
    @user = create(:user,role: "provider", name: @name)
    @campaign = create(:campaign, name: @name,project: @user.projects.first, project_id: @project_id)
    @report = create(:report, name: @name, project: @user.projects.first)
  end
  test 'report exists' do
    assert 1, @project.reports.count
  end
  test "report has name"do
    assert @name, @report.name
  end
end
