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

module Reports

class HTML
module PluginFormatters

    #
    # HTML formatter for the results of the CookieCollector plugin
    #
    # @author: Tasos "Zapotek" Laskos
    #                                      <tasos.laskos@gmail.com>
    #                                      <zapotek@segfault.gr>
    # @version: 0.1.1
    #
    class CookieCollector < Arachni::Plugin::Formatter
        include Arachni::Reports::HTML::Utils

        def run
            return ERB.new( tpl ).result( binding )
        end

        def tpl
            %q{
                <h3>Cookies</h3>
                <ul>
                <% @results.each do |entry| %>
                    <li>
                        On <%=entry[:time].to_s%> @ <a href="<%=escapeHTML(entry[:res]['effective_url'])%>"><%=escapeHTML(entry[:res]['effective_url'])%></a>
                        <br/>
                        Cookies were forced to:
                        <ul>
                            <% entry[:cookies].each_pair do |name, val| %>
                                <li><%=escapeHTML(name)%> = <%=escapeHTML(val)%></li>
                            <%end%>
                        </ul>
                    </li>
                <%end%>
                </ul>
            }
        end

    end

end
end

end
end
