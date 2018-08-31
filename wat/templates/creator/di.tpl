<input type="hidden" name="osd_id"></input>
<table>
    <tr data-tab-field="general">
        <td data-i18n="Description"></td>
        <td>
            <textarea id="name" type="text" name="description"></textarea>
        </td>
    </tr>
    <tr data-tab-field="general">
        <td data-i18n="OS Flavour"></td>
        <td>
            <select class="" name="osf_id" data-any-selected></select>
        </td>
    </tr>
    <tr class="js-osd-row" data-tab-field="image">
        <td data-i18n="Software preview"></td>
        <td class="bb-os-configuration"></td>
    </tr>
    <tr class="js-custom-image-row js-custom-image-row--selector" data-tab-field="image">
        <td data-i18n="Image's source"></td>
        <td>
            <select class="" id="images_source" name="images_source" data-any-selected>
                <option value="computer" data-i18n="Your computer"></option>
                <option value="staging" data-i18n="Staging directory"></option>
                <option value="url" data-i18n="URL"></option>
                <option value="docker" style="display: none"></option>
            </select>
        </td>
    </tr>
    <tr class="image_staging_row js-custom-image-row js-custom-image-row--source" data-tab-field="image" style="display: none;">
        <td data-i18n="Disk image"></td>
        <td>
            <select class="" name="disk_image" id="disk_image"></select>
        </td>
    </tr>
    <tr class="image_computer_row js-custom-image-row js-custom-image-row--source" data-tab-field="image">
        <td data-i18n="Disk image"></td>
        <td>
            <form id="form_file_update">
            <input type="file" name="disk_image_file" class="col-width-100" data-required></select>
            </form>
        </td>
    </tr>
    <tr class="image_url_row js-custom-image-row js-custom-image-row--source" data-tab-field="image">
        <td data-i18n="Disk image's URL"></td>
        <td>
            <input type="text" name="disk_image_url" class="col-width-100" data-required></select>
        </td>
    </tr>
    <tr class="image_docker_row js-custom-image-row js-custom-image-row--source" data-tab-field="image">
        <td data-i18n="Docker registry URL"></td>
        <td>
            <input type="text" name="docker_url" class="col-width-100" data-required></select>
        </td>
    </tr>
    <% 
    if (Wat.C.checkACL('di.create.version')) { 
    %>
    <tr data-tab-field="image">
        <td data-i18n="Version"></td>
        <td>
            <input type="text" name="version" value="">
            <div class="second_row">
                (<span data-i18n="Leave it blank to set an automatic version based on creation date"></span>)
            </div>
        </td>
    </tr>
    <% 
    }
    if (Wat.C.checkACL('di.update.auto-publish')) { 
    %>
    <tr class="js-osd-row" data-tab-field="image">
        <td data-i18n="Auto-publish"></td>
        <td>
            <select class="" id="publish" name="publish" data-any-selected>
                <option value="no" data-i18n="No"></option>
                <option value="when_finish" data-i18n="When publish"></option>
            </select>
        </td>
    </tr>
    <% 
    }
    if (Wat.C.checkACL('di.update.vms-expiration')) { 
    %>
    <tr class="js-osd-row" data-tab-field="image">
        <td data-i18n="Expire affected machines"></td>
        <td>
            <select class="" id="expire_vms" name="expire_vms" data-any-selected>
                <option value="no" data-i18n="No"></option>
                <option value="when_finish" data-i18n="When publish"></option>
                <option value="after_finish" data-i18n="Schedule"></option>
            </select>
        </td>
    </tr>
    <tr class="js-osd-row js-expire-vms-scheduler hidden" data-tab-field="image">
        <td></td>
        <td>
            <%=
                i18n.t("__hours__ hours and __minutes__ minutes after generation", {
                    hours: '<input type="text" name="expire_vms_hours" class="js-scheduler-hours" value="1">',
                    minutes: '<input type="text" name="expire_vms_minutes" class="js-scheduler-minutes" value="0">',
                })
            %>
        </td>
    </tr>
    <%
    }
    if (Wat.C.checkACL('di.create.default')) { 
    %>
    <tr data-tab-field="image">
        <td>Default</td>
        <td class="cell-check">
             <input type="checkbox" name="default" value="1">
        </td>
    </tr>
    <% 
    }
    if (Wat.C.checkACL('di.create.tags')) { 
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