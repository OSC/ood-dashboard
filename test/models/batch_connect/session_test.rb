require 'test_helper'

class BatchConnect::SessionTest < ActiveSupport::TestCase
  test "should return no sessions if dbroot is empty" do
    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      BatchConnect::Session.stubs(:db_root).returns(dir)

      assert_equal [], BatchConnect::Session.all
    end
  end

  test "should only return sorted running sessions from dbroot and clean up completed/corrupt session files" do
    double_session = Class.new(BatchConnect::Session) do
      def completed?
        job_id == "COMPLETED"
      end
    end

    Dir.mktmpdir("dbroot") do |dir|
      dir = Pathname.new(dir)
      double_session.stubs(:db_root).returns(dir)

      [
        { id: "A", job_id: "RUNNING",   created_at: 500 },
        { id: "B", job_id: "RUNNING",   created_at: 100 },
        { id: "C", job_id: "RUNNING",   created_at: 300 },
        { id: "D", job_id: "COMPLETED", created_at: 400 }
      ].each do |v|
        File.open(dir.join(v[:id]), "w") do |f|
          f.write v.to_json
        end
      end
      File.open(dir.join("bad1"), "w") do |f|
        f.write("")
      end
      File.open(dir.join("bad2"), "w") do |f|
        f.write("{)")
      end

      assert_equal ["A", "B", "C", "D", "bad1", "bad2"], dir.children.map(&:basename).map(&:to_s).sort
      sessions = double_session.all
      assert_equal ["A", "C", "B"], sessions.map(&:id)
      assert_equal ["A", "B", "C"], dir.children.map(&:basename).map(&:to_s).sort
    end
  end
end
