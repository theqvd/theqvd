<% if (editable) { %>
    <button class="button2 js-button-edit-os button-edit-os fa fa-cog" href="javascript:" data-osf-id="<%= osfId %>" data-i18n="Configure software">Configure software</button>
<% } %>
<table class="details details-list os-configuration">
    <tr>
        <td>
            <i class="fa fa-window-maximize"></i>
            <span data-i18n="Distro">Distro</span>
        </td>
        <td class="settings-box settings-box-distro" colspan=2>
            <div class="fleft setting-row os-row js-os-row">
                <div class="settings-box-element-value" ><img class="os-icon" src="<%= distro.icon %>"><span class="os-name"><%= distro.value %></span></div>
            </div>
            <% if (shrinked) { %>
                <a class="button2 fright fa fa-chevron-down js-expand-os-conf">More</a>
            <% } %>
        </td>
    </tr>
    <tr class="js-os-configuration-expanded <%= shrinked ? 'hidden' : '' %>">
        <td>
            <i class="fa fa-tasks"></i>
            <span data-i18n="Settings">Settings</span>
        </td>
        <td class="settings-box">
            <%
                $.each(model.get('config_params'), function (paramName, paramDef) {
            %>
                    <div class="setting-row setting-row-list">
                        <span class="settings-box-element-name" data-18n="<%= paramDef.description %>"><%= paramDef.description %></span>
                        <div class="settings-box-element-value" >
                            <%
                                switch (paramDef.type) {
                                    case 'bool':
                                        print (model.get(paramName) ? 'Enabled' : 'Disabled');
                                        break;
                                    case 'list':
                                        print (paramDef.list_options[model.get(paramName)]);
                                        break;
                                    case 'text':
                                    default:
                                        print (model.get(paramName));
                                        break;
                                }
                            %>
                        </div>
                    </div>
            <%
                });
            %>
        </td>
    </tr>
    <tr class="js-os-configuration-expanded <%= shrinked ? 'hidden' : '' %>">
        <td>
            <i class="fa fa-share"></i>
            <span data-i18n="Shortcuts">Shortcuts</span>
        </td>
        <td class="settings-box">
            <%
                $.each(shortcuts, function (i, sc) {
                    %>
                        <div class="setting-row setting-row-list">
                            <span class="settings-box-element-shortcut">
                                <div class="icon-bg fleft" style="background-image: url(<%= sc.icon_url %>)">
                                    <i class="fa fa-share shortcut"></i>
                                </div>
                                <%= sc.name %>
                            </span>
                            <div></div>
                        </div>
                    <%
                });
                
                if (shortcuts.length == 0) {
                    print ('-');
                }
            %>
        </td>
    </tr>
    <tr class="js-os-configuration-expanded <%= shrinked ? 'hidden' : '' %>">
        <td>
            <i class="fa fa-code"></i>
            <span data-i18n="Scripts">Scripts</span>
        </td>
        <td class="settings-box">
            <%
                $.each(scripts, function (i, script) {
                    %>
                        <div class="setting-row setting-row-list">
                            <span class="settings-box-element-script">
                                <%= script.name + ' (' + script.execution_hook + ')' %>
                            </span>
                            <div></div>
                        </div>
                    <%
                });
                
                if (scripts.length == 0) {
                    print ('-');
                }
            %>
        </td>
    </tr>
</table>