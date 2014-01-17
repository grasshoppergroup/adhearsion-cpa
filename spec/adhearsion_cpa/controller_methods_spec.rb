require 'spec_helper'

module AdhearsionCpa
  describe ControllerMethods do

    let(:mock_call) { double 'Call', active?: true }
    subject { Adhearsion::CallController.new mock_call }

    let(:expected_component)  { Punchblock::Component::Input.new mode: :cpa, grammars: expected_grammars }
    let(:mock_complete_event) { double 'Event', reason: mock_signal }
    let(:mock_signal)         { double 'Signal', type: :beep }

    describe "#detect_tone" do
      context "when watching for a beep" do
        let(:mock_signal)         { double 'Signal', type: "beep" }
        let(:expected_grammars) do
          [ Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:beep:1?terminate=true") ]
        end

        it "detects a fax" do
          mock_call.should_receive(:write_and_await_response).with expected_component, 5000
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
          mock_call.should_receive(:write_and_await_response).with(expected_component, 5000).and_return mock_signal
          Punchblock::Component::Input.any_instance.should_receive(:complete_event).and_return mock_complete_event

          subject.detect_tone(:beep, :modem, timeout: 5).type.should == :beep
        end
      end

      context "with a timeout" do
        let(:expected_grammars) { [ Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:beep:1?terminate=true") ] }

        it "returns nil" do
          mock_call.should_receive(:write_and_await_response).with(expected_component, 5000).and_raise Adhearsion::Call::CommandTimeout
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
          mock_call.should_receive(:write_and_await_response).with expected_component, 5000
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
          mock_call.should_receive(:write_and_await_response).with expected_component, 5000
          Punchblock::Component::Input.any_instance.should_receive(:complete_event).and_return mock_complete_event

          subject.detect_tone({speech: {maxTime: 4000, minSpeechDuration: 4000}, beep: {}}, timeout: 5, foo: :bar)
        end
      end
    end
  end
end
