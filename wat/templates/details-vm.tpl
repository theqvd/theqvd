<div class="details-header">
    <span class="fa fa-cloud h1"><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('vm.delete.')) { %>
    <a class="button fleft button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"></a>
    <% } %>
    
    <% if(Wat.C.checkGroupACL('vmEdit')) { %>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"></a>
    <% } %>
    
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
    
    <% 
    if (Wat.C.checkACL('vm.update.block')) {
        if(model.get('blocked')) {
    %>
            <a class="button button-icon js-button-unblock fa fa-unlock fright" href="javascript:" data-i18n="[title]Unblock"></a>
    <%
        } 
        else { 
    %>
            <a class="button button-icon js-button-block fa fa-lock fright" href="javascript:" data-i18n="[title]Block"></a>
    <%
        }
    }
    %>
    
    <% 
    if (Wat.C.checkACL('vm.update.disconnect-user') && model.get('user_state') == 'connected') {
    %>
        <a class="button button-icon js-button-disconnect-user fa fa-plug fright" href="javascript:" data-i18n="[title]Disconnect user"></a>
    <%
    }
    %>  
    
</div>

<table class="details details-list <% if (!enabledProperties) { %> col-width-100 <% } %>">
    <% 
    if (detailsFields['id'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-male"></i><span data-i18n="Id"></span></td>
            <td>
                <%= model.get('id') %>
            </td>
        </tr>  
    <% 
    }
    if (detailsFields['state'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-heart"></i><span data-i18n="State"></span></td>
            <td>
                <% 
                if (model.get('state') == 'running') {
                %>
                    <span data-i18n data-wsupdate="state-text" data-id="<%= model.get('id') %>">Running</span>
                <%
                }
                else {
                %>
                    <span data-i18n data-wsupdate="state-text" data-id="<%= model.get('id') %>">Stopped</span>
                <%
                }
                %>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['ip'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-ellipsis-h"></i><span data-i18n="IP address"></span></td>
            <td>
                <%= model.get('ip') %>
            </td>
        </tr>  
    <% 
    }
    if (detailsFields['mac'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-ellipsis-h"></i><span data-i18n="MAC address"></span></td>
            <td>
                <%= model.get('mac') %>
            </td>
        </tr>  
    <% 
    }
    if (detailsFields['user'] != undefined) { 
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_USERS %>"></i><span data-i18n="User"></span></td>
            <td>
                <a href="#/user/<%= model.get('user_id') %>">
                    <%= model.get('user_name') %>
                </a>
            </td>
        </tr>  
    <% 
    }
    if (detailsFields['user_state'] != undefined) { 
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
    if (detailsFields['osf'] != undefined) { 
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_OSFS %>"></i><span data-i18n="OS Flavour"></span></td>
            <td>
                <a href="#/osf/<%= model.get('osf_id') %>">
                    <%= model.get('osf_name') %>
                </a>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['tag'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-tag"></i><span data-i18n="Image tag"></span></td>
            <td>
                <%= model.get('di_tag') %>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['disk_image'] != undefined) { 
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_DIS %>"></i><span data-i18n="Disk image"></span></td>
            <td>
                <a href="#/di/<%= model.get('di_id') %>">
                    <%= model.get('di_name') %>
                </a>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['expiration'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-warning"></i><span data-i18n="Expiration"></span></td>
                <%
                    var expiration_soft = model.get('expiration_soft');
                    var expiration_hard = model.get('expiration_hard');
                    if (!expiration_soft && !expiration_hard) {
                %>
                    <td>
                        <div class="no-elements" data-i18n="No"></div>
                    </td>
                <%
                    }
                    else {
                %>        
                    <td class="inner-table">
                        <table class="expiration-table">
                            <tbody>
                                <%
                                    if (expiration_soft) {
                                %>
                                    <tr>
                                        <td class="warning" data-i18n="Soft"></td>
                                        <td class="warning"><%= model.get('expiration_soft').replace('T',' ') %></td>
                                        <td class="warning"><i class="fa fa-info-circle fa-centered"></i></td>
                                    </tr>
                                <%
                                    }
                                    if (expiration_hard) {
                                %>
                                    <tr>
                                        <td class="ok" data-i18n="Hard"></td>
                                        <td class="ok"><%= model.get('expiration_hard').replace('T',' ') %></td>
                                        <td class="ok"><i class="fa fa-info-circle fa-centered"></td>
                                    </tr>
                                <%
                                    }
                                %>
                        </table>
                    </td>
                <%
                    }
                %>
        </tr>
    <% 
    }
    if (detailsFields['block'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-lock"></i><span data-i18n="Blocking"></span></td>
            <td>
                <% 
                if (model.get('blocked')) {
                %>
                    <!--
                    <i class="fa fa-lock" data-i18n="[title]Blocked"></i>
                    -->
                    <span data-i18n="Blocked"></span>
                <%
                }
                else {
                %>
                    <!--
                    <i class="fa fa-unlock" data-i18n="[title]Unblocked"></i>
                    -->
                    <span data-i18n="Unblocked"></span>
                <%
                }
                %>
            </td>
        </tr>
    <% 
    }
    %>
</table>