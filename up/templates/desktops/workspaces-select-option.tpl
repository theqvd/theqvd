<span data-i18n="Active configuration"></span>: 
<select class="" style="width: 20%"; name="active_configuration_select">
    <%
    $.each(collection.models, function (modId, model) {
    %>
        <option value="<%= model.get('id') %>" <%= model.get('active') ? 'selected="selected"' : '' %>><%= model.get('name') %></option>
    <%
    });
    %>
</select>

<div class="fright desktop">
    <a class="button fleft <%= viewMode == 'grid' ? 'disabled' : '' %> fa fa-th-large js-change-viewmode" name="viewmode-grid" data-viewmode="grid" href="javascript:" data-i18n="Grid"></a>
    <a class="button fleft <%= viewMode == 'list' ? 'disabled' : '' %> fa fa-th-list js-change-viewmode" name="viewmode-list" data-viewmode="list" href="javascript:" style="margin-left: 10px;" data-i18n="List"></a>
</div>