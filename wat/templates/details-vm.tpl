<div class="details-header">
    <span class="fa fa-cloud h1"><%= model.get('name') %></span>
    <% if(Wat.C.checkACL('vm_update')) { %>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
    <% } %>
</div>

<table class="details details-list">
    <tr>
        <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>  
    <tr>
        <td><i class="fa fa-heart"></i><span data-i18n>State</span></td>
        <td>
            <% 
            if (model.get('state') == 'running') {
            %>
                <i class="fa fa-play ok" data-i18n="[title]Running"></i>
            <%
            }
            else {
            %>
                <i class="fa fa-pause error" data-i18n="[title]Stopped"></i>
            <%
            }
            %>
        </td>
    </tr>
    <tr>
        <td><i class="<%= CLASS_ICON_USERS %>"></i><span data-i18n>User</span></td>
        <td>
            <a href="#/user/<%= model.get('user_id') %>">
                <%= model.get('user_name') %>
            </a>
        </td>
    </tr>    
    <tr>
        <td><i class="fa fa-plug"></i><span data-i18n>User state</span></td>
        <td>
            <% 
            if (model.get('user_state') == 'connected') {
            %>
                <i class="fa fa-user ok" data-i18n="[title]Connected"></i>
            <%
            }
            else {
            %>                
                <i class="fa fa-user error" data-i18n="[title]Disconnected"></i>
            <%
            }
            %>
        </td>
    </tr>
    <tr>
        <td><i class="<%= CLASS_ICON_OSFS %>"></i><span data-i18n>OS Flavour</span></td>
        <td>
            <a href="#/osf/<%= model.get('osf_id') %>">
                <%= model.get('osf_name') %>
            </a>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-tag"></i><span data-i18n>Image tag</span></td>
        <td>
            <%= model.get('di_tag') %>
        </td>
    </tr>
    <tr>
        <td><i class="<%= CLASS_ICON_DIS %>"></i><span data-i18n>Disk image</span></td>
        <td>
            <a href="#/di/<%= model.get('di_id') %>">
                <%= model.get('di_name') %>
            </a>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-warning"></i><span data-i18n>Expiration</span></td>
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
                                    <td class="warning" data-i18n>Soft</td>
                                    <td class="warning"><%= model.get('expiration_soft').replace('T',' ') %></td>
                                    <td class="warning"><i class="fa fa-info-circle fa-centered"></i></td>
                                </tr>
                            <%
                                }
                                if (expiration_hard) {
                            %>
                                <tr>
                                    <td class="ok" data-i18n>Hard</td>
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
    <tr>
        <td><i class="fa fa-lock"></i><span data-i18n>Blocking</span></td>
        <td>
            <% 
            if (model.get('blocked')) {
            %>
                <i class="fa fa-lock" data-i18n="[title]Blocked"></i>
            <%
            }
            else {
            %>
                <i class="fa fa-unlock" data-i18n="[title]Unblocked"></i>
            <%
            }
            %>
        </td>
    </tr>
</table>