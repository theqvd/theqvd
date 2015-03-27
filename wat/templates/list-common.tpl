<%
    var nFilters = 0;
    $.each(formFilters, function(name, filter) {
        if (!filter.displayDesktop) {
            return;
        }
        
        nFilters++;
    });
    
    var filtersClass = '';
    var listBlockClass = '';
    if (nFilters == 0) {
        filtersClass = 'hidden-forced';
        listBlockClass = 'col-width-100';
    }
%>
<div class="wrapper-content <%= cid %>">
    <div class="filter js-side <%= filtersClass %>">
        <!-- ADVANCED FILTERS
        <span class="filter-control">
            <label for="filter_mode" data-i18n="Filter mode"></label>
            <select class="chosen-single" name="filter_mode">
                <option value="simple" selected="selected" data-i18n="Simple"></option>
                <option value="advanced" data-i18n="Advanced"></option>
            </select>
        </span>
        <hr>
        -->
        <% 
            $.each(formFilters, function(name, filter) {
                if (!filter.displayDesktop) {
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
                                <label for="<%= name %>" <%= translationAttr %>><%= filter.text %></label>
                                <input type="text" name="<%= name %>" data-filter-field="<%= filter.filterField %>"/>
                            </span>
                        <%
                        break;            
                    case 'select':
                        %>
                            <span class="filter-control desktop">
                                <label for="<%= name %>" <%= translationAttr %>><%= filter.text %></label>
                                <select name="<%= name %>" class="<%= filter.class %>" data-filter-field="<%= filter.filterField %>">
                                    <% 
                                    if (!filter.fillable) {
                                        _.each(filter.options, function(option) {
                                            // If is a not filter add a special attribute with value to be checked
                                            var notAttr = '';
                                            if (option.not != undefined) {
                                                notAttr = 'data-not="' + option.not + '"';
                                            }
                                    %>
                                            <% 
                                                var selectedAttr = '';
                                                if(option.selected) { 
                                                    selectedAttr = 'selected="selected"';
                                                }
                                            %>
                                            <option value="<%= option.value %>" <%= selectedAttr %> <%= notAttr %> <%= translationAttr %>><%= option.text %></option>
                                    <% 
                                        }); 
                                    }
                                    %>
                                </select>
                            </span>
                        <%
                        break;
                }
             }); 
         %>
    </div>

    <div class="list-block bb-list-block <%= listBlockClass %>">
    </div>
</div>

