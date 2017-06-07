<% if (massive) { %>
        <div class="info-header second_row" colspan=2>
            <span data-i18n class="fa fa-info-circle">This list will be added to the affected OSFs without remove existing items</span><br> 
        </div>
<% } %>

<table class="js-list-shortcuts" style="margin-bottom: 20px;">
    <tbody class="shortcuts-form">
        <tr>
            <td class="col-width-47">
                <div>Shortcut name</div>
                <input type="text" name="shortcut_name">
            </td>
            <td class="col-width-47">
                <div>Command</div>
                <input type="text" name="shortcut_command">
            </td>
            <td class="col-width-5" style="vertical-align: bottom;">
                <a class="button2 fa fa-plus-circle js-add-shortcut" data-i18n="New shortcut">New shortcut</a>
            </td>
        </tr>
    </tbody>
</table>
<table class="list js-list-shortcuts">
    <tbody class="shortcuts-form">
        <tr>
            <td colspan=5>
                <input type="text" class="fleft col-width-25 configuration-block" data-i18n="[placeholder]Search">
            </td>
        </tr>
    </tbody>
    <tbody class="bb-os-conf-shortcuts-new-rows"></tbody>
    <tbody class="bb-os-conf-shortcuts-rows"></tbody>
</table>