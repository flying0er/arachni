=begin
    Copyright 2010-2012 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

module Arachni
module Plugins

#
# Automated login plugin.
#
# It looks for the login form in the user provided URL,
# merges its input field with the user supplied parameters and sets the cookies
# of the response as framework-wide cookies to be used by the spider later on.
#
# @author: Tasos "Zapotek" Laskos
#                                      <tasos.laskos@gmail.com>
#                                      <zapotek@segfault.gr>
# @version: 0.1.1
#
class AutoLogin < Arachni::Plugin::Base

    attr_accessor :http

    MSG_SUCCESS     = 'Form submitted successfully.'
    MSG_FAILURE     = 'Could not find a form suiting the provided params at: '
    MSG_NO_RESPONSE = 'Form submitted but no response was returned.'

    def prepare
        @framework.pause!
        print_info( "System paused." )

        @params = parse_params

        # we need to declared this in order to pass ourselves
        # as the auditor to the form later in order to submit it.
        @http = @framework.http
    end

    def run

        # grab the page containing the login form
        res  = @http.get( @options['url'], :async => false ).response

        parser = Arachni::Parser.new( @framework.opts, res )
        # parse the response as a Page object
        page = parser.run

        # find the login form
        login_form = nil
        page.forms.each {
            |form|
            login_form = form if login_form?( form )
        }

        if !login_form
            register_results( { :code => 0, :msg => MSG_FAILURE + @options['url'] } )
            print_bad( MSG_FAILURE + @options['url'] )
            return
        end

        name = login_form.raw['attrs']['name'] ? login_form.raw['attrs']['name'] : '<n/a>'
        print_status( "Found log-in form with name: "  + name )

        # merge the input fields of the form with the user supplied parameters
        login_form.auditable.merge!( @params )

        # register us as the auditor
        login_form.auditor( self )
        res = login_form.submit( :async => false, :update_cookies => true ).response

        if !res
            register_results( { :code => -1, :msg => MSG_NO_RESPONSE } )
            print_bad( MSG_NO_RESPONSE )
            return
        else
            register_results( { :code => 1, :msg => MSG_SUCCESS, :cookies => @http.current_cookies.dup } )
            print_ok( MSG_SUCCESS )
            print_info( 'Cookies set to:' )
            @http.current_cookies.each_pair {
                |name, val|
                print_info( '    * ' + name + ' = ' + val )
            }
        end

    end

    def clean_up
        @framework.resume!
    end

    def login_form?( form )
        avail    = form.auditable.keys
        provided = @params.keys

        provided.each {
            |name|
            return false if !avail.include?( name )
        }

        return true
    end

    def parse_params
        params = {}
        @options['params'].split( '&' ).each {
            |param|
            k, v = param.split( '=', 2 )
            params[k] = v
        }
        return params
    end


    def self.info
        {
            :name           => 'AutoLogin',
            :description    => %q{It looks for the login form in the user provided URL,
                merges its input fields with the user supplied parameters and sets the cookies
                of the response and request as framework-wide cookies to be used by the spider later on.
            },
            :author         => 'Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>',
            :version        => '0.1.1',
            :options        => [
                Arachni::OptUrl.new( 'url', [ true, 'The URL that contains the login form.' ] ),
                Arachni::OptString.new( 'params', [ true, 'Form parameters to submit. ( username=user&password=pass )' ] )
            ]
        }
    end

end

end
end
