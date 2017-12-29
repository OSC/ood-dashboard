class Announcements
  include Enumerable

  class << self
    # Parse from an announcement path file/dir
    # @param path [#to_s] announcement path
    # @return [Announcements] the parsed announcements
    def parse(path)
      path = Pathname.new(path.to_s).expand_path

      if path.directory?
        paths = Pathname.glob(path.join("*.{md,yml}")).sort
      else
        paths = [path]
      end

      new( paths.map {|p| Announcement.parse(p)}.compact.select(&:valid?) )
    end

    # Build a list of announcements from files
    # @return [Announcements] all announcements
    def all
      if path = Configuration.announcement_path
        parse(path)
      else
        new
      end
    end
  end

  # @param announcements [Array<Announcement>] list of announcements
  def initialize(announcements = [])
    @announcements = announcements
  end

  # For a block {|announcement| ...}
  # @yield [announcement] Gives the next announcement object in the list
  def each(&block)
    @announcements.each(&block)
  end
end
