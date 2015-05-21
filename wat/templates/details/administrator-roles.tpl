    <fieldset>
        <legend data-i18n="Roles assignment"></legend>
            <table class="roles-inherit-tools-table">
                <% 
                if (Wat.C.checkACL('administrator.update.assign-role')) { 
                %>
                    <tr>
                        <td colspan=2>
                            <div data-i18n="Assign a role to give the ACLs contained on it to the current administrator" class="bold"></div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <select name="role"></select>
                        </td>
                    </tr>
                    <tr>
                        <td class="col-width-1">
                            <a class="button add-role-button js-add-role-button fa fa-graduation-cap fright" href="javascript:" data-i18n="Assign selected role"></a>
                        </td>
                    </tr>
                <% 
                }   
                %>
            </table>
    </fieldset>