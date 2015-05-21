<div class="side-component">
    <%
        // Show state info fields if is granted any of contained fields. Hide it otherwise
        var showStateInfo = false;

        if (Wat.C.checkGroupACL('vmStateInfoDetails')) {
            showStateInfo = true;
        }
                
        // Show vm status table depend on the returned state
        var runningStyle = 'display: none;';
        var stoppedStyle = 'display: none;';
        var startingStyle = 'display: none;';
        var stoppingStyle = 'display: none;';

        switch (model.get('state')) {
            case 'running':
                var runningStyle = '';
                break;
            case 'stopped':
                var stoppedStyle = '';
                break;
            case 'starting':
                var startingStyle = '';
                break;
            case 'stopping':
                var stoppingStyle = '';
                break;
        }
        
    %>
    <table class="details-list col-width-100">
        <tbody class="js-body-state" data-wsupdate="state-running" data-id="<%= model.get('id') %>" style="<%= runningStyle %>">
            <tr>
                <td colspan=2>
                <span class="h2" data-i18n="Execution state"></span>
                <% 
                if (Wat.C.checkACL('vm.update.state')) {
                    if (model.get('state') != 'stopped') { 
                %>
                        <a class="button fright button-icon js-button-stop-vm fa fa-stop fright" href="javascript:" data-i18n="[title]Stop" data-wsupdate="state-button" data-id="<%= model.get('id') %>"></a>
                        <!--<a style="margin-right: 6px;" class="button fright button-icon js-button-restart-vm fa fa-refresh fright" href="javascript:" data-i18n="[title]Restart" data-wsupdate="state-button-restart" data-id="<%= model.get('id') %>"></a>-->
                <% 
                    }
                    else { 
                %>
                        <a class="button fright button-icon js-button-start-vm fa fa-play fright" href="javascript:" data-i18n="[title]Start" data-wsupdate="state-button" data-id="<%= model.get('id') %>"></a>
                <% 
                    }
                } 
                %>
                </td>
            </tr>
            <%
            if (Wat.C.checkACL('vm.see.host')) {
                var hostHtml = Wat.C.ifACL('<a href="#/host/' + model.get('host_id') + '">', 'host.see-details.') + model.get('host_name') + Wat.C.ifACL('</a>', 'host.see-details.');
            %>
                <tr>
                    <td colspan=2 class="center padded" data-wsupdate="host" data-id="<%= model.get('id') %>"><%= i18n.t('Running at __node__', {'node': hostHtml}) %></td>
                </tr>
            <%
            }
            else { 
            %>
                <tr>
                    <td colspan=2 class="center padded"><span data-i18n="Running"></span></td>
                </tr>
            <%
            }
            if (showStateInfo) {
            %>
                <tr class="js-execution-params-button-row">
                    <td colspan=2 class="padded"><a class="fa fa-eye button2 col-width-100 center js-execution-params-button" href="javascript:" data-i18n="See execution parameters"></a></td>
                </tr>
            <%
            }
            %>
                <tr class="js-execution-params execution-params"><td colspan=2 class="padded">
                <table class="details details-list">
                <tr class="js-execution-params execution-params">
                    <td colspan=2>
                        <span class="h2" data-i18n="Execution parameters"></span>
                    </td>
                </tr>
            <%
            if (Wat.C.checkACL('vm.see.host')) { 
            %>
                <tr class="js-execution-params execution-params">
                    <td><i class="<%= CLASS_ICON_HOSTS %>"></i><span data-i18n="Node"></span></td>
                    <td data-wsupdate="host" data-id="<%= model.get('id') %>">
                        <%= hostHtml %>
                    </td>
                </tr>
            <%
            }
            if (Wat.C.checkACL('vm.see.ip')) { 
            %>
                <tr class="js-execution-params execution-params">
                    <td><i class="fa fa-ellipsis-h"></i><span data-i18n="IP address"></span></td>
                    <td class="col-width-100" data-wsupdate="ip" data-id="<%= model.get('id') %>">
                        <%= model.get('ip') %>
                    </td>
                </tr>
            <%
            }
            if (Wat.C.checkACL('vm.see.di')) { 
            %>
                <tr class="js-execution-params execution-params">
                    <td><i class="<%= CLASS_ICON_DIS %>"></i><span data-i18n="Disk image"></span></td>
                    <td>
                        <span data-wsupdate="di" data-id="<%= model.get('id') %>">
                            <a href="#/di/<%= model.get('di_id_in_use') %>">
                                <%= model.get('di_name_in_use') %>
                            </a>
                        </span>
                        <div class="second_row">
                            <span data-i18n="Version"></span>: <span data-wsupdate="di_version" data-id="<%= model.get('id') %>"><%= model.get('di_version_in_use') %></span>
                        </span>
                    </td>
                </tr>
            <% 
            }
            if (Wat.C.checkACL('vm.see.user-state')) { 
            %>
                <tr class="js-execution-params execution-params">
                    <td><i class="fa fa-plug"></i><span data-i18n="User state"></span></td>
                    <td>
                        <% 
                        if (model.get('user_state') == 'connected') {
                        %>
                            <span data-i18n data-wsupdate="user_state-text" data-id="<%= model.get('id') %>">Connected</span>
                        <%
                        }
                        else {
                        %>
                            <span data-i18n data-wsupdate="user_state-text" data-id="<%= model.get('id') %>">Disconnected</span>
                        <%
                        }
                        %>
                    </td>
                </tr>
            <% 
            }
            if (Wat.C.checkACL('vm.see.port-ssh')) { 
            %>
                <tr class="js-execution-params execution-params">
                    <td><i class="fa fa-angle-double-right"></i><span data-i18n="SSH port"></span></td>
                    <td data-wsupdate="ssh_port" data-id="<%= model.get('id') %>"><%= model.get('ssh_port') == "0" ? '-' : model.get('ssh_port') %></td>
                </tr>
            <% 
            }
            if (Wat.C.checkACL('vm.see.port-vnc')) { 
            %>
                <tr class="js-execution-params execution-params">
                    <td><i class="fa fa-angle-double-right"></i><span data-i18n="VNC port"></span></td>
                    <td data-wsupdate="vnc_port" data-id="<%= model.get('id') %>"><%= model.get('vnc_port') == "0" ? '-' : model.get('vnc_port') %></td>
                </tr>
            <% 
            }
            if (Wat.C.checkACL('vm.see.port-serial')) { 
            %>
                <tr class="js-execution-params execution-params">
                    <td><i class="fa fa-angle-double-right"></i><span data-i18n="Serial port"></span></td>
                    <td data-wsupdate="serial_port" data-id="<%= model.get('id') %>"><%= model.get('serial_port') == "0" ? '-' : model.get('serial_port') %></td>
                </tr>
            <% 
            }
            %>
            </table></td></tr>
        </tbody>
        <tbody class="js-body-state" data-wsupdate="state-stopped" data-id="<%= model.get('id') %>" style="<%= stoppedStyle %>">
            <tr>
                <td colspan=2>
                    <span class="h2" data-i18n="Execution state"></span>
                    <% 
                    if (Wat.C.checkACL('vm.update.state')) {
                        if (model.get('state') != 'stopped') { 
                    %>
                            <a class="button fright button-icon js-button-stop-vm fa fa-stop fright" href="javascript:" data-i18n="[title]Stop" data-wsupdate="state-button" data-id="<%= model.get('id') %>"></a>
                    <% 
                        }
                        else { 
                    %>
                            <a class="button fright button-icon js-button-start-vm fa fa-play fright" href="javascript:" data-i18n="[title]Start" data-wsupdate="state-button" data-id="<%= model.get('id') %>"></a>
                    <% 
                        }
                    } 
                    %>
                </td>
            </tr>
            <tr>
                <td colspan=2 class="center"><span data-i18n="Stopped"></span></td>
            </tr>
        </tbody>
        <tbody class="js-body-state" data-wsupdate="state-starting" data-id="<%= model.get('id') %>" style="<%= startingStyle %>">
            <tr>
                <td colspan=2><span class="h1" data-i18n="Execution state"></span></td>
            </tr>
            <tr>
                <td colspan=2 class="center"><i class="fa fa-spinner fa-spin"></i><span data-i18n="Starting"></span></td>
            </tr>
        </tbody>
        <tbody class="js-body-state" data-wsupdate="state-stopping" data-id="<%= model.get('id') %>" style="<%= stoppingStyle %>">
            <tr>
                <td colspan=2><span class="h1" data-i18n="Execution state"></span></td>
            </tr>
            <tr>
                <td colspan=2 class="center"><i class="fa fa-spinner fa-spin"></i><span data-i18n="Stopping"></span></td>
            </tr>
        </tbody>
    </table>
</div>

<div class="side-component js-side-component2">
    <div class="side-header">
        <span class="h2" data-i18n="Log"></span>
        <% if (Wat.C.checkACL('log.see-main.')) { %>
        <a class="button2 button-right fa fa-arrows-h" href="#/logs/<%= Wat.U.transformFiltersToSearchHash({qvd_object: Wat.CurrentView.qvdObj, object_id: model.get('id')}) %>" data-i18n="Extended view"></a>
        <% } %>
    </div>
    <div class="bb-details-side2">
        <div class="mini-loading"><i class="fa fa-gear fa-spin"></i></div>
    </div>
    
    <div id="graph-log" style="width:95%;height:200px;">
        <div class="mini-loading" style="padding-top: 70px;"><i class="fa fa-bar-chart-o fa-spin"></i></div>
    </div>
</div>