<div class="customize-options customize-options--columns js-customize-options js-customize-options--columns" style="<%= $('select[name="element-select"]').val() == 'columns' ? '' : 'display: none;' %>">
<div class="js-customize-columns customize-columns customize-block">
    <table class="customize-fields">
        <tr>
            <th class="center max-1-icons" data-i18n="[title]A column in list view"><i class="fa fa-columns auto"></i></th>
            <th data-i18n="Column"></th>
        </tr>
        <%
        $.each(columns, function(fName, field) {
                if (field.fixed) {
                    return;
                }
                
                if (limitByACLs) {                        
                    if (field.groupAcls) {
                        if (!Up.C.checkGroupACL(field.groupAcls)) {
                            return;
                        }
                    }
                    else if (field.acls) {
                        if (!Up.C.checkACL(field.acls)) {
                            return;
                        }
                    }
                }
        %>  
                <tr class="<%= field.property ? 'js-is-property' : '' %>" data-name="<%= fName %>">
                    <td class="center cell-check">
                        <div class="js-field-check <%= field.property ? 'js-is-property' : '' %>" <%= field.property ? 'data-property-id="' + field.property_id  + '"' : '' %> data-name="<%= fName %>" data-fields="<%= field.fields.join(',') %>">
                            <%= Up.I.controls.CheckBox({checked: field.display}) %>
                        </div>
                    </td>
                    <td>
        <%

                if (field.noTranslatable) {
        %>  
                    <span>
                        <%= field.text %>
                    </span>
        <%
                }
                else {
        %>
                    <span data-i18n="<%= field.text %>">
                        <%= i18n.t(field.text) %>
                    </span>
        <%
                }
        %>
        
                    <span class="fa fa-info-circle js-default-info" style="<%= field.customized ? 'display: none;' : '' %>" data-i18n="[title]Default value"></span>
                    </td>
                </tr>
        <%
        });
        %>
            <tr class="js-is-property js-column-property-template hidden" data-name="">
                <td class="center cell-check">
                    <div class="js-field-check js-is-property" data-name="" data-fields="">
                        <%= Up.I.controls.CheckBox({checked: false}) %>
                    </div>
                </td>
                <td>
                    <span class="js-prop-name">
                    </span>
                </td>
            </tr>
    </table>
</div>
<div class="js-customize-columns customize-filters customize-block">
    <div class="h1" data-i18n="Example"></div>
    <img src="images/views_columns.png" style="width: 100%" />
</div>
</div>

<div class="customize-options customize-options--filters js-customize-options js-customize-options--filters" style="<%= $('select[name="element-select"]').val() == 'filters' ? '' : 'display: none;' %>">
<div class="js-customize-filters customize-filters customize-block">
    <table class="customize-fields">
        <tr>
            <th class="center max-1-icons" data-i18n="[title]Desktop version"><i class="fa fa-desktop auto"></i></th>
            <th class="center max-1-icons" data-i18n="[title]Mobile version"><i class="fa fa-mobile auto"></i></th>
            <th data-i18n="Filter control"></th>
        </tr>
        <%
        $.each(filters, function(fName, filter) {
                if (filter.fixed) {
                    return;
                }
                
                if (limitByACLs) {
                    if (filter.groupAcls) {
                        if (!Up.C.checkGroupACL(filter.groupAcls)) {
                            return;
                        }
                    }
                    else if (filter.acls) {
                        if (!Up.C.checkACL(filter.acls)) {
                            return;
                        }
                    }
                }
        %>  
                <tr class="<%= filter.property ? 'js-is-property' : '' %>" data-name="<%= fName %>">
                    <td class="center cell-check">
                        <div  data-name="<%= fName %>" data-field="<%= filter.filterField %>" class="js-desktop-fields">
                            <%= Up.I.controls.CheckBox({checked: filter.displayDesktop}) %>
                        </div>
                    </td>                    
                    <td class="center cell-check">
                        <div data-name="<%= fName %>" data-field="<%= filter.filterField %>" class="js-mobile-fields">
                            <%= Up.I.controls.CheckBox({checked: filter.displayMobile}) %>
                        </div>
                    </td>
                    <td>
        <%

                if (filter.noTranslatable) {
        %>  
                    <span>
                        <%= filter.text %>
                    </span>
        <%
                }
                else {
        %>
                    <span data-i18n="<%=filter.text%>">
                        <%= i18n.t(filter.text) %>
                    </span>
        <%
                }
        %>
                    <span class="fa fa-info-circle js-default-info" style="<%= filter.customized ? 'display: none;' : '' %>" data-i18n="[title]Default value"></span>

        <%

                filterType = Up.I.getFieldTypeName(filter.type);
        %>
                    <div class="second_row" data-i18n="<%= filterType %>"><%= i18n.t(filterType) %></div>
                    </td>
                </tr>
        <%
        });
        %>
            <tr class="js-is-property js-filter-property-template hidden" data-name="">
                <td class="center cell-check">
                    <div class="js-desktop-fields js-is-property" data-name="" data-fields="">
                        <%= Up.I.controls.CheckBox({checked: false}) %>
                    </div>
                </td>
                <td class="center cell-check">
                    <div class="js-mobile-fields js-is-property" data-name="" data-field="">
                        <%= Up.I.controls.CheckBox({checked: false}) %>
                    </div>
                </td>
                <td>                    
                    <span class="js-prop-name">
                    </span>
                    
                    <div class="second_row" data-i18n="Text input"><%= i18n.t('Text input') %></div>
                </td>
            </tr>
    </table>
</div>
<div class="js-customize-filters customize-columns customize-block">
    <div class="h1" data-i18n="Example"></div>
    <img src="images/views_filters.png" style="width: 100%" />
</div>
</div>