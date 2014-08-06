<div class="<%= cid %>">
    <div class="list-navigation">
        <% if (listActionButton !== null) { %>
            <div class="action-new-item">
                <a class="js-traductable_button actions_button button fa fa-plus-circle" name="<%= listActionButton.name %>" href="<%= listActionButton.link %>" data-i18n>
                    <%= listActionButton.value %>
                </a>
            </div>
        <% } %>
        <div class="filter-mobile mobile">
            <% 
                _.each(formFilters, function(filter) { 
                    switch(filter.mobile) {
                        case true:
                            %>
                                <span class="filter-control">
                                <label for="<%= filter.name %>" data-i18n><%= filter.label %></label>
                                <input type="text" name="<%= filter.name %>"/>
                                </span>
                            <%
                            break;
                    }
                 }); 
             %>
        </div>
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
</div>