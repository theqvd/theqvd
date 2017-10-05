<div class="<%= cid %> sec-list-<%= qvdObj %>">
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
                                <span class="filter-control" data-fieldname="<%= name %>">
                                <label for="<%= name %>" data-i18n="<%= filter.text %>"></label>
                                <input type="text" name="<%= name %>" class="mobile-filter" data-filter-field="<%= name %>"/>
                                </span>
                            <%
                            break;
                        case 'select':
                            %>
                                <span class="filter-control desktop" data-fieldname="<%= name %>">
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
                <a class="js-traductable_button js-button-new actions_button button fa fa-plus-circle" data-qvd-obj="<%= qvdObj %>" name="<%= listActionButton.name %>" href="<%= listActionButton.link %>" data-i18n="<%= listActionButton.value %>"></a>
            </div>
        <% } %>
        <div class="pagination js-pagination fright">
            <a class="fa fa-step-backward first button2"></a>
            <a class="fa fa-caret-left prev button2"></a>
            <span class="pagination_current_page"><input type="text" class="js-current-page current-page" val="1"/></span> / <span class="pagination_total_pages">1</span>
            <a class="fa fa-caret-right next button2"></a>
            <a class="fa fa-step-forward last button2"></a>
        </div>
    </div>
    <div class="list bb-list js-list">

    </div>
    <div class="shown-elements js-shown-elements second_row fright">
        <span data=i18n="Shown"><%= $.i18n.t('Shown') %></span>:
        <span class="elements-shown"></span>
        /
        <span class="elements-total"></span>
    </div>
    <div class="clear"></div>
    
    <fieldset class="action-selected js-action-selected bb-action-selected"></fieldset>
    
    <div class="clear mobile"></div>
</div>