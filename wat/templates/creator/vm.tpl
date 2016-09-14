<table>
    <tr>
        <td data-i18n="Name" class="mandatory-label"></td>
        <td>
            <input type="text" class="" name="name" data-required>
        </td>
    </tr>
    <tr>
        <td data-i18n="Description"></td>
        <td>
            <textarea id="name" type="text" name="description" data-i18n="[placeholder]No changes"></textarea>
        </td>
    </tr>
    <tr>
        <td data-i18n="User"></td>
        <td>
            <select class="" name="user_id" data-any-selected></select>
        </td>
    </tr>
    <tr>
        <td data-i18n="OS Flavour"></td>
        <td>
            <select class="" name="osf_id" data-any-selected></select>
        </td>
    </tr>
    <% if (Wat.C.checkACL('vm.create.di-tag')) { %>
    <tr>
        <td data-i18n="Image tag"></td>
        <td>
            <select class="" name="di_tag" data-any-selected></select>
        </td>
    </tr>
    <% } %>
 </table>