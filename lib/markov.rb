require 'ruby-progressbar'
require 'oj'

require 'markov/version'
require 'markov/transition_matrix'
require 'markov/statistics/random_event'

require 'markov/chain'

module Markov
  def self.generate(thing)
    chain_for(thing).generate_word!.strip
  end

  private
  def self.chains
    @chains ||= {}
  end

  def self.chain_for(thing)
    chains[thing] ||= load_chain(thing)
  end

  def self.load_chain(thing)
    analysis_file = File.join(
      File.expand_path(File.dirname(__FILE__)),
      '..',
      'data',
      "#{thing}.json"
    )

    chain_data = File.read(analysis_file)
    Oj.load(chain_data)
  end
end
