<div class="wrapper-content <%= cid %>">
    <div class="filter js-side">
        <span class="filter-control">
            <label for="filter_mode" data-i18n>Filter mode</label>
            <select class="chosen-single" name="filter_mode">
                <option value="simple" selected="selected" data-i18n>Simple</option>
                <option value="advanced" data-i18n>Advanced</option>
            </select>
        </span>
        <hr>
        <% 
            _.each(formFilters, function(filter) { 
                var translationAttr = 'data-i18n';
                if (filter.noTranslatable === true) {
                    translationAttr = '';
                }
                
                switch(filter.type) {
                    case 'text':
                        %>
                            <span class="filter-control">
                                <label for="<%= filter.name %>" <%= translationAttr %>><%= filter.label %></label>
                                <input type="text" name="<%= filter.name %>" data-filter-field="<%= filter.filterField %>"/>
                            </span>
                        <%
                        break;            
                    case 'select':
                        %>
                            <span class="filter-control desktop">
                                <label for="<%= filter.name %>" <%= translationAttr %>><%= filter.label %></label>
                                <select name="<%= filter.name %>" class="<%= filter.class %>" data-filter-field="<%= filter.filterField %>">
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

    <div class="list-block bb-list-block">
    </div>
</div>

