module Markov
  module Statistics
    class RandomEvent
      def initialize(outcome_counts = {})
        @outcome_counts = outcome_counts
      end

      def add_outcome(outcome, count)
        @outcome_counts[outcome] = count
      end

      def normalized_outcome_probabilities
        total_outcome_counts = @outcome_counts.values.reduce(:+).to_f
        @outcome_counts.map { |outcome, count| [outcome, count / total_outcome_counts] }.to_h
      end

      def predict!
        roll = rand
        selected = nil
        normalized_outcome_probabilities.inject(0.0) do |acc, (outcome, probability)|
          if (acc += probability) > roll
            selected = outcome 
            break
          end
          acc
        end
        selected
      end
    end
  end
end
