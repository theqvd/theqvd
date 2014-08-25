<table>
    <tr>
        <td data-i18n="Disk image"></td>
        <td>
            <input type="text" name="disk_image" value="">
        </td>
    </tr>
    <tr>
        <td data-i18n="Version"></td>
        <td>
            <input type="text" name="version" value="">
        </td>
    </tr>
    <tr>
        <td data-i18n>OS Flavour</td>
        <td>
            <select class="" name="osf_id"></select>
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