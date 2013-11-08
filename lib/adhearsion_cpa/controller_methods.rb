module AdhearsionCpa
  module ControllerMethods

    # Detects a tone
    #
    # @example Check for a fax tone
    #   detect_tone :fax, timeout: 5
    # @example Check for multiple tone types
    #   detect_tone "fax-ced", :modem, timeout: 5
    #
    # @return [PunchBlock::Signal] if one of the requested tones was detected
    # @return [nil] if none of the requested tones were detected in time
    #
    def detect_tone(*arguments)
      options = arguments.last.is_a?(Hash) && arguments.count > 1 ? arguments.pop : {}
      ToneDetector.new(self).detect_tones arguments, options
    end
  end
end
