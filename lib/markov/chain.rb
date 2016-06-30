module Markov
  class Chain
    include Statistics

    attr_reader :name
    attr_reader :order, :words, :new_words
    attr_reader :transition_matrices

    def initialize(name: 'anonymous', order: 2, new_words: false)
      @name = name
      @order = order
      @words = []
      @new_words = new_words

      @transition_matrices = 1.upto(order+1).map do |depth|
        TransitionMatrix.new(depth: depth)
      end
    end

    def count_syllables(s)
      s.scan(/[aiouy]+e*|e(?!d$|ly).|[td]ed|le$/).size
    end

    def transitions_from(states, primary: true)
      states = [states] unless states.is_a?(Array)

      matrices = @transition_matrices.reverse

      candidate_matrix = matrices.
        select { |m| states.count >= m.depth - 1 }.
        detect do |matrix|
          matrix.transitions_from(states)
        end

      if candidate_matrix
        candidate_matrix.transitions_from(states)
      else
        {}
      end
    end

    def parse(text)
      puts "---> PARSE TEXT!"
      puts "     Analyzing character distribution..."
      text.gsub!(/[^A-Za-z \n]/, '')
      @transition_matrices.each do |matrix|
        cons_chars = text.chars.each_cons(matrix.depth)
        progress_bar = ProgressBar.create(
          title: "Parsing characters (depth #{matrix.depth})",
          total: cons_chars.count
        )
        cons_chars.each do |word_group|
          matrix.add_transition(word_group)
          progress_bar.increment
	end
      end

      puts "     Analyzing prosody..."
      @words = text.gsub(/[^A-Za-z \n]/,'').split(/[\n ]/).map(&:strip)
      puts "---> done!"
    end

    def predict_next_state(last_states)
      transition_probabilities = transitions_from(last_states)
      next_state = RandomEvent.new(transition_probabilities)
      next_state.predict!
    end

    def generate!(max: 1_000, start_text: "", show: false) #, original: true)
      generated_count = 0
      generated_text = start_text.chars
      word = nil

      until max && (generated_count +=1)>=max
        word = generate_word!(context: new_words ? ["\n"] : generated_text)

        if show
          word.chars.each do |ch|
            sleep 0.05 + rand*(0.01)
            yield ch
          end
        end

        generated_count += word.chars.count
        generated_text += word.chars
      end

      generated_text.join
    end

    def generate_word!(context: ["\n"])
      if new_words
        word = @words.first
        until !@words.include?(word.chomp) && word.chomp.match(/^[A-Z][a-z]+$/)
          word = (generate_any_word!) #.chomp #(context: generated_text)
        end
        @words.push(word.chomp)
        word
      else
        generate_any_word!(context: context) #generated_text)
      end    
    end

    private
    def generate_any_word!(context: ["\n"])
      generated_chars = []
      char = ''
      until char.match(/[ .,;!?\n]/)
        char = predict_next_state(context+generated_chars)
        generated_chars.push(char)
      end
      generated_chars.join
    end
  end
end
