require 'pry'
require 'spec_helper'
require 'markov'

describe Markov do
  it "should have a VERSION constant" do
    expect(subject.const_get('VERSION')).to_not be_empty
  end
end

include Statistics
describe RandomEvent do
  context 'when an event has only one outcome' do
    it 'always happens' do
      expect(RandomEvent.new(always: 1).predict!).to eq(:always)
    end
  end

  context 'when the event has multiple outcomes' do
    let(:trials) { 100_000 }

    subject(:event) do
      RandomEvent.new(heads: 51, tails: 49)
    end

    it 'should distribute them' do
      coinflips = trials.times.map { event.predict! }

      heads_variance = (coinflips.count(:heads) - trials/2).abs
      tails_variance = (coinflips.count(:tails) - trials/2).abs

      expected_variance = trials/10 

      expect(heads_variance).to be < expected_variance
      expect(tails_variance).to be < expected_variance
    end
  end
end

describe TransitionMatrix do
  subject(:matrix) { TransitionMatrix.new(depth: depth) }

  context "when adding transitions" do
    context 'of depth 1 (zero-memory)' do
      let(:depth) { 1 }
      it 'should form a "transition" to a state from no-context' do
        matrix.add_transition(%w[ hello ])
        expect(matrix.transitions_from([])).to eq({'hello' => 1})
        expect(matrix.transitions_from(%w[ anything here ])).to eq({'hello' => 1})
      end
    end

    context 'of depth 2' do
      let(:depth) { 2 }

      it 'should form a transition between two states' do
        matrix.add_transition(%w[ hello world ])
        expect(matrix.transitions_from('hello')).to eq({'world' => 1})

        matrix.add_transition(%w[ hello world ])
        expect(matrix.transitions_from('hello')).to eq({'world' => 2})
      end

      it 'should not add a transition that is too short' do
        expect {
          matrix.add_transition(%w[ it ])
        }.to raise_error
      end
    end

    context 'of depth 3' do
      let(:depth) { 3 }
      it 'should form a transition between three states' do
        matrix.add_transition(%w[ why hello there ])
        expect(matrix.transitions_from(%w[ why hello ])).to eq({'there' => 1})
      end
    end

    context 'of depth 4' do
      let(:depth) { 4 }
      it 'should form a transition between four states' do
        matrix.add_transition(%w[ in the beginning there ])
        transitions = matrix.transitions_from(%w[ in the beginning ])
        expect(transitions).to eq({'there' => 1})
      end
    end
  end
end

describe Chain do
  subject(:chain) do
    Chain.new(order: order)
  end

  let(:order) { 2 }

  context '#order' do
    it 'is two by default' do
      expect(Chain.new.order).to eq(2)
    end

    it 'is whatever order specified otherwise' do
      expect(chain.order).to eq(order)
    end
  end

  context "#parse" do
    it 'should ingest the state elements corpus' do
      expect { chain.parse("hello world hello there") }.to change { chain.words.length }.by(4)
    end

    it 'should assemble a transition matrix' do
      expect { chain.parse("hello world hello there") }.to change { chain.transitions_from('h') }.to({'e' => 3}) #33'there' => 1})
    end
  end

  context "#generate" do
    let(:order) { 3 }
    before do
      chain.parse(File.read("data/war-and-peace-ch-xxii.txt"))
    end

    it 'should ingest a corpus and generate a sentence' do
      generated = chain.generate!
      expect(generated).to be_a(String)
      expect(generated).not_to be_empty
    end
  end
end
