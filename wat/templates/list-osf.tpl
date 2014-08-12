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
                        case 'name':
            %>
                            <th class="cacheable sortable" data-sortby="name" data-i18n="Name">
                                <%= getCached('Name', cache) %>
                            </th>
            <%
                            break;
                        case 'overlay':
            %>
                            <th class="cacheable desktop sortable" data-sortby="overlay" data-i18n="Overlay">
                                <%= getCached('Overlay', cache) %>
                            </th>
            <%
                            break;
                        case 'memory':
            %>
                            <th class="cacheable desktop sortable" data-sortby="memory" data-i18n="Memory">
                                <%= getCached('Memory', cache) %>
                            </th>
            <%
                            break;
                        case 'user_storage':
            %>
                            <th class="cacheable desktop sortable" data-sortby="user_storage" data-i18n="User storage">
                                <%= getCached('User storage', cache) %>
                            </th>
            <%
                            break;
                        case '#dis':
            %>
                            <th class="cacheable desktop sortable" data-sortby="#dis" data-i18n="Disk images">
                                <%= getCached('Disk images', cache) %>
                            </th>
            <%
                            break;
                        case '#vms':
            %>
                            <th class="cacheable desktop sortable" data-sortby="#vms" data-i18n="Virtual machines">
                                <%= getCached('Virtual machines', cache) %>
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
                            case 'name':
                %>
                                <td>
                                    <a href="#/osf/<%= model.get('id') %>" data-i18n="[title]Click for details">
                                        <i class="fa fa-search"></i>
                                        <%= model.get('name') %>
                                    </a>
                                </td>
                <%
                                break;
                            case 'overlay':
                %>
                                <td class="desktop">
                                    <%= model.get('overlay') %>
                                </td>
                <%
                                break;
                            case 'memory':
                %>
                                <td class="desktop">
                                    <%= model.get('memory') %> MB
                                </td>
                <%
                                break;
                            case 'user_storage':
                %>
                                <td class="desktop">
                                    <%
                                    if (!model.get('user_storage')) {
                                    %>
                                        <span data-i18n="No">
                                            <%= i18n.t('No') %>
                                        </span>
                                    <%
                                    }
                                    else {
                                        print(model.get('user_storage')  + " MB");
                                    }
                                    %>
                                </td>
                <%
                                break;
                            case '#dis':
                %>
                                <td class="desktop">
                                    <%= model.get('#dis') %>
                                </td>
                <%
                                break;
                            case '#vms':
                %>
                                <td class="desktop">
                                    <%= model.get('#vms') %>
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