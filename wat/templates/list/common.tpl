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
        <div class="h2"><i class="fa fa-filter"></i><span data-i18n="Search by"></span></div>
        
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
                                <% 
                                    var textValue = '';
                                    if (currentFilters[filter.filterField] != undefined) {
                                        if (typeof currentFilters[filter.filterField] == 'string') {
                                            textValue = currentFilters[filter.filterField];
                                        }
                                        else {
                                            var firstKey = Object.keys(currentFilters[filter.filterField])[0];
                                            textValue = currentFilters[filter.filterField][firstKey];
                                            
                                            if (firstKey == '~') {
                                                // Remove wildcards (%25)
                                                textValue = textValue.substring(3, textValue.length-3);
                                            }
                                        }
                                    }
                                %>
                                <label for="<%= name %>" <%= translationAttr %>><%= filter.text %></label>
                                <input type="text" class="desktop-filter <%= filter.class %>" name="<%= name %>" data-filter-field="<%= filter.filterField %>" value="<%= textValue %>"/>
                            </span>
                        <%
                        break;            
                    case 'select':
                        %>
                            <span class="filter-control desktop">
                                <label for="<%= name %>" <%= translationAttr %>><%= filter.text %></label>
                                <select name="<%= name %>" class="desktop-filter <%= filter.class %>" data-filter-field="<%= filter.filterField %>" <%= filter.tenantDepent ? 'data-tenant-depent="1"' : '' %> <%= filter.waitLoading ? 'disabled="disabled" data-waiting-loading="1"' : '' %>>
                                    <% 
                                    /*
                                    var forceSelected = undefined;
                                    if (currentFilters[filter.filterField] != undefined) {
                                        forceSelected = currentFilters[filter.filterField];
                                    }
                                    */
                                    
                                    if (!filter.fillable) {
                                        _.each(filter.options, function(option) {
                                            // If is a not filter add a special attribute with value to be checked
                                            var notAttr = '';
                                            if (option.not != undefined) {
                                                notAttr = 'data-not="' + option.not + '"';
                                            }
                                    %>
                                            <% 
                                                /*
                                                if (forceSelected != undefined && forceSelected == option.value) {
                                                    option.selected = true;
                                                }
                                                */
                                                
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

