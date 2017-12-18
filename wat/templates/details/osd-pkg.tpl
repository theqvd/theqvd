<%
var pkgCollection = pluginData;

$.each(pkgCollection.models, function (i, pkgModel) {
    %>
    <div class="js-package-details" data-package="<%= pkgModel.get('name') %>">
        <span>- <%= pkgModel.get('name') %><span>
        <div class="second_row"><%= pkgModel.get('description') %></div>
    </div>
    <%
});

if (pkgCollection.models.length == 0) {
    %>
    <span class="second_row" data-i18n="No elements found"></span>
    <%
}

%>