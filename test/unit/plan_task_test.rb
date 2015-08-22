# == Schema Information
#
# Table name: plan_tasks
#
#  id          :integer          not null, primary key
#  project_id  :integer          default(0), not null
#  name        :string(255)      not null
#  is_open     :boolean          default(TRUE), not null
#  task_type   :integer          default(0), not null
#  owner_id    :integer          default(0), not null
#  description :string(255)
#  wbs         :string(255)
#  parent_task :integer
#

require File.dirname(__FILE__) + '/../test_helper'

class PlanTaskTest < ActiveSupport::TestCase
  fixtures :projects, :users, :plan_tasks, :plan_requests

  setup do
    User.current = User.find(2)
  end

  test "all_project_tasks project 1" do
    project = Project.find(1)
    filtered = PlanTask.all_project_tasks(project)
    assert_equal 3, filtered.length
    assert_equal 1, filtered[0].project_id
    assert_equal 1, filtered[1].project_id
  end

  test "all_project_tasks project 2" do
    filtered = PlanTask.all_project_tasks(2)
    assert_equal 1, filtered.length
    assert_equal 2, filtered[0].project_id
  end

  test "create new" do
    tmp = PlanTask.new(:name => 'New task', :owner => User.find(2))
    tmp.project = Project.find(1)
    assert tmp.save
  end

  test "validations" do
    # duplicate name for project 1
    tmp = PlanTask.new(:name => 'Task 1', :owner => User.find(2))
    tmp.project = Project.find(1)
    assert !tmp.valid?
    assert tmp.errors[:name]
  end

  test "can edit" do
    tmp = PlanTask.find(1)
    assert !tmp.can_edit?

    tmp = PlanTask.find(2)
    assert tmp.can_edit?
  end

  test "can delete" do
    tmp = PlanTask.find(2)
    assert !tmp.can_delete?
    assert_raise(ActiveRecord::DeleteRestrictionError) { tmp.destroy }

    tmp = PlanTask.find(4)
    assert tmp.can_delete?
    tmp.destroy
    assert tmp.destroyed?
  end
end
