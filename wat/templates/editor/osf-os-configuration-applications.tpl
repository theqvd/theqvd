
<% if (massive) { %>
        <div class="info-header second_row" colspan=2>
            <span data-i18n class="fa fa-info-circle">Selected elements will be overrided or added to the affected OSFs without remove other existing items</span><br> 
        </div>
<% } %>
<div>
    <input type="text" class="fleft col-width-25 configuration-block" data-i18n="[placeholder]Search">
</div>
<table class="list js-list-apps">
    <% $.each(apps, function (appCode, app) { %>
        <tbody data-unique-id="code-<%= appCode %>" data-row-app-wrapper="<%= appCode %>" 
                data-app-category="<%= app.category %>">

            <tr data-row-app="<%= appCode %>"
                <%= !app.installed ? 'class="disabled"' : '' %>>

                <td class="col-width-5">
                    <button class="
                                button2 
                                fright 
                                button-icon--desktop 
                                js-button-show-app-details 
                                fa 
                                fa-chevron-down 
                                <%= !app.installed ? 'disabled' : '' %>
                                " 
                            href="javascript:" 
                            data-i18n="[title]Edit" 
                            data-app="<%= appCode %>" 
                            title="View app details">

                        <span data-i18n="Edit" class="mobile">View app details</span>
                    </button>
                </td>
                <td class="col-width-5">
                    <input class="js-app-install-checkbox" 
                            data-app="<%= appCode %>" 
                            type="checkbox" 
                            <%= app.installed ? 'checked="checked"' : '' %>/>
                </td>
                <td class="col-width-5">
                    <div class="icon-bg" style="background-image: url(<%= app.icon %>)"></div>
                </td>
                <td class="col-width-80">
                    <%= app.name + " " + app.version %>
                </td>
                <td class="col-width-5">
                    <i class="fa fa-list-ul <%= app.menu ? '' : 'disabled' %>"></i>
                </td>
            </tr>
            <tr class="hidden" data-row-app-details="<%= appCode %>">
                <td colspan="6">
                    <table class="col-width-100">
                        <tbody data-unique-id="code-<%= appCode %>">
                            <tr>
                                <td>
                                    Icon
                                </td>
                                <td colspan=2>
                                    <input type="text" name="app_icon" value="<%= app.icon %>"></input>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    Applications menu
                                </td>
                                <td colspan=2>
                                    <input type="checkbox" <%= app.menu ? 'checked="checked"' : '' %>/>
                                </td>
                            </tr>
                            <%
                            $.each (app.settings, function (iSetting, setting) {
                            %>
                                <tr>
                                    <td>
                                        <%= setting.name %>
                                    </td>
                                    <td colspan=2>
                                        <%
                                        switch (setting.type) {
                                            case 'text':
                                                %>
                                                    <input type="text" value="<%= typeof setting.default != 'undefined' ? setting.default : '' %>">
                                                <%
                                                break;
                                            case 'select':
                                                break;
                                            case 'checkbox':
                                                %>
                                                    <table>
                                                        <%
                                                        $.each (setting.boxes, function (iBox, box) {
                                                        %>
                                                            <tr>
                                                                <td class="col-width-5">
                                                                    <input type="checkbox" <%= box.checked ? 'checked="checked"' : '' %>/>
                                                                </td>
                                                                <td class="col-width-5">
                                                                    <img src="<%= box.icon %>" width="19px"/>
                                                                </td>
                                                                <td>
                                                                    <%= box.name %>
                                                                </td>
                                                            </tr>
                                                        <%
                                                        });
                                                        %>
                                                    </table>
                                                <%
                                                break;
                                            case 'radio':
                                                break;
                                        }
                                        %>
                                    </td>
                                </tr>
                            <%
                            });
                            %>
                        </tbody>
                    </table>
                </td>
            </tr>
        </tbody>
    <% }); %>
</table>