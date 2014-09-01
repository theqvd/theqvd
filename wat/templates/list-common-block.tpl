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
                                <label for="<%= name %>" data-i18n><%= filter.text %></label>
                                <input type="text" name="<%= name %>" class="mobile-filter" data-filter-field="<%= name %>"/>
                                </span>
                            <%
                            break;
                        case 'select':
                            %>
                                <span class="filter-control desktop">
                                    <label for="<%= name %>" <%= translationAttr %>><%= filter.text %></label>
                                    <select name="<%= name %>" class="<%= filter.class %> mobile-filter" data-filter-field="<%= filter.filterField %>">
                                        <% _.each(filter.options, function(option) { %>
                                            <% 
                                                var selectedAttr = '';
                                                if(option.selected) { 
                                                    selectedAttr = 'selected="selected"';
                                                }
                                            %>
                                            <option value="<%= option.value %>" <%= selectedAttr %> <%= translationAttr %>><%= option.text %></option>
                                        <% }); %>
                                    </select>
                                </span>
                            <%
                            break;
                    }
                 }); 
             %>
        </div>
        <% if (listActionButton !== null) { %>
            <div class="action-new-item">
                <a class="js-traductable_button js-button-new actions_button button fa fa-plus-circle" name="<%= listActionButton.name %>" href="<%= listActionButton.link %>" data-i18n>
                    <%= listActionButton.value %>
                </a>
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
    <% 
    if (selectedActions.length > 0)
    {
    %>
        <div class="action-selected">
            <select name="selected_actions_select" class="chosen-single">
                <% _.each(selectedActions, function(action) { %>
                    <option value="<%= action.value %>" data-i18n><%= action.text %></option>
                <% }); %>
            </select>
            <a class="js-traductable_button actions_button button fa fa-check" name="selected_actions_button" data-i18n>
                Apply to selected items
            </a>
        </div>
    <%
    }
    %>
</div>