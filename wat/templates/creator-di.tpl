<table>
    <tr>
        <td data-i18n="Disk image"></td>
        <td>
            <input type="text" name="disk_image" value="" data-required>
        </td>
    </tr>
    <tr>
        <td data-i18n="Version"></td>
        <td>
            <input type="text" name="version" value="">
            <div class="second_row" data-i18n>
                <%=
                    '(' + i18n.t('Leave it blank for set automatic version based en creation date') + ')'
                %>
            </div>
        </td>
    </tr>
    <tr>
        <td data-i18n>OS Flavour</td>
        <td>
            <select class="" name="osf_id" data-any-selected></select>
        </td>
    </tr>
    <tr>
        <td data-i18n>Default</td>
        <td>
             <input type="checkbox" name="default" value="1">
        </td>
    </tr>
    <tr>
        <td data-i18n>Tags</td>
        <td>
            <input type="text" class="" name="tags" value="<%= model.get('tags') %>">
        </td>
    </tr>
 </table>