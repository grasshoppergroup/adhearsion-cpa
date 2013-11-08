require 'spec_helper'

module AdhearsionCpa
  describe ControllerMethods do

    let(:mock_call) { double 'Call' }
    subject { Adhearsion::CallController.new mock_call }

    describe "#detect_tone" do
      let(:expected_component) { Punchblock::Component::Input.new mode: :cpa, grammars: expected_grammars }
      let(:mock_complete_event) { double 'Event', reason: mock_signal }

      context "when watching for a fax" do
        let(:mock_signal)         { double 'Signal', type: "fax-ced" }
        let(:expected_grammars) do
          [ Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:fax-ced:1?terminate=true"),
            Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:fax-cng:1?terminate=true") ]
        end

        it "detects a fax" do
          mock_call.should_receive(:write_and_await_response).with expected_component, 5000
          Punchblock::Component::Input.any_instance.should_receive(:complete_event).and_return mock_complete_event

          subject.detect_tone(:fax, timeout: 5).type.should == "fax-ced"
        end
      end

      context "when watching for a beep and modem" do
        let(:mock_signal) { double 'Signal', type: :beep }
        let(:expected_grammars) do
          [ Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:beep:1?terminate=true"),
            Punchblock::Component::Input::Grammar.new(url: "urn:xmpp:rayo:cpa:modem:1?terminate=true") ]
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
    end
  end
end
