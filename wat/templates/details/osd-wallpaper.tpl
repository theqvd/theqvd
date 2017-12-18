<%
if (!pluginData.get('id')) {
%>
    <div>
        <span class="second_row" data-i18n="No wallpaper is defined"></span>
    </div>
<%
}
else {
    var wpModel = assets.findWhere({id: pluginData.get('id')});
    wpUrl = wpModel.get('url');
%>
    <div>
        <span data-i18n="Wallpaper"></span>
    </div>
    <div class="js-wallpaper-details" data-wallpaper="<%= pluginData.get('name') %>">
        <img src="<%= wpUrl %>" style="width: 300px;" title="<%= pluginData.get('name') %>"/>
    </div>
<%
}
%>