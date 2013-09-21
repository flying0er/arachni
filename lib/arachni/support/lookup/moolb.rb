=begin
    Copyright 2010-2014 Tasos Laskos <tasos.laskos@gmail.com>
    All rights reserved.
=end

require_relative '../cache'

module Arachni
module Support::LookUp

#
# Opposite of Bloom a filter, ergo Moolb.
#
# Basically a cache used for look-up operations.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
class Moolb < Base

    DEFAULT_OPTIONS = {
        strategy:   Support::Cache::RandomReplacement,
        max_size:   100_000
    }

    # @param    [Hash]  options
    # @option options [Support::Cache::Base]  :strategy (Support::Cache::RandomReplacement)
    #   Sets the type of cache to use.
    #
    # @option options [Integer]  :max_size (100_000)
    #   Maximum size of the cache.
    #
    # @see DEFAULT_OPTIONS
    #
    def initialize( options = {} )
        super( options )

        @options.merge!( DEFAULT_OPTIONS.merge( options ) )
        @collection = @options[:strategy].new( @options[:max_size] )
    end

    #
    # @param    [#persistent_hash] item item to insert.
    #
    # @return   [HashSet]  self
    #
    def <<( item )
        @collection[calculate_hash( item )] = true
        self
    end
    alias :add :<<

end

end
end
