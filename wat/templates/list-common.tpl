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
            <a class="js-traductable_button actions_button button2 fa fa-filter" name="filter_button" data-i18n>
                tButton.filter
                </a>
        </div>
    </div>

    <div class="list-block bb-list-block">
    </div>
</div>

