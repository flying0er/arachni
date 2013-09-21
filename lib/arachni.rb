=begin
    Copyright 2010-2014 Tasos Laskos <tasos.laskos@gmail.com>
    All rights reserved.
=end

require 'rubygems'
require 'bundler/setup'

def ap( obj )
    super obj, raw: true
end

module Arachni
end

require_relative 'arachni/version'
require_relative 'arachni/banner'

#
# If there's no UI driving us then there's no output interface.
#
# Chances are that someone is using Arachni as a Ruby lib so there's no
# need for a functional output interface, so provide non-functional one.
#
if !Arachni.constants.include?( :UI )
    require_relative 'arachni/ui/foo/output'
end

require_relative 'arachni/framework'
