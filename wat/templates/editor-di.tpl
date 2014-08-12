<%
var tags = [];
var tagHead = false;
var tagDefault = false;

$(model.get('tags')).each( function (index, tag) {
    if (tag.tag == 'head') {
        tagHead = true;
    }
    else if (tag.tag == 'default') {
        tagDefault = true;
    }
    else {
        tags.push(tag.tag);
    }
});

%>

<table>
    <tr>
        <td data-i18n>Default</td>
        <td>
            <input type="text" class="" name="default" value="<%= model.get('default') %>">
        </td>
    </tr>
    <tr>
        <td data-i18n>Tags</td>
        <td>
            <input type="text" class="" name="tags" value="<%= tags.join(',') %>">
        </td>
    </tr>
 </table>