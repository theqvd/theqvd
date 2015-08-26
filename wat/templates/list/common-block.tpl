<div class="<%= cid %>">
    <div class="list-navigation">
        <div class="filter-mobile mobile">
            <%
                $.each(formFilters, function(name, filter) { 
                    if (!filter.displayMobile) {
                        return;
                    }
                    
                    var translationAttr = 'data-i18n';
                    if (filter.noTranslatable === true) {
                        translationAttr = '';
                    }
                    
                    switch(filter.type) {
                        case 'text':
                            %>
                                <span class="filter-control">
                                <label for="<%= name %>" data-i18n="<%= filter.text %>"></label>
                                <input type="text" name="<%= name %>" class="mobile-filter" data-filter-field="<%= name %>"/>
                                </span>
                            <%
                            break;
                        case 'select':
                            %>
                                <span class="filter-control desktop">
                                    <label for="<%= name %>" <%= translationAttr %>><%= filter.text %></label>
                                    <select name="<%= name %>" class="<%= filter.class %> mobile-filter" data-filter-field="<%= filter.filterField %>">
                                        <% 
                                        _.each(filter.options, function(option) {
                                            // If is a not filter add a special attribute with value to be checked
                                            var notAttr = '';
                                            if (option.not != undefined) {
                                                notAttr = 'data-not="' + option.not + '"';
                                            
                                            }
                                            
                                            var selectedAttr = '';
                                            if(option.selected) { 
                                                selectedAttr = 'selected="selected"';
                                            }
                                         %>
                                            <option value="<%= option.value %>" <%= selectedAttr %>  <%= notAttr %> <%= translationAttr %>><%= option.text %></option>
                                        <% 
                                        }); 
                                        %>
                                    </select>
                                </span>
                            <%
                            break;
                    }
                 }); 
             %>
        </div>
        <% if (listActionButton !== null && Wat.C.checkACL(listActionButton.acl)) { %>
            <div class="action-new-item">
                <a class="js-traductable_button js-button-new actions_button button fa fa-plus-circle" name="<%= listActionButton.name %>" href="<%= listActionButton.link %>" data-i18n="<%= listActionButton.value %>"></a>
            </div>
        <% } %>
        <div class="pagination">
            <a class="fa fa-step-backward first button2"></a>
            <a class="fa fa-caret-left prev button2"></a>
            <span class="pagination_current_page">1</span>/<span class="pagination_total_pages">1</span>
            <a class="fa fa-caret-right next button2"></a>
            <a class="fa fa-step-forward last button2"></a>
        </div>
    </div>
    <div class="list bb-list">

    </div>
    <div class="shown-elements js-shown-elements second_row">
        <span data=i18n="Shown"><%= $.i18n.t('Shown') %></span>:
        <span class="elements-shown"></span>
        /
        <span class="elements-total"></span>
    </div>
    <div class="mobile clear"></div>

    <% 
    if (Object.keys(selectedActions).length > 0)
    {
    %>
        <div class="selected-elements js-selected-elements second_row">
            <span data=i18n="Selected"><%= $.i18n.t('Selected') %></span>:
            <span class="elements-selected">0</span>
        </div>
        
        <fieldset class="action-selected js-action-selected">
            <legend data-i18n="Actions over selected items"></legend>
            <div class="action-selected-select">
                <select name="selected_actions_select" class="chosen-single">
                    <% $.each(selectedActions, function(action, actionConfig) { %>
                        <option value="<%= action %>" data-i18n="<%= actionConfig.text %>"></option>
                    <% }); %>
                </select>
            </div>
            <div class="action-selected-button">
                <a class="js-traductable_button actions_button button fa fa-check-square-o" name="selected_actions_button" data-i18n="Apply"></a>
            </div>
            <div class="clear mobile"></div>
        </fieldset>
    <%
    }
    %>
    <div class="clear mobile"></div>
</div>