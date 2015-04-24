
<% if(Wat.C.checkACL('role.update.assign-role') && (!model.get('fixed') || !RESTRICT_INTERNAL_ROLES)) { %>
    <fieldset>
        <legend data-i18n="ACLs inheritance"></legend>
        <table class="roles-inherit-tools-table">
            <tr>
                <td colspan=2>
                    <div data-i18n="Inheritance mode" class="bold"></div>
                </td>                    
            </tr>
            <tr>
                <td colspan=2>
                    <input type="radio" name="role-inherit-mode" class="js-role-inherit-mode" <%= inheritanceSelectedMode == 'role' ? 'checked' : '' %> value="role">
                    <span data-i18n="Inherit ACLs from other roles"></span>
                </td>                    
            </tr>
            <tr>
                <td colspan=2>
                    <input type="radio" name="role-inherit-mode" class="js-role-inherit-mode" <%= inheritanceSelectedMode == 'template' ? 'checked' : '' %> value="template">
                    <span data-i18n="Inherit ACLs from templates"></span>
                </td>                    
            </tr>
            <tr class="inherit-role">
                <td colspan=2>
                    <div data-i18n="Roles" class="bold"></div>
                </td>
            </tr>
            <tr class="inherit-role">
                <td colspan=2>
                    <select name="role"></select>
                </td>
            </tr>
            <tr class="inherit-role">
                <td>
                    <a class="button add-role-button js-add-role-button fa fa-sitemap fright" href="javascript:" data-i18n="Inherit selected role"></a>
                </td>
            </tr>
            <tr class="inherit-template" style="display: none;">
                <td colspan=2>
                    <div data-i18n="Templates" class="bold"></div>
                </td>
            </tr>
            <tr class="inherit-template" style="display: none;">
                <td colspan=2>
                    <table class="role-template-matrix">
                        <tr>
                            <th class="center">
                            </th>
                            <%
                            $.each(ROLE_TEMPLATE_ACTIONS, function (iRTA, rTA) {
                            %>
                                <th><%= rTA %></th>
                            <%
                            });
                            %>
                        </tr>
                        <%
                        $.each(ROLE_TEMPLATE_SCOPE, function (iRTS, rTS) {
                        %>
                            <tr>
                                <th><%= rTS %></th>
                                <%
                                $.each(ROLE_TEMPLATE_ACTIONS, function (iRTA, rTA) {
                                %>
                                    <td data-role-template-cell="<%= rTS %> <%= rTA %>"><a class="button no-text-button add-template-button js-add-template-button fa fa-sitemap invisible" style="width: 100%;" href="javascript:" data-i18n="[title]<%= rTS %> <%= rTA %>"></a></td>
                                <%
                                });
                                %>
                            </tr>
                        <%
                        });
                        %>
                            <tr>
                                <th>Master</th>
                                <td colspan=7 data-role-template-cell="Master"><a class="button no-text-button add-role-button js-add-role-button fa fa-sitemap invisible" title="Master" style="width: 100%" href="javascript:"></a></td>
                            </tr>
                    </table>
                </td>
            </tr>
        </table>
    </fieldset>
<% } %>
