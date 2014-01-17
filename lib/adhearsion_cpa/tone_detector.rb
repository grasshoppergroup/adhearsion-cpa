module AdhearsionCpa
  class ToneDetector

    attr_accessor :tones, :timeout

    def initialize(controller)
      @controller = controller
    end

    def detect_tones(tones, options)
      @tones = tones
      process options

      component.register_event_handler Punchblock::Component::Input::Signal do |event|
        yield event if block_given?
      end if async?

      call.write_and_await_response component, timeout if call_alive?

      if async?
        component
      else
        component.complete_event.reason
      end
    rescue Adhearsion::Call::CommandTimeout
      @component.stop! if @component && @component.executing?
      nil
    end

  private

    def process(opts)
      @async   = opts.delete :async
      @timeout = opts.delete(:timeout) || 1
      @timeout = nil if @timeout == -1
      @timeout *= 1_000 if @timeout
      opts[:terminate] == false ? opts.delete(:terminate) : opts[:terminate] = true

      @options = opts
    end

    def component
      @component ||= Punchblock::Component::Input.new mode: :cpa, grammars: tone_grammars
    end

    def tone_grammars
      tones.map do |tone_object|
        if tone_object.is_a? Hash
          tone_object.map do |tone, individual_options|
            combined_options = @options.merge individual_options
            build_grammar_for tone, combined_options
          end
        else
          build_grammar_for tone_object
        end
      end.flatten
    end

    def build_grammar_for(tone, opts={})
      opts.merge! @options
      ns_url = "#{Punchblock::BASE_RAYO_NAMESPACE}:cpa:#{tone}:#{Punchblock::RAYO_VERSION}"
      opts.each_with_index do |(k, v), i|
        if i == 0
          ns_url << "?#{k}=#{v}"
        else
          ns_url << ";#{k}=#{v}"
        end
      end

      Punchblock::Component::Input::Grammar.new url: ns_url
    end

    def async?
      @async
    end

    def call
      @controller.call
    end

    def call_alive?
      call && call.active?
    end
  end
end
