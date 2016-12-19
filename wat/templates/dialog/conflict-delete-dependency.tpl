<div class="dialog-advice">
        <div><span data-i18n="Some elements cannot be deleted due the following dependency"></span>:</div>
        <div class="center">
            <span data-i18n="<%= LOG_TYPE_OBJECTS[qvdObj] %>"></span>
            <span class="fa fa-long-arrow-right"></span>
            <span data-i18n="<%= LOG_TYPE_OBJECTS[QVD_OBJ_DEPENDENCIES[qvdObj]] %>"></span>
        </div>
        <div data-i18n="With the enforced deletion of an element, all dependent elements will be deleted too" class="bold"></div> 

    <table class="list js-elements-list" data-all-ids="<%= Object.keys(dependencyElements).join(',') %>" data-qvd-obj="<%= qvdObj %>">
        <tr>
            <th><i class="<%= CLASS_ICON_BY_QVD_OBJ[qvdObj] %>"><%= LOG_TYPE_OBJECTS[qvdObj] %></i></th>
            <th><span data-i18n="Action"></span></th>
        </tr>
        <% $.each (dependencyElements, function (id, name) { %>
            <tr class="js-force-delete-row" data-id="<%= id %>">
                <td><%= name %></td>
                <td>
                    <a class="fa fa-bomb button js-button-force-delete" data-i18n="Enforce deletion" data-id="<%= id %>"></a>
                    <span class="js-notifications fright" data-id="<%= id %>"></span>
                </td>
            </tr>
        <% }) %>
    </table>
</div>