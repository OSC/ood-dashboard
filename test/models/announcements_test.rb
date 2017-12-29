require 'test_helper'

class AnnouncementsTest < ActiveSupport::TestCase
  test "should respond to each" do
    announcements = Announcements.new
    assert_respond_to announcements, :each
  end

  test "should return empty list if no valid path" do
    Configuration.expects(:announcement_path).returns(nil)
    announcements = Announcements.all
    assert_equal 0, announcements.count
  end

  test "should not parse file that doesn't exist" do
    f = Tempfile.open(["announcement", ".md"])
    path = f.path
    f.close(true)

    announcements = Announcements.parse(path)
    assert_equal 0, announcements.count
  end

  test "should parse single valid markdown file" do
    f = Tempfile.open(["announcement", ".md"])
    f.write %{Test announcement.}
    f.close

    announcements = Announcements.parse(f.path)
    assert_equal 1, announcements.count
    announcement = announcements.first
    assert_equal :warning, announcement.type
    assert_equal "Test announcement.", announcement.msg
  end

  test "should not parse invalid markdown file" do
    f = Tempfile.open(["announcement", ".md"])
    f.write %{   \n \n \t    }
    f.close

    announcements = Announcements.parse(f.path)
    assert_equal 0, announcements.count
  end

  test "should parse a valid yaml file" do
    f = Tempfile.open(["announcement", ".yml"])
    f.write %{type: success\nmsg: <%= true ? "Test announcement." : "Fail!" %>}
    f.close

    announcements = Announcements.parse(f.path)
    assert_equal 1, announcements.count
    announcement = announcements.first
    assert_equal :success, announcement.type
    assert_equal "Test announcement.", announcement.msg
  end

  test "should not parse invalid yaml file" do
    f = Tempfile.open(["announcement", ".yml"])
    f.write %{type: success\nmsg: <%= true ? "null" : "Test announcement." %>}
    f.close

    announcements = Announcements.parse(f.path)
    assert_equal 0, announcements.count
  end

  test "should parse a directory of files" do
    Dir.mktmpdir("announcements") do |dir|
      File.open("#{dir}/valid1.md", "w") do |f|
        f.write %{File 1}
      end
      File.open("#{dir}/valid2.yml", "w") do |f|
        f.write %{msg: "File 2"}
      end
      File.open("#{dir}/invalid1.yml", "w") do |f|
        f.write %{type: danger\nmsg: "<%= true ? "  \n \t " : "Stuff" %>"}
      end

      announcements = Announcements.parse(dir)
      assert_equal 2, announcements.count
    end
  end
end
