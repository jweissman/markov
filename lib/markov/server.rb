require 'markov' # ...?
require 'oj'
require 'sinatra'
require 'thin'

module Markov
  class Server < Sinatra::Base
    get '/' do
      "<b>markov processes</b><br/>" +
      settings.chains.sort_by(&:name).map do |ch|
        "<a href='/#{ch.name}'>#{ch.name}</a>"
      end.join(" | ")
    end

    get '/:chain' do |name|
      chain = settings.chains.detect { |ch| ch.name == name }
      if chain
        stream do |out|
          out << "<pre>"
          chain.generate!(show: true) do |ch|
            out << ch
          end
          out << "</pre>"
        end
      else
        "No chain found :("
      end
    end
  end
end

if __FILE__ == $0
  include Markov

  Server.configure do |config|
    config.set :chains, Dir.glob(File.join('data','**.json')).map { |f| Oj.load(File.read(f)) }
  end

  Server.run!(port: ENV['PORT'])
end
