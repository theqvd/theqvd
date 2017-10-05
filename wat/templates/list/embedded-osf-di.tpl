<table class="list <%= cid %>">
    <thead>
        <tr>
            <th class="col-width-1 cell-check">
                <input type="checkbox" class="check_all" data-check-id="<%= osfId %>" data-embedded-view="di">
            </th>
            <th colspan=4>
                <a class="js-traductable_button js-button-new actions_button button fa fa-plus-circle" data-qvd-obj="di" name="new_di_button" href="javascript:" data-i18n="New Disk image" data-osf-id="<%= osfId %>"></a>
            </th>
        </tr>
    </thead>
    <tbody>
    <% $.each(models, function (iModel, model) {
            var state = Wat.C.getDIStatus(model.get('id'));
            if (shrinkFactor == iModel) {
                %>
                    <tr class="js-rows-unshrink-row rows-unshrink-row">
                        <td colspan="4">
                            <a class="button2 fa fa-chevron-down col-width-100 center js-unshrink-btn">See all disk images</a>
                        </td>
                    </tr>
                <%
            }
            
    %>
        <tr class="di-row-state-<%= state %> <%= shrinkFactor <= iModel ? 'hidden' : '' %> js-shrinked-row">
            <td class="cell-check">
                <input type="checkbox" 
                    class="check-it js-check-it" 
                    data-options-kind="select"
                    data-check-id="<%= osfId %>"
                    data-id="<%= model.get('id') %>" 
                    data-embedded-view="di"
                >
            </td>
            <td class="desktop max-1-icons">
                <% 
                switch (state) { 
                    case 'creating':
                        %>
                            <i class="fa fa-magic faa-wrench animated" title="Being created"></i>
                        <%
                        break;
                    case 'scheduled':
                        %>
                            <i class="fa fa-calendar" title="Scheduled: 2 days"></i>
                        <%
                        break;
                    case 'published':
                        %>
                            <i class="fa fa-check" title="Published"></i>
                        <%
                        break;
                }

                if (model.get('tags')) {
                %>
                    <i class="fa fa-tags" title="&raquo; <%= model.get('tags').replace(/,/g,'<br /><br />&raquo; ') %>"></i>
                <%
                }

                if (model.get('head')) {
                %>
                    <i class="fa fa-flag-o" title="head"></i>
                <%
                }

                if (model.get('default')) {
                %>
                    <i class="fa fa-home" title="default"></i>
                <%
                }

                if (model.get('blocked')) {
                %>
                    <i class="fa fa-lock" data-i18n="[title]Blocked" title="<%= i18n.t('Blocked') %>"></i>
                <%
                }
                %>
            </td>
            <td>
                <%= model.get('version') %>
                <% if (state != 'creating') { %>
                <div class="second_row">
                    <span class="fa fa-database">
                        <%= model.get('disk_image') %>
                    </span>
                </div>
                <% } %>
            </td>
            <td class="description"><% 
                switch (state) { 
                    case 'creating':
                        %>
                            <div class="second_row">The disk image is being created</div>
                        <%
                        break;
                    case 'scheduled':
                        %>
                            <div class="second_row">The disk image is not public yet.</div>
                            <div class="second_row">It will be published and ready to use at:</div>
                            <div class="second_row"><%= (new Date()).toISOString().substring(0, 16).replace('T',' ') %> (In 03:04:32)</div>
                        <%
                        break;
                } 
                %>
                <div class="second_row"><%= model.get('description') %></div>
            </td>
        </tr>
    <% }); %>
    </tbody>
</table>