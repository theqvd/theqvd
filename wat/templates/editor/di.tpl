<input type="hidden" name="osd_id"></input>
<table>
    <%
    if (Wat.C.checkACL('vm.update.description')) {
    %>
    <tr data-tab-field="general">
        <td data-i18n="Description"></td>
        <td>
            <textarea id="name" type="text" name="description"><%= model.get('description') %></textarea>
        </td>
    </tr>
    <%
    }
    if (model.get('state') != 'published' && model.get('state') != 'ready') { 
    %>
        <tr class="js-osd-row" data-tab-field="image">
            <td data-i18n="Auto-publish"></td>
            <td>
                <select class="" id="publish" name="publish" data-any-selected>
                    <option value="no" data-i18n="No" <%= model.get('auto_publish') ? '' : 'selected="selected"' %>></option>
                    <option value="when_finish" data-i18n="When finish generation" <%= model.get('auto_publish') ? 'selected="selected"' : '' %>></option>
                </select>
            </td>
        </tr>
        <tr class="js-osd-row" data-tab-field="image">
            <td data-i18n="Expire affected machines"></td>
            <td>
                <select class="" id="expire_vms" name="expire_vms" data-any-selected>
                    <option value="no" data-i18n="No" <%= model.get('expiration_time_hard') === null ? 'selected="selected"' : '' %>></option>
                    <option value="when_finish" data-i18n="When finish generation" <%= model.get('expiration_time_hard') === 0 ? 'selected="selected"' : '' %>></option>
                    <option value="after_finish" data-i18n="Schedule" <%= model.get('expiration_time_hard') > 0 ? 'selected="selected"' : '' %>></option>
                </select>
            </td>
        </tr>
        <tr class="js-osd-row js-expire-vms-scheduler <%= !model.get('expiration_time_hard') ? 'hidden' : '' %>" data-tab-field="image">
            <td></td>
            <td>
                <%
                    var hours = 1; // 1 hour by default
                    var minutes = 0;
                    
                    if (model.get('expiration_time_hard') ) {
                        var totalSeconds = parseInt(model.get('expiration_time_hard'));
                        var totalMinutes = Math.round(totalSeconds/60);
                        hours = Math.round(totalMinutes / 60);
                        minutes = Math.round(totalMinutes % 60);
                    }
                %>
                <%=
                    i18n.t("__hours__ hours and __minutes__ minutes after generation", {
                        hours: '<input type="text" name="expire_vms_hours" class="js-scheduler-hours" value="' + hours + '" readonly>',
                        minutes: '<input type="text" name="expire_vms_minutes" class="js-scheduler-minutes" value="' + minutes + '" readonly>',
                    })
                %>
            </td>
        </tr>
    <%
    }
    %>
    <tr data-tab-field="image">
        <td>Default</td>
        <td>
            <%
            if (model.get('default')) {
            %>
                <div class="second_row" data-i18n="This disk image is already setted as default - To change this, another disk image of the same OSF must be setted as default"></div>
            <%
            }
            else {
            %>
                <input type="checkbox" name="default" value="1">
            <%
            }
            %>
        </td>
    </tr>
    <% 
    if (Wat.C.checkACL('di.update.tags')) { 
    %>
        <tr data-tab-field="image">
            <td data-i18n="Tags"></td>
            <td>
                <input type="text" class="" name="tags" value="<%= model.get('tags') %>">
            </td>
        </tr>
    <% 
    } 
    %>
 </table>