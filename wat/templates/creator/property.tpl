<% 

var selectedObj = $('select[name="obj-qvd-select"]').val(); 

var checkedUser = '';
var checkedVM = '';
var checkedHost = '';
var checkedOSF = '';
var checkedDI = '';

switch (selectedObj) {
    case 'user':
        checkedUser = 'checked';
        break;
    case 'vm':
        checkedVM = 'checked';
        break;
    case 'host':
        checkedHost = 'checked';
        break;
    case 'osf':
        checkedOSF = 'checked';
        break;
    case 'di':
        checkedDI = 'checked';
        break;
    case 'all':
        checkedUser = 'checked';
        checkedVM = 'checked';
        checkedHost = 'checked';
        checkedOSF = 'checked';
        checkedDI = 'checked';
        break;
}

%>

<table>
    <tr>
        <td data-i18n="Name" class="mandatory-label"></td>
        <td>
            <input id="key" type="text" name="key" value="" data-required>
        </td>
    </tr>
    <tr>
        <td data-i18n="Description"></td>
        <td>
            <textarea id="description" type="text" name="description"></textarea>
        </td>
    </tr>
    <tr>
        <td data-i18n="Users"></td>
        <td>
            <input type="checkbox" name="in_user" value="1" <%= checkedUser %>>
        </td>
    </tr>
    <tr>
        <td data-i18n="Virtual machines"></td>
        <td>
            <input type="checkbox" name="in_vm" value="1" <%= checkedVM %>>
        </td>
    </tr>
    <tr>
        <td data-i18n="Nodes"></td>
        <td>
            <input type="checkbox" name="in_host" value="1" <%= checkedHost %>>
        </td>
    </tr>
    <tr>
        <td data-i18n="OS Flavours"></td>
        <td>
            <input type="checkbox" name="in_osf" value="1" <%= checkedOSF %>>
        </td>
    </tr>
    <tr>
        <td data-i18n="Disk images"></td>
        <td>
            <input type="checkbox" name="in_di" value="1" <%= checkedDI %>>
        </td>
    </tr>
 </table>
