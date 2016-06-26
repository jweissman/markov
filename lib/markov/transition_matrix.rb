module Markov
  class TransitionMatrix
    attr_reader :depth, :transitions

    def initialize(transitions={}, depth:)
      @depth = depth
      @transitions = transitions
    end

    def add_transition(states)
      # p [ :add_transition, states: states, depth: depth ]
      if states.is_a?(Array) && states.count > @depth
        states = states[-(@depth)..-1]
      end

      unless states.count == depth
        raise "This transition matrix is depth #@depth, not #{states.count}!"
      end

      *key, last = states
      key.inject(@transitions) { |h,k| h[k] ||= {}; h[k] }
      key.inject(@transitions, :fetch)[last] ||= 0
      key.inject(@transitions, :fetch)[last] += 1
    end

    def transitions_from(states)
      states = [states] unless states.is_a?(Array)

      if states.count >= @depth
        states = states[-(@depth-1)..-1]
      end

      if @depth == 1
        states = []
      end

      if states.count > 0
        @transitions.dig(*states)
      else
        @transitions
      end
    end
  end
end
