<div class="details-header">
    <span class="fa fa-dot-circle-o h1"><%= model.get('disk_image') %></span>
    <% if(Wat.C.checkACL('di.delete.')) { %>
    <a class="button fleft button-icon js-button-delete fa fa-trash" href="javascript:" data-i18n="[title]Delete"></a>
    <% } %>
    <% if(Wat.C.checkGroupACL('diEdit')) { %>
    <a class="button fright button-icon js-button-edit fa fa-pencil" href="javascript:" data-i18n="[title]Edit"></a>
    <% } %>
    
    <% 
    if (Wat.C.checkACL('di.update.block')) {
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
    
    <% if(Wat.C.checkACL('di.update.default') && !model.get('default')) { %>
    <a class="button fright button-icon js-button-default fa fa-home" href="javascript:" data-i18n="[title]Set by default"></a>
    <% } %>
    
</div>

<table class="details details-list <% if (!enabledProperties) { %> col-width-100 <% } %>">
    <%   
    if (Wat.C.checkACL('di.see.description')) { 
    %>
        <tr>
            <td><i class="fa fa-align-justify"></i><span data-i18n="Description"></span></td>
            <td>
                <% 
                if (model.get('description')) { 
                %>
                    <%= model.get('description').replace(/\n/g, '<br>') %>
                <%
                }
                else {
                %>
                    <span class="second_row">-</span>
                <%
                }
                %>
            </td>
        </tr>
    <% 
    }
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
    if (detailsFields['version'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-ticket"></i><span data-i18n="Version"></span></td>
            <td>
                <%= model.get('version') %>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['osf'] != undefined) { 
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_OSFS %>"></i><span data-i18n="OS Flavour"></span></td>
            <td>
                <%= Wat.C.ifACL('<a href="#/osf/' + model.get('osf_id') + '" data-i18n="[title]Click for details">', 'osf.see-details.') %>
                    <%= model.get('osf_name') %>
                <%= Wat.C.ifACL('</a>', 'osf.see-details.') %>
            </td>
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
                    <span data-i18n="Blocked"></span>
                <%
                }
                else {
                %>
                    <span data-i18n="Unblocked"></span>
                <%
                }
                %>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['default'] != undefined && model.get('default')) { 
    %>
        <tr>
            <td><i class="fa fa-home"></i><span data-i18n="Default"></span></td>
            <td>
                <div class="second_row" data-i18n="Default image for this OSF"></div>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['head'] != undefined && model.get('head')) { 
    %>
        <tr> 
            <td><i class="fa fa-flag-o"></i><span data-i18n="Head"></span></td>
            <td>
                <div class="second_row" data-i18n="Last image created on this OSF"></div>
            </td>
        </tr>
    <% 
    }
    if (detailsFields['tags'] != undefined) { 
    %>
        <tr>
            <td><i class="fa fa-tags"></i><span data-i18n="Tags"></span></td>
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
    <% 
    }
    if (Wat.C.checkACL('di.see.created-by')) {
    %>
        <tr>
            <td><i class="<%= CLASS_ICON_ADMINS %>"></i><span data-i18n="Created by"></span></td>
            <td>
                <span><%= model.get('creation_admin_name') %></span>
            </td>
        </tr>
    <% 
    }
    if (Wat.C.checkACL('di.see.creation-date')) {
    %>
        <tr>
            <td><i class="fa fa-clock-o"></i><span data-i18n="Creation date"></span></td>
            <td>
                <span><%= model.get('creation_date') %></span>
            </td>
        </tr>
    <% 
    }
    %>
    <tbody class="bb-properties"></tbody>
</table>