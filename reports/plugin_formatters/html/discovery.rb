=begin
    Copyright 2010-2014 Tasos Laskos <tasos.laskos@gmail.com>
    All rights reserved.
=end

class Arachni::Reports::HTML

#
# HTML formatter for the results of the Discovery plugin.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
class PluginFormatters::Discovery < Arachni::Plugin::Formatter

    def run
        ERB.new( tpl ).result( binding )
    end

    def tpl
        <<-HTML
            <ul>
            <%results.each do |issue| %>
                <li>
                    <a href="#issue_<%=issue['index']%>">
                        [#<%=issue['index']%>] <%=issue['name']%> at <%=issue['url']%>
                    </a>
                </li>
            <%end%>
            </ul>
        HTML
    end

end
end
