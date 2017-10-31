<%
    var shortcuts = pluginData.attributes;
    $.each(shortcuts, function (i, sc) {
        var scIcon = assets.findWhere({id: sc.idAsset});
        sc.iconUrl = scIcon.get('url');
        %>
            <div class="setting-row" style="clear: both;">
                <span class="settings-box-element-shortcut">
                    <div class="icon-bg fleft" style="background-image: url(<%= sc.iconUrl %>); height: 32px; width: 32px;">
                        <i class="fa fa-share shortcut"></i>
                    </div>
                </span>
                <span class="fleft">
                    <div><%= sc.name %></div>
                    <div class="second_row"><span data-i18n="Command">Command</span>: <%= sc.code %></div>
                </span>
            </div>
        <%
    });

    if (Object.keys(shortcuts).length == 0) {
        %>
        <span class="second_row" data-i18n="No elements found"></span>
        <%
    }
%>