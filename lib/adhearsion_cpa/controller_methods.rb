module AdhearsionCpa
  module ControllerMethods

    # Detects a tone
    #
    # @example Wait 5 seconds to detect a fax tone
    #   detect_tone "fax-cng", timeout: 5
    # @example Check for multiple tone types
    #   detect_tone "fax-ced", :modem, timeout: 5
    # @example Check for a type, with options
    #   detect_tone :speech, maxTime: 4000, minSpeechDuration: 4000, timeout: 5
    # @example Check for a type, with options, and another type without
    #   detect_tone({:dtmf => {}, speech: {maxTime: 4000, minSpeechDuration: 4000}}, timeout: 5)
    #
    # @return [PunchBlock::Signal] if one of the requested tones was detected
    # @return [nil] if none of the requested tones were detected in time
    #
    def detect_tone(*arguments)
      options = arguments.last.is_a?(Hash) && arguments.count > 1 ? arguments.pop : {}
      ToneDetector.new(self).detect_tones arguments, options
    end

    # Begin asynchronous tone detection, and run the block when the tone is detected
    #
    # @example Asynchronous wait for a dtmf
    #   detect_tone :dtmf, timeout: -1 { |detected| logger.info "Beep! Customer pushed #{detected.inspect}"}
    # @example Asynchronous wait for dtmf presses, running the block multiple times if multiple signals are detected
    def detect_tone!(*arguments)
      options = arguments.last.is_a?(Hash) && arguments.count > 1 ? arguments.pop : {}
      ToneDetector.new(self).detect_tones arguments, options.merge(async: true), &Proc.new
    end
  end
end
