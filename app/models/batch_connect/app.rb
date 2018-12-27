require "smart_attributes"

module BatchConnect
  class App
    # Router for a deployed batch connect app
    # @return [DevRouter, UsrRouter, SysRouter] router for batch connect app
    attr_accessor :router

    # The sub app
    # @return [String, nil] sub app
    attr_accessor :sub_app

    # Raised when batch connect app components could not be found
    class AppNotFound < StandardError; end

    class << self
      # Generate an object from a token
      # @param token [String] the token
      # @return [App] generated object
      def from_token(token)
        type, *app = token.split("/")
        case type
        when "dev"
          name, sub_app = app
          router = DevRouter.new(name)
        when "usr"
          owner, name, sub_app = app
          router = UsrRouter.new(name, owner)
        else  # "sys"
          name, sub_app = app
          router = SysRouter.new(name)
        end
        new(router: router, sub_app: sub_app)
      end
    end

    # @param router [DevRouter, UsrRouter, SysRouter] router for batch connect
    #   app
    # @param sub_app [String, nil] sub app
    def initialize(router:, sub_app: nil)
      @router  = router
      @sub_app = sub_app && sub_app.to_s
    end

    # Generate a token from this object
    # @return [String] token
    def token
      [router.token, sub_app].compact.join("/")
    end

    # Get the token for this app, excluding the subapp
    # @return [String] token
    def base_token
      router.token
    end

    # Root path to batch connect app
    # @return [Pathname] root directory of batch connect app
    def root
      router.path
    end

    # Root path to the sub apps
    # @return [Pathname] root directory of sub apps
    def sub_app_root
      if Configuration.load_external_bc_config? && router.type == :sys && global_sub_app_root.directory?
        global_sub_app_root
      else
        root.join("local")
      end
    end

    # Global root path to the sub apps
    # @return [Pathname] global root directory of sub apps
    def global_sub_app_root
      Configuration.bc_config_root.join(router.name)
    end

    # Title for the batch connect app
    # @return [String] title of app
    def title
      form_config.fetch(:title, default_title)
    end

    # Default title for the batch connect app
    # @return [String] default title of app
    def default_title
      title  = ood_app.title
      title += ": #{sub_app.titleize}" if sub_app
      title
    end

    # Description for the batch connect app
    # @return [String] description of app
    def description
      form_config.fetch(:description, default_description)
    end

    # Default description for the batch connect app
    # @return [String] default description of app
    def default_description
      ood_app.manifest.description
    end

    # The clusters that are available
    def clusters
      OodAppkit.clusters
    end

    # The clusters that the batch connect app uses
    # invalid cluster ids are ignored
    # @return [Array<OodCore::Cluster>] clusters that app uses
    def cluster_dependencies
      all_cluster_dependencies.select(&:job_allow?)
    end

    def all_cluster_dependencies
      cluster_ids.map {|cluster_id| clusters[cluster_id] }.compact
    end

    # The ids of clusters that the batch connect app declares it uses
    # @return [Array<String>] array of ids of clusters that app declares it uses
    def cluster_ids
      Array.wrap(form_config.fetch(:cluster, nil)).compact.map(&:to_sym)
    end

    # Whether this is a valid app the user can use
    #
    # An app is valid if:
    #
    # 1. The form config exists
    # 2. If any clusters that are declared, the user has access to at least one
    #
    # @return [Boolean] whether valid app
    def valid?
      valid_form_config? && valid_cluster_ids? && declared_clusters_authorized?
    end

    # @return [Boolean] true if form config exists
    def valid_form_config?
      ! form_config.empty?
    end

    # FIXME: There is no test coverage for this
    #        This method would be irrelevant if you had a NullCluster object
    # @return [Boolean] true if all declared cluster ids are valid
    def valid_cluster_ids?
      cluster_ids.all? { |cluster_id|  clusters.include?(cluster_id) }
    end

    # FIXME: there is no test coverage for this
    # @return [Boolean] true if no declared clusters or at least one accessible declared cluster
    def declared_clusters_authorized?
      if all_cluster_dependencies.any?
        cluster_dependencies.any?
      else
        true
      end
    end

    # The reason why this app may or may not be valid
    # @return [String] reason why not valid
    def validation_reason
      if @validation_reason
        @validation_reason
      elsif !valid_cluster_ids?
        "This app requires a cluster that does not exist."
      elsif !declared_clusters_authorized?
        "You do not have access to use this app."
      else
        "There is a problem with this app."
      end
    end

    # The session context described by this batch connect app
    # @return [SessionContext] the session context
    def build_session_context
      local_attribs = form_config.fetch(:attributes, {})
      attrib_list   = form_config.fetch(:form, [])
      BatchConnect::SessionContext.new(
        attrib_list.map do |attribute_id|
          attribute_opts = local_attribs.fetch(attribute_id.to_sym, {})

          # Developer wanted a fixed value
          attribute_opts = { value: attribute_opts, fixed: true } unless attribute_opts.is_a?(Hash)

          # Hide resolution if not using native vnc clients
          attribute_opts = { value: nil, fixed: true } if attribute_id.to_s == "bc_vnc_resolution" && !ENV["ENABLE_NATIVE_VNC"]

          SmartAttributes::AttributeFactory.build(attribute_id, attribute_opts)
        end
      )
    end

    # Generate a hash of the submission options
    # @param session_context [SessionContext] object with attributes
    # @param fmt [String, nil] formatting used for attributes in submit hash
    # @return [Hash] hash of submission options
    def submit_opts(session_context, fmt: nil)
      hsh = {}
      session_context.each do |attribute|
        hsh = hsh.deep_merge attribute.submit(fmt: fmt)
      end
      hsh = hsh.deep_merge submit_config(binding: session_context.get_binding)
    end

    # View used for session if it exists
    # @return [String, nil] session view
    def session_view
      file = root.join("view.html.erb")
      file.read if file.file?
    end

    # Paths to custom javascript files
    # @return [Pathname] paths to custom javascript files that exist
    def custom_javascript_files
      files = [root.join("form.js")]
      files << sub_app_root.join("#{sub_app}.js")
      files.select(&:file?)
    end

    # List of sub apps that are owned by the parent batch connect app
    # (including this app as well)
    # @return [Array<App>] list of sub apps
    def sub_app_list
      @sub_app_list ||= build_sub_app_list
    end

    # Convert object to string
    # @return [String] the string describing this object
    def to_s
      token
    end

    # The comparison operator
    # @param other [#to_s] object to compare against
    # @return [Boolean] whether objects are equivalent
    def ==(other)
      token == other.to_s
    end

    private
      def build_sub_app_list
        return [self] unless sub_app_root.directory? && sub_app_root.readable? && sub_app_root.executable?
        list = sub_app_root.children.select(&:file?).map do |f|
          root = f.dirname
          name = f.basename.to_s.split(".").first
          file = form_file(root: root, name: name)
          self.class.new(router: router, sub_app: name) if f == file
        end.compact
        list.empty? ? [self] : list.sort_by(&:sub_app)
      end

      # Path to file describing form hash
      def form_file(root:, name: "form")
        %W(#{name}.yml.erb #{name}.yml).map { |f| root.join(f) }.select(&:file?).first
      end

      # Path to file describing submission hash
      def submit_file(root:, paths: %w(submit.yml.erb submit.yml))
        Array.wrap(paths).compact.map { |f| root.join(f) }.select(&:file?).first
      end

      # Parse an ERB and Yaml file
      def read_yaml_erb(path:, binding: nil)
        contents = path.read
        contents = render_erb_file(path: path, contents: contents, binding: binding) if path.extname == ".erb"
        YAML.safe_load(contents).to_h.deep_symbolize_keys
      end

      # pure function to render erb, properly setting the filename attribute
      # before rendering
      def render_erb_file(path:, contents:, binding:)
        erb = ERB.new(contents, nil, "-")
        erb.filename = path.to_s
        erb.result(binding)
      end

      # Hash describing the full form object
      def form_config(binding: nil)
        return @form_config if @form_config

        raise AppNotFound, "This app does not exist under the directory '#{root}'" unless root.directory?
        file = form_file(root: root)
        raise AppNotFound, "This app does not supply a form file under the directory '#{root}'" unless file
        hsh = read_yaml_erb(path: file, binding: binding)
        if sub_app
          file = form_file(root: sub_app_root, name: sub_app)
          raise AppNotFound, "This app does not supply a sub app form file under the directory '#{sub_app_root}'" unless file
          hsh = hsh.deep_merge read_yaml_erb(path: file, binding: binding)
        end
        @form_config = hsh
      rescue AppNotFound => e
        @validation_reason = e.message
        return {}
      rescue => e
        @validation_reason = "#{e.class.name}: #{e.message}"
        return {}
      end

      # Hash describing the full submission properties
      def submit_config(binding: nil)
        return @submit_config if @submit_config

        file = submit_file(root: root)
        hsh = file ? read_yaml_erb(path: file, binding: binding) : {}
        if path = form_config.fetch(:submit, nil)
          file = submit_file(root: sub_app_root, paths: path)
          hsh = hsh.deep_merge read_yaml_erb(path: file, binding: binding) if file
        end
        @submit_config = hsh
      end

      # The OOD app object describing this app
      def ood_app
        @ood_app ||= OodApp.new(router)
      end
  end
end
