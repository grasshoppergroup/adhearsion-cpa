require 'spec_helper'

module AdhearsionCpa
  describe ControllerMethods do

    let(:mock_call) { double 'Call', active?: true }
    subject { Adhearsion::CallController.new mock_call }

    let(:expected_component)  { Punchblock::Component::Input.new mode: :cpa, grammars: expected_grammars }
    let(:mock_complete_event) { double 'Event', reason: mock_signal }
    let(:mock_signal)     { double 'Signal', type: "dtmf" }

    describe "#detect_tone" do
      context "when watching for a beep" do
        let(:mock_signal)         { double 'Signal', type: "beep" }
        let(:expected_grammars) do
          [ Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:beep:1?terminate=true") ]
        end

        it "detects a beep" do
          mock_call.should_receive(:write_and_await_response).with expected_component
          Punchblock::Component::Input.any_instance.should_receive(:complete_event).and_return mock_complete_event

          subject.detect_tone(:beep, timeout: 5).type.should == "beep"
        end
      end

      context "when watching for a beep and modem" do
        let(:mock_signal) { double 'Signal', type: :beep }
        let(:expected_grammars) do
          [
            Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:beep:1?terminate=true"),
            Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:modem:1?terminate=true")
          ]
        end

        it "detects which tone" do
          mock_call.should_receive(:write_and_await_response).with(expected_component).and_return mock_signal
          Punchblock::Component::Input.any_instance.should_receive(:complete_event).and_return mock_complete_event

          subject.detect_tone(:beep, :modem, timeout: 5).type.should == :beep
        end
      end

      context "when timing out" do
        let(:expected_grammars) { [ Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:beep:1?terminate=true") ] }

        it "returns nil" do
          mock_call.should_receive(:write_and_await_response).with(expected_component).and_raise Timeout::Error
          Punchblock::Component::Input.any_instance.should_receive(:executing?).and_return true
          Punchblock::Component::Input.any_instance.should_receive :stop!

          subject.detect_tone(:beep, timeout: 5).should be_nil
        end
      end

      context "with an options hash" do
        let(:expected_grammars) do
          [
            Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:speech:1?maxTime=4000;minSpeechDuration=4000;terminate=true"),
          ]
        end

        it "encodes them in the grammar URL" do
          mock_call.should_receive(:write_and_await_response).with expected_component
          Punchblock::Component::Input.any_instance.should_receive(:complete_event).and_return mock_complete_event

          subject.detect_tone :speech, maxTime: 4000, minSpeechDuration: 4000, timeout: 5
        end
      end

      context "with individual options, and an options hash" do
        let(:expected_grammars) do
          [
            Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:speech:1?foo=bar;terminate=true;maxTime=4000;minSpeechDuration=4000"),
            Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:beep:1?foo=bar;terminate=true")
          ]
        end

        it "encodes the individual and group options in the grammar URL" do
          mock_call.should_receive(:write_and_await_response).with expected_component
          Punchblock::Component::Input.any_instance.should_receive(:complete_event).and_return mock_complete_event

          subject.detect_tone({speech: {maxTime: 4000, minSpeechDuration: 4000}, beep: {}}, timeout: 5, foo: :bar)
        end
      end
    end

    describe "#detect_tone!" do
      let(:mock_component) { double Punchblock::Component::Input, executing?: true }

      before do
        Punchblock::Component::Input.should_receive(:new).
          with(mode: :cpa, grammars: expected_grammars).
          and_return mock_component

        mock_component.should_receive(:register_event_handler).with Punchblock::Component::Input::Signal do |&block|
          @on_detect_block = block
        end
        mock_call.should_receive(:write_and_await_response).with mock_component
      end

      context "watches in the background" do
        let(:expected_grammars) do
          [ Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:dtmf:1?terminate=true") ]
        end

        it "detects the dtmf" do
          detector = subject.detect_tone!(:dtmf, timeout: 0.02) { |tone| tone.type }
          detector.should == mock_component
          mock_signal.should_receive :type
          @on_detect_block.call mock_signal

          mock_component.should_receive :stop!
          sleep 0.03
        end
      end

      context " with :terminate set to false" do
        let(:expected_grammars) do
          [ Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:dtmf:1") ]
        end

        it "watches repeatedly in the background" do
          detector = subject.detect_tone!(:dtmf, timeout: 0.02, terminate: false) { |tone| tone.type }
          detector.should == mock_component

          mock_signal.should_receive(:type).twice
          @on_detect_block.call mock_signal
          @on_detect_block.call mock_signal

          mock_component.should_receive :stop!
          sleep 0.03
        end
      end
    end
  end
end
