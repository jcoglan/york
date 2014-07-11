require 'nokogiri'
require 'pathname'
require 'pygments.rb'

module York

  EXAMPLE_REGISTER = :york_example_name

  root = File.expand_path('../york', __FILE__)
  require File.join(root, 'highlighter')
  require File.join(root, 'examples_tag')
  require File.join(root, 'show_tag')

  PARAM_SYNTAX = /("[^"]*"|[^ =]+)(?:=("[^"]*"|[^ =]+))?/i
  INT_SYNTAX   = /^[1-9][0-9]*$/

  SOURCE_DIR = '_examples'
  TARGET_DIR = 'examples'

  def self.guess_language(pathname)
    require 'linguist/file_blob'
    Linguist::FileBlob.new(pathname.to_s).language.name
  rescue LoadError
    pathname.extname.sub(/^\./, '')
  end

  def self.parse_tag_params(text, arity = 0)
    matches = text.strip.scan(PARAM_SYNTAX)
    params  = matches[0...arity].map { |pair| remove_quotes(pair.first) }
    options = {}

    matches[arity..-1].each do |key, value|
      options[remove_quotes(key)] = interpret_value(value)
    end

    params + [options]
  end

  def self.remove_quotes(value)
    value.gsub(/^"(.*?)"$/, '\1')
  end

  def self.interpret_value(value)
    return true if value.nil?
    value = remove_quotes(value)
    return value.to_i if value =~ INT_SYNTAX
    value
  end

  def self.source_dir(site)
    examples_dir = site.config.fetch('york', {}).fetch('source', SOURCE_DIR)
    Pathname.new(site.source).join(examples_dir)
  end

end
