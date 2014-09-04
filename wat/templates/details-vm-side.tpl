<div class="side-component">
    <div class="side-header">
        <span class="h2" data-i18n>Remote administration</span>
    </div>

    <div class="remote-administration-wrapper">
        <div class="remote-administration-state">
            <% 
                var vmState = model.get('state');
                switch(vmState) {
                    case 'stopped':
            %>
                        <div class="error" data-i18n>Stopped</div>
                        <div class="fa fa-pause icon-pause"></div>
                        <div class="address invisible"><%=model.get('ip')%></div>
            <%
                        break;
                    case 'running':
            %>
                        <div class="ok" data-i18n>Running</div>
                        <div class="fa fa-play icon-play"></div>
                        <div class="address"><%=model.get('ip')%></div>
            <%
                        break;
                }
            %>
        </div>
        <div class="remote-administration-buttons">
            <%
                var disabledClass = ' disabled ';
                if (vmState == 'running') {
                    disabledClass = '';
                }
            %>
            <a class="button2 fa fa-external-link <%= disabledClass %>" data-i18n>VNC viewer</a>
            <a class="button2 fa fa-desktop <%= disabledClass %>" data-i18n>VNC local client</a>
            <a class="button2 fa fa-terminal <%= disabledClass %>" data-i18n>Telnet viewer</a>
        </div>
    </div>

    <table class="details fixed">
    <tbody>
        <tr>
            <td><span data-i18n>Node</span></td>
            <td>
                <a href="#/host/<%= model.get('host_id') %>">
                    <%= model.get('host_name') %>
                </a>
            </td>
        </tr>
        <tr>
            <td><span data-i18n>Next boot IP</span></td>
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
        <tr>
            <td><span data-i18n>SSH port</span></td>
            <td><%= model.get('ssh_port') %></td>
        </tr>
        <tr>
            <td><span data-i18n>VNC port</span></td>
            <td><%= model.get('vnc_port') %></td>
        </tr>
        <tr>
            <td><span data-i18n>Serial port</span></td>
            <td><%= model.get('serial_port') %></td>
        </tr>
    </tbody>
    </table>
</div>