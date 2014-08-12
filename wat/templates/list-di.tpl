<table class="list">
    <thead>
        <tr>
            <% 
                _.each(columns, function(col) {
                    if (col.display == false) {
                        return;
                    }
                    
                    switch(col.name) {
                        case 'checks':
            %>
                            <th class="max-1-icons">
                                <input type="checkbox" class="check_all">
                            </th>
            <%
                            break;
                        case 'id':
            %>
                            <th class="cacheable sortable desktop max-2-icons" data-sortby="id" data-i18n="Id">
                                <%= getCached('Id', cache) %>
                            </th>
            <%
                            break;
                        case 'disk_image':
            %>
                            <th class="cacheable sortable" data-sortby="name" data-i18n="Disk image">
                                <%= getCached('Disk image', cache) %>
                            </th>
            <%
                            break;
                        case 'version':
            %>
                            <th class="cacheable desktop sortable" data-sortby="version" data-i18n="Version">
                                <%= getCached('Version', cache) %>
                            </th>
            <%
                            break;
                        case 'osf':
            %>
                            <th class="cacheable desktop sortable" data-sortby="osf_name" data-i18n="OS Flavour">
                                <%= getCached('OS Flavour', cache) %>
                            </th>
            <%
                            break;
                        case 'default':
            %>
                            <th class="cacheable desktop sortable" data-sortby="user_storage" data-i18n="Default">
                                <%= getCached('Default', cache) %>
                            </th>
            <%
                            break;
                        case 'head':
            %>
                            <th class="cacheable desktop sortable" data-sortby="head" data-i18n="Head">
                                <%= getCached('Head', cache) %>
                            </th>
            <%
                            break;
                        default:
                            var translationAttr = 'data-i18n="' + col.name + '"';
                            if (col.noTranslatable === true) {
                                translationAttr = '';
                            }
                    
            %>
                            <th class="cacheable sortable desktop" data-sortby="<%= col.name %>" <%= translationAttr %>>
                                <%= col.name %>
                            </th>
            <%
                            break;
                    }
                });
            %>
        </tr>
    </thead>
    <tbody>
        <% _.each(models, function(model) { %>
            <tr>
                <% 
                    _.each(columns, function(col) {
                        if (col.display == false) {
                            return;
                        }
                    
                        switch(col.name) {
                            case 'checks':
                %>
                                <td>
                                    <input type="checkbox" name="check_<%= model.get('id') %>" class="check-it js-check-it">
                                </td>
                <%
                                break;
                            case 'id':
                %>
                                <td class="desktop">
                                    <%= model.get('id') %>
                                </td>
                <%
                                break;
                            case 'disk_image':
                %>
                                <td>
                                    <a href="#/di/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                        <i class="fa fa-search"></i>
                                        <%= model.get('disk_image') %>
                                    </a>
                                </td>
                <%
                                break;
                            case 'version':
                %>
                                <td class="desktop">
                                    <%= model.get('version') %>
                                </td>
                <%
                                break;
                            case 'osf':
                %>
                                <td class="desktop">
                                    <a href="#/osf/<%= model.get('osf_id') %>">
                                        <%= model.get('osf_name') %>
                                    </a>
                                </td>
                <%
                                break;
                            case 'default':
                %>
                                <td class="desktop">
                                    <%
                                    if (!model.get('default')) {
                                    %>
                                        <span data-i18n="No">
                                            <%= i18n.t('No') %>
                                        </span>
                                    <%
                                    }
                                    else {
                                    %>
                                        <span data-i18n="Yes">
                                            <%= i18n.t('Yes') %>
                                        </span>
                                    <%
                                    }
                                    %>
                                </td>
                <%
                                break;
                            case 'head':
                %>
                                <td class="desktop">
                                    <%
                                    if (!model.get('head')) {
                                    %>
                                        <span data-i18n="No">
                                            <%= i18n.t('No') %>
                                        </span>
                                    <%
                                    }
                                    else {
                                    %>
                                        <span data-i18n="Yes">
                                            <%= i18n.t('Yes') %>
                                        </span>
                                    <%
                                    }
                                    %>
                                </td>
                <%
                                break;
                            default:
                %>
                                <td class="desktop">
                                    <% 
                                        if (model.get(col.name) !== undefined) {
                                            print(model.get(col.name));
                                        }
                                        else if (model.get('properties') !== undefined && model.get('properties')[col.name] !== undefined) {
                                            print(model.get('properties')[col.name]);
                                        }
                                    
                                    %>
                                </td>
                <%
                                break;
                        }
                    });
                %>
            </tr>
        <% }); %>
    </tbody>
</table>