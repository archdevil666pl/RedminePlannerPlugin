# == Schema Information
#
# Table name: plan_requests
#
#  id             :integer          not null, primary key
#  requester_id   :integer          default(0), not null
#  resource_id    :integer          default(0), not null
#  approver_id    :integer          default(0)
#  task_id        :integer          default(0), not null
#  req_type       :integer          default(0), not null
#  priority       :integer          default(3), not null
#  description    :text
#  status         :integer          default(0), not null
#  requested_on   :datetime
#  approved_on    :datetime
#  approver_notes :text
#

require File.dirname(__FILE__) + '/../test_helper'

class PlanRequestTest < ActiveSupport::TestCase
  include Redmine::I18n

  fixtures :projects, :users, :plan_tasks, :plan_requests, :plan_details
  if Redmine::VERSION::MAJOR == 3
    fixtures :email_addresses
  end

  setup do
    User.current = User.find(2)
  end

  test "create new" do
    tmp = PlanRequest.new(
      :requester => User.find(2), :resource => User.find(3), :task => PlanTask.find(1))
    assert tmp.save
  end

  test "validations" do
    req = PlanRequest.find(1)
    req.status = 37
    req.priority = 42
    assert !req.valid?
    assert req.errors[:status]
    assert req.errors[:priority]
  end

  test "status string" do
    test_status PlanRequest::STATUS_NEW,      l(:label_planner_req_status_new)
    test_status PlanRequest::STATUS_READY,    l(:label_planner_req_status_ready)
    test_status PlanRequest::STATUS_APPROVED, l(:label_planner_req_status_approved)
    test_status PlanRequest::STATUS_DENIED,   l(:label_planner_req_status_denied)
    test_status 37, ""
  end

  test "priority string" do
    test_priority PlanRequest::PRIO_LOWEST,  l(:label_planner_req_prio_lowest)
    test_priority PlanRequest::PRIO_LOW,     l(:label_planner_req_prio_low)
    test_priority PlanRequest::PRIO_NORMAL,  l(:label_planner_req_prio_normal)
    test_priority PlanRequest::PRIO_HIGH,    l(:label_planner_req_prio_high)
    test_priority PlanRequest::PRIO_HIGHEST, l(:label_planner_req_prio_highest)
    test_priority 37, ""
  end

  test "type select" do
    select = PlanRequest.priority_select
    assert_equal 5, select.length
    #FIXME: test all five entries
  end

  test "all project requests" do
    requests = PlanRequest.all_project_requests(1)
    assert_equal 6, requests.length
    assert_equal requests[0], PlanRequest.find(1)
    assert_equal requests[1], PlanRequest.find(2)
    assert_equal requests[2], PlanRequest.find(3)
    assert_equal requests[3], PlanRequest.find(5)
    assert_equal requests[4], PlanRequest.find(6)
    assert_equal requests[5], PlanRequest.find(7)
  end

  test "all open requests requester" do
    requests = PlanRequest.all_open_requests_requester(1)
    assert_equal 3, requests.length
    assert_equal requests[0], PlanRequest.find(2)
    assert_equal requests[1], PlanRequest.find(6)
    assert_equal requests[2], PlanRequest.find(7)
  end

  test "all open requests approver" do
    requests = PlanRequest.all_open_requests_approver(1)
    assert_equal 2, requests.length
    assert_equal requests[0], PlanRequest.find(3)
  end

  test "all open requests requestee" do
    requests = PlanRequest.all_open_requests_requestee(1)
    assert_equal 1, requests.length
    assert_equal requests[0], PlanRequest.find(1)
  end

  test "send request" do
    req = PlanRequest.find(2)

    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      req.send_request
    end

    assert req.requested_on
    assert_equal PlanRequest::STATUS_READY, req.status
    assert_equal User.find(1), req.approver
  end

  test "send request without teamleader" do
    req = PlanRequest.find(7)

    assert_no_difference('ActionMailer::Base.deliveries.size') do
      assert !req.send_request
    end
  end

  test "approve request" do
    req = PlanRequest.find(3)
    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      req.approve_deny_request(PlanRequest::STATUS_APPROVED, 'note')
    end

    assert_equal PlanRequest::STATUS_APPROVED, req.status
    assert req.approved_on
    assert_equal 'note', req.approver_notes
  end

  test "deny request" do
    req = PlanRequest.find(3)

    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      req.approve_deny_request(PlanRequest::STATUS_DENIED, 'note')
    end

    assert_equal PlanRequest::STATUS_DENIED, req.status
    assert req.approved_on
    assert_equal 'note', req.approver_notes
  end

  test "test can_edit" do
    req = PlanRequest.find(2)
    assert req.can_edit?

    req.status = PlanRequest::STATUS_DENIED
    assert req.can_edit?

    req = PlanRequest.find(1)
    assert !req.can_edit?
  end

  test "test can_request" do
    req = PlanRequest.find(2)
    assert req.can_request?

    req.status = PlanRequest::STATUS_READY
    assert !req.can_request?

    req.status = PlanRequest::STATUS_DENIED
    assert req.can_request?
  end

  test "test can_approve" do
    req = PlanRequest.find(3)
    assert req.can_approve?

    req.status = PlanRequest::STATUS_APPROVED
    assert !req.can_approve?

    req.status = PlanRequest::STATUS_DENIED
    assert !req.can_approve?
  end

  test "delete dependent" do
    tmp = PlanRequest.find(2)
    assert tmp.details.any?
    assert_no_difference('ActionMailer::Base.deliveries.size') do
      tmp.destroy
    end

    details = PlanDetail.where(:request_id => 2)
    assert details.empty?
  end

  test "delete notification" do
    tmp = PlanRequest.find(5)
    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      tmp.destroy
    end
  end

private
  def test_status(status, string)
    tmp = PlanRequest.new
    tmp.status = status
    assert_equal string, tmp.status_string
  end

  def test_priority(priority, string)
    tmp = PlanRequest.new
    tmp.priority = priority
    assert_equal string, tmp.priority_string
  end
end
