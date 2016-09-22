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

  test "nav config category hierarchy" do
    nav = Nav.categories({
      "Main" => {
        "Apps" => [],
        "Clusters" => []
      },
      "Other" => [{'title' => 'Main', 'url' => 'www.osc.edu'}]
    })

    assert_equal 2, nav.count
    assert_instance_of Nav::Category, nav[0]
    assert_instance_of Nav::Category, nav[1]
    assert_equal 2, nav[0].links.count
    assert_instance_of Nav::Category, nav[0].links[0]
    assert_instance_of Nav::Category, nav[0].links[1]
  end

  test "nav config category hierarchy symbols" do
    nav = Nav.categories({
      Main: {
        Apps: [],
        Clusters: []
      },
      Other: [{title: 'Main', url: 'www.osc.edu'}]
    })

    assert_equal 2, nav.count
    assert_instance_of Nav::Category, nav[0]
    assert_instance_of Nav::Category, nav[1]
    assert_equal 2, nav[0].links.count
    assert_instance_of Nav::Category, nav[0].links[0]
    assert_instance_of Nav::Category, nav[0].links[1]
  end

  test "nav link types" do
    nav = Nav.categories({
      Main: [
        {title: 'Main', url: 'www.osc.edu'}, # Link
        {app: :systemstatus}, # App with owner sys
        {app: :job, owner: :efranz}, # App with owner efranz
        {path: '/users/PZS0562/efranz'}, # Path
        :separator, # Separator
        'separator', # Separator
        :logout, # Logout
        'logout', # Logout
      ]
    })

    nav.first.links.tap do |links|
      assert_equal 8, links.count
      assert_instance_of Nav::Link, links[0]
      assert_instance_of Nav::App, links[1]
      assert_instance_of Nav::App, links[2]
      assert_instance_of Nav::Path, links[3]
      assert_instance_of Nav::Separator, links[4]
      assert_instance_of Nav::Separator, links[5]
      assert_instance_of Nav::Logout, links[6]
      assert_instance_of Nav::Logout, links[7]
    end
  end

  test "nav values" do
    link = Nav.categories({N: [{app: 'systemstatus'}]}).first.links.first
    assert_equal :sys, link.owner
    assert_equal "systemstatus", link.app

    link = Nav.categories({N: [{app: 'systemstatus', owner: 'efranz'}]}).first.links.first
    assert_equal 'efranz', link.owner
    assert_equal "systemstatus", link.app
  end
end
