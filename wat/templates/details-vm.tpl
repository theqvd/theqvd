<div class="details-header">
    <span class="fa fa-cloud h1"><%= model.get('name') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
</div>

<table class="details details-list">
    <tr>
        <td data-i18n>Id</td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>    
    <tr>
        <td data-i18n>User</td>
        <td>
            <a href="#/user/<%= model.get('user_id') %>">
                <%= model.get('user_name') %>
            </a>
        </td>
    </tr>
    <tr>
        <td data-i18n>OS Flavour</td>
        <td>
            <a href="#/osf/<%= model.get('osf_id') %>">
                <%= model.get('osf_name') %>
            </a>
        </td>
    </tr>
    <tr>
        <td data-i18n>Disk image's tag</td>
        <td>
            <%= model.get('di_tag') %>
        </td>
    </tr>
    <tr>
        <td data-i18n>Disk image</td>
        <td>
            <a href="#/di/<%= model.get('di_id') %>">
                <%= model.get('di_name') %>
            </a>
        </td>
    </tr>
    <tr>
        <td data-i18n>Expiration</td>
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
                            <tr>
                                <td class="warning" data-i18n>Soft</td>
                                <td class="warning"><%= model.get('expiration_soft') %></td>
                                <td class="warning"><i class="fa fa-warning fa-centered"></i></td>
                            </tr>
                            <tr>
                                <td class="ok" data-i18n>Hard</td>
                                <td class="ok"><%= model.get('expiration_hard') %></td>
                                <td class="ok"><i class="fa fa-info-circle fa-centered"></td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            <%
                }
            %>
    </tr>
    <tr>
        <td data-i18n>Blocking</td>
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