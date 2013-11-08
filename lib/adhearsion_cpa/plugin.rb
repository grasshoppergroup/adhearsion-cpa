module AdhearsionCpa
  class Plugin < Adhearsion::Plugin

    init :adhearsion_cpa do
      Adhearsion::CallController.class_eval do
        include AdhearsionCpa::ControllerMethods
      end

      logger.info "Adhearsion-CPA has been loaded"
    end

    config :adhearsion_cpa do
    end
  end
end
