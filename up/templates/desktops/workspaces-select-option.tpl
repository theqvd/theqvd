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