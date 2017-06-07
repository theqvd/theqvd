<table class="js-editor-table editor-table">
    <tr>
        <td>
        <table class="col-width-100 list">
            <tr>
                <th class="center">
                    Scripts
                </th>
            </tr>
                <td>
                    <% if (massive) { %>
                            <div class="info-header second_row" colspan=2>
                                <span data-i18n class="fa fa-info-circle">This list will be added to the affected OSFs without remove existing items</span><br> 
                            </div>
                    <% } %>
                    <input type="file" class="js-starting-script fleft right col-width-70" name="starting-script-file"/>
                    <a class="button2 fleft fa fa-plus-circle js-add-starting-script col-width-29 center" style="margin-left: 1%" data-i18n="Add script">Add script</a>
                    <div style="padding: 10px; clear: both;">
                        <table class="list js-scripts-list">
                            <tr class="js-scripts-empty">
                                <td class="second_row center" colspan=2 data-i18n="There are no starting scripts">There are no starting scripts</td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
        </td>
    </tr>
</table>