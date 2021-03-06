require File.dirname(__FILE__) + '/../test_helper'

class PlanGroupsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :trackers, :members, :member_roles,
    :enabled_modules, :plan_groups, :plan_group_members

  setup do
    @plan_group = plan_groups(:one)

    @request.session[:user_id] = 2
    Role.find(1).add_permission! :planner_admin
    Project.find(1).enabled_module_names = [:planner]
  end

  test "should get index" do
    get :index, :project_id => 1

    assert_response :success
    assert_template 'index'
    assert_equal PlanGroup.all_project_groups(1), assigns(:plan_groups)
  end

  test "should get new" do
    get :new, :project_id => 1

    assert_response :success
    assert_template 'new'
  end

  test "should create plan_group" do
    assert_difference('PlanGroup.count') do
      post :create, :project_id => 1, :plan_group => {
        :group_type => PlanGroup::TYPE_TEAM,
        :leader_id => @plan_group.leader_id,
        :name => "A new group",
        :parent_group => @plan_group.parent_group
      }
    end

    assert_redirected_to plan_group_path(assigns(:plan_group))

    tmp = assigns(:plan_group)
    assert_equal 'A new group', tmp.name
    assert_equal PlanGroup::TYPE_TEAM, tmp.group_type
    assert_equal @plan_group.leader_id, tmp.leader_id
    assert_equal @plan_group.parent_group, tmp.parent_group
  end

  test "should not create invalid" do
    PlanGroup.any_instance.stubs(:save).returns(false)
    post :create, :project_id => 1, :plan_group => {
      :group_type => PlanGroup::TYPE_TEAM,
      :leader_id => @plan_group.leader_id,
      :name => "A new group",
      :parent_group => @plan_group.parent_group
    }
    assert_template 'new'
  end

  test "should show plan_group" do
    get :show, :id => @plan_group.id

    assert_response :success
    assert_template 'show'
    assert_equal @plan_group, assigns(:plan_group)
  end

  test "should get edit" do
    get :edit, :id => @plan_group.id

    assert_response :success
    assert_template 'edit'
    assert_equal @plan_group, assigns(:plan_group)
  end

  test "should update plan_group" do
    put :update, :id => @plan_group.id, :plan_group => {
      :group_type => PlanGroup::TYPE_GROUP,
      :leader_id => 3,
      :name => 'New name',
      :parent_group => @plan_group.parent_group
    }
    assert_redirected_to plan_group_path(assigns(:plan_group))

    tmp = PlanGroup.find(@plan_group.id)
    assert_equal 'New name', tmp.name
    assert_equal PlanGroup::TYPE_GROUP, tmp.group_type
    assert_equal 3, tmp.leader_id
    assert_equal @plan_group.parent_group, tmp.parent_group
  end

  test "should not update invalid" do
    PlanGroup.any_instance.stubs(:update_attributes).returns(false)
    put :update, :id => @plan_group.id, :plan_group => {
      :group_type => PlanGroup::TYPE_GROUP,
      :leader_id => 3,
      :name => 'New name',
      :parent_group => @plan_group.parent_group
    }
    assert_template 'edit'
  end

  test "should destroy plan_group" do
    assert_difference('PlanGroup.count', -1) do
      delete :destroy, :id => @plan_group.id
    end

    assert_redirected_to project_plan_groups_path(@plan_group.project)
  end

  test "should add plan_group member" do
    assert_difference('PlanGroupMember.count') do
      post :add_membership, :id => 2, :membership => [3]
    end

    assert_redirected_to plan_group_path(assigns(:plan_group))
    assert PlanGroupMember.where(:plan_group_id => 2, :user_id => 3).exists?
  end

  test "should add plan_group member XHR" do
    assert_difference('PlanGroupMember.count') do
      xhr :post, :add_membership, :id => 2, :membership => [3]
    end

    assert_response :success
    assert_template 'edit_membership'
    assert_equal 'text/javascript', response.content_type
    assert_include 'member-list', response.body
    assert_include 'non-member-list', response.body

    assert PlanGroupMember.where(:plan_group_id => 2, :user_id => 3).exists?
  end

  test "should remove plan_group member" do
    assert_difference('PlanGroupMember.count', -1) do
      delete :remove_membership, :id => 1, :membership_id => 2
    end

    assert_redirected_to plan_group_path(assigns(:plan_group))
    assert !PlanGroupMember.exists?(2)
  end

  test "should remove plan_group member XHR" do
    assert_difference('PlanGroupMember.count', -1) do
      xhr :delete, :remove_membership, :id => 1, :membership_id => 2
    end

    assert_response :success
    assert_template 'edit_membership'
    assert_equal 'text/javascript', response.content_type
    assert_include 'member-list', response.body
    assert_include 'non-member-list', response.body
    assert !PlanGroupMember.exists?(2)
  end
end
