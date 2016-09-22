require 'test_helper'

class NavTest < ActiveSupport::TestCase

  test "category creation" do
    c = Nav::Category.create("Clusters", [{path: "/1"}, {path: "/2"}])
    assert_instance_of Nav::Category, c
    assert_equal 2, c.links.count
    assert_instance_of Nav::Path, c.links.first
    assert_instance_of Nav::Path, c.links.last
  end

  test "link creation" do
    assert_instance_of Nav::Link, Nav::Link.create({"url"=>"/pun/sys/shell/ssh/oakley.osc.edu", "icon"=>"fa fa-terminal"})
    assert_instance_of Nav::Path, Nav::Link.create({path: "/fs/project/PZS0645"})
    assert_instance_of Nav::Path, Nav::Link.create({"path"=>"/Users/efranz", "title"=>"Home Directory", "icon"=>"fa fa-home"})
    assert_instance_of Nav::Separator, Nav::Link.create("separator")
    assert_instance_of Nav::Logout, Nav::Link.create("logout")
  end

  test "to_partial_path" do
    assert_equal "shared/nav/app", Nav::App.new.to_partial_path
    assert_equal "shared/nav/category", Nav::Category.new.to_partial_path
    assert_equal "shared/nav/link", Nav::Link.new.to_partial_path
    assert_equal "shared/nav/path", Nav::Path.new.to_partial_path
    assert_equal "shared/nav/separator", Nav::Separator.new.to_partial_path
    assert_equal "shared/nav/logout", Nav::Logout.new.to_partial_path
  end

end
