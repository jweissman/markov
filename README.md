# markov

* [Homepage](https://rubygems.org/gems/markov)
* [Documentation](http://rubydoc.info/gems/markov/frames)
* [Email](mailto:jweissman1986 at gmail.com)

[![Code Climate GPA](https://codeclimate.com/github//markov/badges/gpa.svg)](https://codeclimate.com/github//markov)

## Description

Character-oriented Markov processes for text generation

## Features

## Examples

    require 'markov'
    chain = Markov::Chain.new
    chain.parse(File.read("data/war-and-peace.txt"))
    chain.generate! # => "..."

## Requirements

  - Ruby 2.3.0

## Install

    $ gem install markov

## Synopsis

    $ markov

## Copyright

Copyright (c) 2016 Joseph Weissman

See {file:LICENSE.txt} for details.
