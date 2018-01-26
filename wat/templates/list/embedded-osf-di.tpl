<table class="list <%= cid %>">
    <thead>
        <tr>
            <th class="col-width-1 cell-check">
                <input type="checkbox" class="check_all" data-check-id="<%= osfId %>" data-embedded-view="di">
            </th>
            <th colspan=4>
                <% if (enabledCreation && Wat.C.checkACL('di.create.')) { %>
                    <a class="js-traductable_button js-button-new actions_button button fa fa-plus-circle" data-qvd-obj="di" name="new_di_button" href="javascript:" data-i18n="New Disk image" data-osf-id="<%= osfId %>"></a>
                <% } %>
            </th>
        </tr>
    </thead>
    <tbody>
    <%
    if (models.length == 0) {
    %>
        <tr style="display:block;">
            <td colspan=5 class="center" style="display:block;">
                <span class="no-elements" data-i18n="There are no elements">
                    <%= i18n.t('There are no elements') %>
                </span>
            </td>
        </tr>
    <%
    }
    $.each(models, function (iModel, model) {
            if (shrinkFactor == iModel) {
                %>
                    <tr class="js-rows-unshrink-row rows-unshrink-row">
                        <td colspan="4">
                            <a class="button2 fa fa-chevron-down col-width-100 center js-unshrink-btn" data-i18n="See all"></a>
                        </td>
                    </tr>
                <%
            }
            var cleanName = model.get('disk_image').substr(model.get('disk_image').indexOf('-')+1);
    %>
    
        <tr class="js-di-row-state di-row-state di-row-state--<%= model.get('state') %> <%= shrinkFactor <= iModel ? 'hidden' : '' %> js-shrinked-row" data-id="<%= model.get('id') %>" data-osf-id="<%= model.get('osf_id') %>" data-name="<%= cleanName %>">
            <td class="cell-check">
                <input type="checkbox" 
                    class="check-it js-check-it" 
                    data-options-kind="select"
                    data-check-id="<%= osfId %>"
                    data-id="<%= model.get('id') %>" 
                    data-embedded-view="di"
                >
            </td>
            <td class="desktop max-1-icons bb-di-info" data-id="<%= model.get('id') %>"></td>
            <td class="col-width-40">
                <%= model.get('version') %>
                <% if (model.get('state') != 'generating' && model.get('state') != 'new') { %>
                <div class="second_row">
                    <span class="fa fa-database">
                        <%= model.get('disk_image') %>
                    </span>
                </div>
            <%
                }
                if (model.get('description')) {
                    switch(model.get('state')) {
                        case 'new':
                        case 'generating':
                        case 'uploading':
            %>
                            <div class="second_row">
                                <span class="fa fa-file-text-o">
                                    <%= model.get('description') %>
                                </span>
                            </div>
            <%
                            break;
                    }
                }
            %>
            </td>
            <td class="description">
            <%
                if (model.get('description')) {
                    switch(model.get('state')) {
                        case 'new':
                        case 'generating':
                        case 'uploading':
                            break;
                        default:
            %>
                            <div class="second_row">
                                <span class="fa fa-file-text-o">
                                    <%= model.get('description') %>
                                </span>
                            </div>
            <%
                            break;
                    }
                }
                %>
                <div class="bb-di-progress" data-id="<%= model.get('id') %>"></div>
            </td>
        </tr>
    <% }); %>
    </tbody>
</table>
