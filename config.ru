$:.unshift('./lib')

require 'bundler/setup'
require 'serialcaster/app'

run Serialcaster::App
