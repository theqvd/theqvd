<tr>
    <td colspan="<%= nColumns %>" class="center">
        <i class="fa fa-spin fa-gear"></i>
        <i class="<%= orderClass %>"></i>
        <%= $.i18n.t('Sorting by __field__', {'field': sortedFieldName}) %>
    </td>
</tr>