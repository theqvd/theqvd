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
        
        var stateComponents = {
            running: {
                stateText: 'Running',
                stateIcon: '<i class="fa fa-play"></i>',
                style: 'display: none;'
            },
            stopped: {
                stateText: 'Stopped',
                stateIcon: '<i class="fa fa-stop"></i>',
                style: 'display: none;'
            },
            starting: {
                stateText: 'Starting',
                stateIcon: '<i class="fa fa-play faa-flash animated"></i>',
                style: 'display: none;'
            },
            stopping: {
                stateText: 'Stopping',
                stateIcon: '<i class="fa fa-stop faa-flash animated"></i>',
                style: 'display: none;'
            },
        };
        
        stateComponents[model.get('state')].style = '';
        
    %>
    <table class="details-list col-width-100">
        <tbody data-id="<%= model.get('id') %>">
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

            
            <tr>
                <td>
                    <%
                        var nDots = 15;
                        
                        var hostHtml = '';
                        if (Wat.C.checkACL('vm.see.host')) {
                            hostHtml = Wat.C.ifACL('<a href="#/host/' + model.get('host_id') + '">', 'host.see-details.') + model.get('host_name') ? model.get('host_name') : '' + Wat.C.ifACL('</a>', 'host.see-details.');
                        }
                    %>
                    <fieldset style="margin-top: 20px;">
                        <table style="width: auto; margin-top: 30px; margin-bottom: 30px;" class="js-vmst vmst">
                            <tr class="center">
                                <td rowspan=2 colspan=2 class="vmst-vm-cell">
                                    <i class="<%= CLASS_ICON_VMS %> js-vmst-vm vmst-vm" style="font-size: 40px"></i>
                                </td>
                                <% 
                                $.each(stateComponents, function (state, components) {
                                %>
                                    <td colspan=<%= nDots %> class="js-vmst-status vmst-status js-body-state" data-wsupdate="state-<%= state %>" data-id="<%= model.get('id') %>" style="<%= components['style'] %>">
                                        <%= components['stateIcon'] %><span data-i18n="<%= components['stateText'] %>"></span>
                                    </td>
                                <%
                                });
                                %>
                                <td rowspan=2 colspan=2 class="vmst-host-cell">
                                    <i class="<%= CLASS_ICON_HOSTS %> js-vmst-host vmst-host" style="font-size: 40px"></i>
                                </td>
                            </tr>
                            <tr class="center">
                                <% for(i=1; i<=nDots; i++) { %>
                                    <td>
                                        <i class="fa fa-circle-o js-vmst-dot vmst-dot"></i>
                                    </td>
                                <% } %>
                            </tr>
                            <tr class="center">
                                <td colspan=2 class="js-vmst-vm-name vmst-vm-name">
                                    <%= model.get('name') %>
                                </td>                            
                                <td colspan=<%= nDots %>>
                                    <div data-wsupdate="state-running" data-id="<%= model.get('id') %>" style="<%= runningStyle %>">
                                        <%
                                        if (showStateInfo) {
                                        %>
                                            <i class="fa fa-chevron-circle-down vmst-dot vmst-dot-branch"></i>
                                            <i class="fa fa-chevron-circle-down vmst-dot vmst-dot-branch"></i>
                                            <i class="fa fa-chevron-circle-down vmst-dot vmst-dot-branch"></i>
                                        <%
                                        }
                                        %>
                                    </div>
                                </td>
                                <td colspan=2 class="js-vmst-host-name vmst-host-name" data-wsupdate="host" data-id="<%= model.get('id') %>">
                                    <%= hostHtml %>
                                </td>
                            </tr>
                            <tr data-wsupdate="state-running" data-id="<%= model.get('id') %>" style="<%= runningStyle %>">
                                <td colspan=<%= nDots+4 %>>
                                    <table class="details details-list">
                                        <tr class="">
                                            <td colspan=2 class="center">
                                                <span class="h2" data-i18n="Execution parameters"></span>
                                            </td>
                                        </tr>
                                    <%
                                    if (Wat.C.checkACL('vm.see.host')) { 
                                    %>
                                        <tr>
                                            <td><i class="<%= CLASS_ICON_HOSTS %>"></i><span data-i18n="Node"></span></td>
                                            <td data-wsupdate="host" data-id="<%= model.get('id') %>">
                                                <%= hostHtml %>
                                            </td>
                                        </tr>
                                    <%
                                    }
                                    if (Wat.C.checkACL('vm.see.ip')) { 
                                    %>
                                        <tr>
                                            <td><i class="fa fa-ellipsis-h"></i><span data-i18n="IP address"></span></td>
                                            <td class="col-width-100" data-wsupdate="ip" data-id="<%= model.get('id') %>">
                                                <%= model.get('ip_in_use') %>
                                            </td>
                                        </tr>
                                    <%
                                    }
                                    if (Wat.C.checkACL('vm.see.di')) { 
                                    %>
                                        <tr>
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
                                        <tr>
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
                                        <tr>
                                            <td><i class="fa fa-angle-double-right"></i><span data-i18n="SSH port"></span></td>
                                            <td data-wsupdate="ssh_port" data-id="<%= model.get('id') %>"><%= model.get('ssh_port') == "0" ? '-' : model.get('ssh_port') %></td>
                                        </tr>
                                    <% 
                                    }
                                    if (Wat.C.checkACL('vm.see.port-vnc')) { 
                                    %>
                                        <tr>
                                            <td><i class="fa fa-angle-double-right"></i><span data-i18n="VNC port"></span></td>
                                            <td data-wsupdate="vnc_port" data-id="<%= model.get('id') %>"><%= model.get('vnc_port') == "0" ? '-' : model.get('vnc_port') %></td>
                                        </tr>
                                    <% 
                                    }
                                    if (Wat.C.checkACL('vm.see.port-serial')) { 
                                    %>
                                        <tr>
                                            <td><i class="fa fa-angle-double-right"></i><span data-i18n="Serial port"></span></td>
                                            <td data-wsupdate="serial_port" data-id="<%= model.get('id') %>"><%= model.get('serial_port') == "0" ? '-' : model.get('serial_port') %></td>
                                        </tr>
                                    <% 
                                    }
                                    %>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
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