<div class="details-header">
    <span class="fa fa-dot-circle-o h1" data-i18n><%= model.get('disk_image') %></span>
    <% if(Wat.C.checkACL('di_delete')) { %>
    <a class="button fleft button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"></a>
    <% } %>
    <% if(Wat.C.checkACL('di_update')) { %>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"></a>
    <% } %>
    
    <% 
    if (Wat.C.checkACL('di_update')) {
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
</div>

<table class="details details-list">
    <tr>
        <td><i class="fa fa-male"></i><span data-i18n>Id</span></td>
        <td>
            <%= model.get('id') %>
        </td>
    </tr>
    <tr>
        <td><i class="fa fa-ticket"></i><span data-i18n>Version</span></td>
        <td>
            <%= model.get('version') %>
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
        <td><i class="fa fa-lock"></i><span data-i18n>Blocking</span></td>
        <td>
            <% 
            if (model.get('blocked')) {
            %>
                <span data-i18n>Blocked</span>
            <%
            }
            else {
            %>
                <span data-i18n>Unblocked</span>
            <%
            }
            %>
        </td>
    </tr>
    
    <%
        if (model.get('default')) {
    %>
            <tr>
                <td><i class="fa fa-home"></i><span data-i18n>Default</span></td>
                <td>
                    <div class="second_row" data-i18n="Default image for this OSF"></div>
                </td>
            </tr>
    
    <%
        }
    %>
            
    <%
        if (model.get('head')) {
    %>
           <tr> 
                <td><i class="fa fa-flag-o"></i><span data-i18n>Head</span></td>
                <td>
                    <div class="second_row" data-i18n="Last image created on this OSF"></div>
                </td>
            </tr>
    
    <%
        }
    %>
    
    <tr>
        <td><i class="fa fa-tags"></i><span data-i18n>Tags</span></td>
        <td>
        <%
            if (!model.get('tags')) {
        %>
                <span class="no-elements" data-i18n="There are not tags"></span>
        <%
            }
        %>
            <ul class="tags">
                <%
                if (model.get('tags')) {
                    $(model.get('tags').split(',')).each( function (index, tag) {
                %>
                        <li class="fa fa-tag"><%= tag %></li>
                <%
                    });
                }
                %>
            </ul>
        </td>
    </tr>
</table>