ENV['GEM_HOME'] = File.expand_path('vendor/bundle')
ENV['GEM_PATH'] = ENV['GEM_HOME']
ENV['BUNDLE_GEMFILE'] = File.expand_path('Gemfile')

require 'bundler/setup'
require_relative 'src/TextSender.rb'

text_sender = TextSender.new()
text_sender.run
