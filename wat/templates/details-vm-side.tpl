<div class="side-component">
    <div class="side-header">
        <span class="h2" data-i18n="Remote administration"></span>
    </div>

    <div class="remote-administration-wrapper">
        <% if (Wat.C.checkACL('vm.see.state')) { %>
            <div class="remote-administration-state">
                <% 
                    var vmState = model.get('state');
                    switch(vmState) {
                        case 'stopped':
                %>
                            <div data-i18n data-wsupdate="state-text" data-id="<%= model.get('id') %>">Stopped</div>
                            <div class="fa fa-stop" data-wsupdate="state" data-id="<%= model.get('id') %>"></div>
                            <div class="address invisible" data-wsupdate="ip" data-id="<%= model.get('id') %>"><%=model.get('ip')%></div>
                <%
                            break;
                        case 'running':
                %>
                            <div data-i18n data-wsupdate="state-text" data-id="<%= model.get('id') %>">Running</div>
                            <div class="fa fa-play" data-wsupdate="state" data-id="<%= model.get('id') %>"></div>
                            <div class="address" data-wsupdate="ip" data-id="<%= model.get('id') %>"><%=model.get('ip')%></div>
                <%
                            break;
                        case 'starting':
                %>
                            <div data-i18n data-wsupdate="state-text" data-id="<%= model.get('id') %>">Starting</div>
                            <div class="fa fa-spinning fa-spin" data-wsupdate="state" data-id="<%= model.get('id') %>"></div>
                            <div class="address" data-wsupdate="ip" data-id="<%= model.get('id') %>"><%=model.get('ip')%></div>
                <%
                            break;
                        case 'stopping':
                %>
                            <div data-i18n data-wsupdate="state-text" data-id="<%= model.get('id') %>">Stopping</div>
                            <div class="fa fa-spinning fa-spin" data-wsupdate="state" data-id="<%= model.get('id') %>"></div>
                            <div class="address" data-wsupdate="ip" data-id="<%= model.get('id') %>"><%=model.get('ip')%></div>
                <%
                            break;
                    }
                %>
            </div>
        <% } %>
        <div class="remote-administration-buttons invisible">
            <%
                var disabledClass = ' disabled ';
                if (vmState == 'running') {
                    disabledClass = '';
                }
            %>
            <a class="button2 fa fa-external-link <%= disabledClass %>" data-i18n="VNC viewer"></a>
            <a class="button2 fa fa-desktop <%= disabledClass %>" data-i18n="VNC local client"></a>
            <a class="button2 fa fa-terminal <%= disabledClass %>" data-i18n="Telnet viewer"></a>
        </div>
    </div>
    <% if (Wat.C.checkGroupACL('vmRemoteAdminDetails')) { %>
        <table class="details fixed">
        <tbody>
            <% if (Wat.C.checkACL('vm.see.host')) { %>
            <tr>
                <td><span data-i18n="Node"></span></td>
                <td data-wsupdate="host" data-id="<%= model.get('id') %>">
                    <%= Wat.C.ifACL('<a href="#/host/' + model.get('host_id') + '">', 'host.see-details.') %>
                        <%= model.get('host_name') %>
                    <%= Wat.C.ifACL('</a>', 'host.see-details.') %>
                </td>
            </tr>
            <% } %>
            <% if (Wat.C.checkACL('vm.see.next-boot-ip')) { %>
            <tr>
                <td><span data-i18n="Next boot IP"></span></td>
                <td>
                <%
                    if (model.get('next_boot_ip')) {
                        print(model.get('next_boot_ip'));
                    }
                    else if (vmState == 'running') {
                %>
                            <span data-i18n="Current"></span>
                <%
                    }
                    else {
                        print(model.get('ip')); 
                    }
                %>
                </td>
            </tr>
            <% } %>
            <% if (Wat.C.checkACL('vm.see.port-ssh')) { %>
            <tr>
                <td><span data-i18n="SSH port"></span></td>
                <td data-wsupdate="ssh_port" data-id="<%= model.get('id') %>"><%= model.get('ssh_port') == 0 ? '' : model.get('ssh_port') %></td>
            </tr>
            <% } %>
            <% if (Wat.C.checkACL('vm.see.port-vnc')) { %>
            <tr>
                <td><span data-i18n="VNC port"></span></td>
                <td data-wsupdate="vnc_port" data-id="<%= model.get('id') %>"><%= model.get('vnc_port') == 0 ? '' : model.get('vnc_port') %></td>
            </tr>
            <% } %>
            <% if (Wat.C.checkACL('vm.see.port-serial')) { %>
            <tr>
                <td><span data-i18n="Serial port"></span></td>
                <td data-wsupdate="serial_port" data-id="<%= model.get('id') %>"><%= model.get('serial_port') == 0 ? '' : model.get('serial_port') %></td>
            </tr>
            <% } %>
        </tbody>
        </table>
    <% } %>
</div>