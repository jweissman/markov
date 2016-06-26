require 'markov/server'
require 'oj'
require 'thor'

module Markov
  class CLI < Thor
    desc "analyze SOURCE_FILE [SOURCE_FILE ...] --out_json JSON_TARGET [--order n --new_words]",
      "analyze the target source files and save the chain data to JSON_TARGET ('data/shakespeare.json')"
    option :order
    option :out_json
    option :new_words
    def analyze(*source_file_paths)
      raise "Please provide an --out_json options!" unless options['out_json'] # || options['out_markov']

      order = options.fetch('order',6).to_i
      new_words = options['new_words']

      say "Constructing chain of order #{order}"
      chain = Chain.new(name: source_file_paths.map { |f| File.basename(f,'.txt') }.join('/'), order: order, new_words: new_words)

      source_file_paths.each do |source_file_path|
        say "Reading #{source_file_path} into memory..."
        text = File.read(source_file_path)

        say "Parsing #{source_file_path}..."
        chain.parse(text)
      end

      outfile = options['out_json']
      say "Writing JSON data to #{outfile}..."
      File.write(outfile, Oj.dump(chain))
    end

    desc "sample ANALYSIS_FILE_PATH", "sample the analyzed data"
    option :max
    option :show
    option :start_text
    def sample(analysis_file="data/shakespeare.json")
      say "Reading analysis files..."
      chain = load_chain(analysis_file)

      max = options.fetch('max', 1_000).to_i
      start_text = options.fetch('start_text', "")

      say "Sampling #{max} characters."
      say "With drama!" if options['show']
      say "Using start text:\n#{start_text}" if start_text

      say "==== BEGIN SAMPLE ===="
      text = chain.generate!(max: max, show: options['show'], start_text: start_text)
      puts text unless options['show']
      say "==== END SAMPLE ===="
    end

    desc "serve ANALYSIS_FILE_PATH [ANALYSIS_FILE_PATH...]", "serve the analyzed data streams"
    option :p
    def serve(*analysis_files)
      Server.configure do |config|
        config.set :chains, analysis_files.map { |f| load_chain(f) }
        config.set :port, options['p'] if options['p']
      end

      Server.run!
    end

    private
    def load_chain(analysis_file)
      chain_data = File.read(analysis_file)
      filetype = File.extname(analysis_file)
      if filetype == ".json"
        say "Reconstructing chain from JSON data in #{analysis_file}..."
        Oj.load(chain_data)
        say "Done!"
      else
        raise "Can't load chain from '#{analysis_file}'"
      end
    end

    def say(text)
      puts "       #{text}"
    end
  end
end
