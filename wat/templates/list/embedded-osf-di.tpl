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
        <tr class="js-di-row-state di-row-state di-row-state--<%= model.get('state') %> <%= shrinkFactor <= iModel ? 'hidden' : '' %> js-shrinked-row" data-id="<%= model.get('id') %>" data-osf-id="<%= model.get('osf_id') %>">
            <td class="cell-check">
                <input type="checkbox" 
                    class="check-it js-check-it" 
                    data-options-kind="select"
                    data-check-id="<%= osfId %>"
                    data-id="<%= model.get('id') %>" 
                    data-embedded-view="di"
                >
            </td>
            <td class="desktop max-1-icons" data-id="<%= model.get('id') %>">
                <% $.each(Wat.I.detailsFields.di.general.fieldList.state.options, function (key, values) { %>
                    <i class="<%= values.icon %> js-progress-icon js-progress-icon--<%= key %> <%= model.get('state') != key ? 'hidden' : '' %>" data-i18n="[title]<%= values.text %>"></i>
                <% }); %>
                
                <%
                var hiddenIfPublished = '';
                var hiddenIfReadyOrPublished = '';
                var hiddenIfNotPublished = '';
                switch (model.get('state')) {
                    case 'published':
                        hiddenIfPublished = 'hidden';
                        hiddenIfReadyOrPublished = 'hidden';
                        break;
                    case 'ready':
                        hiddenIfReadyOrPublished = 'hidden';
                        hiddenIfNotPublished = 'hidden';
                        break;
                    default:
                        hiddenIfNotPublished = 'hidden';
                        break;
                }
                %>
                
                <%
                if (model.get('state') != 'published') {
                %>
                    <i class="fa fa-road js-future-tags-icon <%= hiddenIfPublished %>" data-model-function="renderFutureTags" data-id="<%= model.get('id') %>"></i>
                <%
                }
                
                if (model.get('tags')) {
                %>
                    <i class="fa fa-tags js-tags-icon <%= hiddenIfNotPublished %>" data-model-function="renderTags" data-id="<%= model.get('id') %>"></i>
                <%
                }

                if (model.get('head')) {
                %>
                    <i class="fa fa-flag-o js-head-icon <%= hiddenIfNotPublished %>" title="head"></i>
                <%
                }

                if (model.get('default')) {
                %>
                    <i class="fa fa-home js-default-icon <%= hiddenIfNotPublished %>" title="default"></i>
                <%
                }

                if (model.get('blocked')) {
                %>
                    <i class="fa fa-lock" data-i18n="[title]Blocked" title="<%= i18n.t('Blocked') %>"></i>
                <%
                }

                if (model.get('auto_publish')) {
                %>
                    <i class="fa fa-rocket js-auto-publish-icon <%= hiddenIfReadyOrPublished %>" data-i18n="[title]Will be published after generation" title="<%= i18n.t('Will be published after generation') %>"></i>
                <%
                }
                
                if (model.get('expiration_time_hard') != null) {
                    var expirationTime = Wat.U.secondsToHms(model.get('expiration_time_hard'), 'strLong');
                %>
                    <i class="fa fa-hourglass-half js-expiration-icon <%= hiddenIfPublished %>" title="<%= i18n.t('Affected machines will expire') %>: <%= i18n.t('__time__ after generation', {
                        time: expirationTime
                    }) %>"></i>
                <%
                }
                %>
            </td>
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
