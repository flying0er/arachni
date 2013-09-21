=begin
    Copyright 2010-2014 Tasos Laskos <tasos.laskos@gmail.com>
    All rights reserved.
=end

#
# Metareport
#
# Creates a file to be used with the Arachni MSF plug-in.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
# @version 0.1.3
#
class Arachni::Reports::Metareport < Arachni::Report::Base

    def run
        print_line
        print_status 'Creating file for the Metasploit framework...'

        msf = []
        auditstore.issues.each do |issue|
            next if !issue.metasploitable

            issue.variations.each do |variation|
                url = if (method = issue.method.dup) != 'post'
                    variation.url.split( '?', 2 ).first
                else
                    variation.url
                end

                method = issue.elem if issue.elem == 'cookie' || issue.elem == 'header'

                params = variation.opts[:combo]
                next if !params || !params[issue.var]
                params[issue.var] = params[issue.var].gsub( variation.opts[:injected_orig], 'XXinjectionXX' )

                if method == 'cookie' && variation.headers['request']['cookie']
                    params[issue.var] = URI.encode( params[issue.var], ';' )
                    cookies = sub_cookie( variation.headers['request']['cookie'], params )
                    variation.headers['request']['cookie'] = cookies.dup
                end

                # ap sub_cookie( variation.headers['request']['cookie'], params )

                uri = URI( url )
                msf << {
                    host:        uri.host,
                    port:        uri.port,
                    vhost:       '',
                    ssl:         uri.scheme == 'https',
                    path:        uri.path,
                    query:       uri.query,
                    method:      method.upcase,
                    params:      params,
                    headers:     variation['headers']['request'].dup,
                    pname:       issue.var,
                    proof:       variation['regexp_match'],
                    risk:        '',
                    name:        issue.name,
                    description: issue.description,
                    category:    'n/a',
                    exploit:     issue.metasploitable
                }
            end
        end

        File.open( outfile, 'w' ) { |f| ::YAML.dump( msf, f ) }

        print_status "Saved in '#{outfile}'."
    end

    def sub_cookie( str, params )
        hash = {}
        str.to_s.split( ';' ).each do |cookie|
            k, v = cookie.split( '=', 2 )
            hash[k] = v
        end

        hash.merge( params ).map{ |k,v| "#{k}=#{v}" }.join( ';' )
    end

    def self.info
        {
            name:        'Metareport',
            description: %q{Creates a file to be used with the Arachni MSF plug-in.},
            author:      'Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>',
            version:     '0.1.3',
            options:     [ Options.outfile( '.msf' ) ]

        }
    end

end
