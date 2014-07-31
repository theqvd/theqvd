<div class="wrapper-content">
    <div class="filter js-side">
        <span class="filter-control">
            <label for="filter_mode" data-i18n>tFilter.filter_mode</label>
            <select class="chosen-single" name="filter_mode">
                <option value="simple" selected="selected" data-i18n>tFilter.simple</option>
                <option value="advanced" data-i18n>tFilter.advanced</option>
            </select>
        </span>
        <hr>
        <% 
            _.each(filters, function(filter) { 
                switch(filter.type) {
                    case 'text':
                        %>
                            <span class="filter-control">
                                <label for="<%= filter.name %>" data-i18n><%= filter.label %></label>
                                <input type="text" name="<%= filter.name %>"/>
                            </span>
                        <%
                        break;            
                    case 'select':
                        %>
                            <span class="filter-control desktop">
                                <label for="<%= filter.name %>" data-i18n><%= filter.label %></label>
                                <select name="<%= filter.name %>" class="<%= filter.class %>">
                                    <% _.each(filter.options, function(option) { %>
                                        <% 
                                            var selectedAttr = '';
                                            if(option.selected) { 
                                                selectedAttr = 'selected="selected"';
                                            }
                                        %>
                                        <option value="<%= option.value %>" <%= selectedAttr %> data-i18n><%= option.text %></option>
                                    <% }); %>
                                </select>
                            </span>
                        <%
                        break;
                }
             }); 
         %>
         
        <div class="action-filter">
            <a class="js-traductable_button actions_button button fa fa-filter" name="filter_button" data-i18n>
                tButton.filter
                </a>
        </div>
    </div>

    <div class="list-block">
        <div class="list-navigation">
            <div class="action-new-item">
                <a class="js-traductable_button actions_button button fa fa-plus-circle" name="new_item_button" data-i18n>
                    <%= config.new_item_text %>
                </a>
            </div>
            <div class="filter-mobile mobile">
                <% 
                    _.each(filters, function(filter) { 
                        switch(filter.type) {
                            case 'text':
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
                <a class="fa fa-step-backward first button"></a>
                <a class="fa fa-caret-left prev button"></a>
                <span class="pagination_current_page">1</span>/<span class="pagination_total_pages">1</span>
                <a class="fa fa-caret-right next button"></a>
                <a class="fa fa-step-forward last button"></a>
            </div>
        </div>
        <div class="list bb-list">

        </div>
        
        <div class="action-selected">
            <select name="selected_actions_select" class="chosen-single">
                <% _.each(selected_actions, function(action) { %>
                    <option value="<%= action.value %>" data-i18n><%= action.text %></option>
                <% }); %>
            </select>
            <a class="js-traductable_button actions_button button fa fa-check" name="selected_actions_button" data-i18n>
                tButton.apply_to_selected_items
            </a>
        </div>

    </div>
</div>

