# dashboard app specific configuration
class Configuration
  class << self
    attr_writer :app_development_enabled
    attr_writer :app_sharing_enabled

    # FIXME: temporary
    attr_accessor :app_sharing_facls_enabled
    alias_method :app_sharing_facls_enabled?, :app_sharing_facls_enabled

    def app_development_enabled?
      return @app_development_enabled if defined? @app_development_enabled
      ENV['OOD_APP_DEVELOPMENT'].present? || DevRouter.base_path.exist?
    end
    alias_method :app_development_enabled, :app_development_enabled?

    def app_sharing_enabled?
      return @app_sharing_enabled if defined? @app_sharing_enabled
      @app_sharing_enabled = ENV['OOD_APP_SHARING'].present?
    end
    alias_method :app_sharing_enabled, :app_sharing_enabled?

    # The app's configuration root directory
    # @return [Pathname] path to configuration root
    def config_root
      Pathname.new(ENV["OOD_CONFIG"] || "/etc/ood/config/apps/dashboard")
    end

    # A hash describing the configuration read in from the app's configuration
    # file
    # @return [Hash{Symbol=>Object}] configuration hash
    def config
      yaml = config_root.join("config.yml")
      config = yaml.exist? ? YAML.load(ERB.new(yaml.read, nil, "-").result) : {}

      if config.is_a?(Hash)
        config.compact.deep_symbolize_keys
      else
        Rails.logger.error("ERROR: Configuration file '#{yaml}' needs to define a Hash")
        {}
      end
    rescue Psych::SyntaxError => e
      Rails.logger.error("ERROR: YAML syntax error occurred while parsing #{yaml} - #{e.message}")
      {}
    end

    # The path to the motd file
    # @return [String, nil] motd path
    def motd_path
      ENV["MOTD_PATH"] || config[:motd_path].try(:to_s)
    end

    # Format to display motd
    # @return [String, nil] motd format
    def motd_format
      ENV["MOTD_FORMAT"] || config[:motd_format].try(:to_s)
    end
  end
end

Rails.application.configure do |config|
  config.paths["config/initializers"] << Configuration.config_root.join("initializers").to_s
end
