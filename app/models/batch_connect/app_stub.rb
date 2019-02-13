module BatchConnect
  class AppStub < App

    def form_config(binding: nil)
      if Configuration.render_batch_connect_erb_for_nav?
        super
      else
        {}
      end
    end
  end
end
