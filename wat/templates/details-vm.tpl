<div class="details-header">
    <span class="fa fa-cloud h1"><%= model.get('name') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
</div>

<div class="details-list">
    <span class="details-item fa fa-angle-right">
        <span data-i18n>Id</span>
        <div class="indented-data">
            <%= model.get('id') %>
        </div>
    </span>    
    <span class="details-item fa fa-angle-right">
        <span data-i18n>User</span>
        <div class="indented-data">
            <a href="#/user/<%= model.get('user_id') %>">
                <%= model.get('user_name') %>
            </a>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <span data-i18n>OS Flavour</span>
        <div class="indented-data">
            <a href="#/osf/<%= model.get('osf_id') %>">
                <%= model.get('osf_name') %>
            </a>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <span data-i18n>Disk image's tag</span>
        <div class="indented-data">
            <%= model.get('di_tag') %>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <span data-i18n>Disk image</span>
        <div class="indented-data">
            <div>
                <a href="#/di/<%= model.get('di_id') %>">
                    <%= model.get('di_name') %>
                </a>
            </div>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <span data-i18n>Expiration</span>
        <div class="indented-data">
            <%
                var expiration_soft = model.get('expiration_soft');
                var expiration_hard = model.get('expiration_hard');
                if (!expiration_soft && !expiration_hard) {
            %>
                    <span class="no-elements" data-i18n="No"></span>
            <%
                }
                else {
            %>
                    <table class="expiration-table list">
                        <tbody>
                            <tr>
                                <td class="warning"><span data-i18n>Soft</span></td>
                                <td class="warning"><%= model.get('expiration_soft') %></td>
                                <td class="warning"><i class="fa fa-warning fa-centered"></i></td>
                            </tr>
                            <tr>
                                <td class="ok"><span data-i18n>Hard</span></td>
                                <td class="ok"><%= model.get('expiration_hard') %></td>
                                <td class="ok"><i class="fa fa-info-circle fa-centered"></td>
                            </tr>
                        </tbody>
                    </table>
            <%
                }
            %>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <% 
        if (model.get('blocked')) {
        %>
            <i class="fa fa-lock" data-i18n>Blocked</i>
        <%
        }
        else {
        %>
            <i class="fa fa-unlock" data-i18n>Unblocked</i>
        <%
        }
        %>
    </span>
</div>