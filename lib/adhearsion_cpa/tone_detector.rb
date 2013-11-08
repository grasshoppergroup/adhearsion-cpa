module AdhearsionCpa
  class ToneDetector

    attr_accessor :controller, :tones

    def initialize(controller)
      @controller = controller
    end

    def detect_tones(tones, options)
      @tones = tones
      process_tones

      timeout = options.delete(:timeout) || 1
      timeout = nil if timeout == -1
      timeout *= 1_000 if timeout

      component = Punchblock::Component::Input.new mode: :cpa, grammars: tone_grammars
      controller.call.write_and_await_response component, timeout
      component.complete_event.reason
    rescue Adhearsion::Call::CommandTimeout
      component.stop! if component && component.executing?
      nil
    end

  private

    def tone_grammars
      tones.map do |tone|
        ns_url = "#{Punchblock::BASE_RAYO_NAMESPACE}:cpa:#{tone}:#{Punchblock::RAYO_VERSION}?terminate=true"
        Punchblock::Component::Input::Grammar.new url: ns_url
      end
    end

    def process_tones
      if tones.include? :fax
        tones.delete :fax
        tones << "fax-ced"
        tones << "fax-cng"
      end
    end
  end
end
