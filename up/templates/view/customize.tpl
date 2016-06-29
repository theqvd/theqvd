 <div class="js-custom-views-container <%= cid %> sec-custom-views-<%= viewKind %>" style="display: none;">
    <div class="details-header">
        <%
        if (viewKind == 'tenant') {
        %>
            <span class="<%= CLASS_ICON_VIEWS %> h1" data-i18n="Views"></span>
        <%
        } else {
        %>            
            <span class="<%= CLASS_ICON_VIEWS %> h1" data-i18n="My views"></span>
        <%
        }
        %>
     <%
     if (viewKind == 'tenant') {
     %>
        <div data-i18n="[title]Each administrator will be able to customize his own views overriding this configuration" class="fa fa-info-circle"></div>
     <%
     }
     %>
        <div class="clear mobile"></div>
        <a href="javascript:" class="button fright fa fa-eraser js-reset-views" data-i18n="Reset views to default configuration"></a>
    </div>
     
    <div class="wrapper-content">
        <div class="filter js-side">
            <%
            if (viewKind == 'tenant' && Wat.C.isSuperadmin()) {
            %>
            <span class="filter-control desktop">
                    <label for="tenant-select" data-i18n="Tenant"></label>
                    <select name="tenant-select" class="chosen-single"></select>
            </span>
            <%
            }
            %>
            <span class="filter-control desktop">
                <label for="obj-qvd-select" data-i18n="Section"></label>
                <select name="obj-qvd-select" class="chosen-single">
                    <%
                    if (!limitByACLs || Wat.C.checkACL('user.see-main.')) {
                    %>
                        <option data-i18n="Users" value="user" <%= selectedSection == "user" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('vm.see-main.')) {
                    %>
                        <option data-i18n="Virtual machines" value="vm" <%= selectedSection == "vm" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('host.see-main.')) {
                    %>
                        <option data-i18n="Nodes" value="host" <%= selectedSection == "host" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('osf.see-main.')) {
                    %>
                        <option data-i18n="OS Flavours" value="osf" <%= selectedSection == "osf" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('di.see-main.')) {
                    %>
                        <option data-i18n="Disk images" value="di" <%= selectedSection == "di" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (Wat.C.isMultitenant() && (Wat.C.isSuperadmin() || Wat.C.isRecoveradmin()) && (!limitByACLs || Wat.C.checkACL('tenant.see-main.'))) {
                    %>
                        <option data-i18n="Tenants" value="tenant" <%= selectedSection == "tenant" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('administrator.see-main.')) {
                    %>
                        <option data-i18n="Administrators" value="administrator" <%= selectedSection == "administrator" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('role.see-main.')) {
                    %>
                        <option data-i18n="Roles" value="role" <%= selectedSection == "role" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('log.see-main.')) {
                    %>
                        <option data-i18n="Log" value="log" <%= selectedSection == "log" ? 'selected' : '' %>></option>
                    <%
                    }
                    %>
                </select>
            </span>

                <span class="filter-control desktop">
                <label for="element-select" data-i18n="Element"></label>
                <select name="element-select" class="chosen-single">
                    <option value="columns" data-i18n="Columns"></option>
                    <option value="filters" data-i18n="Filters"></option>
                </select>
                </span>
            </div>
        <div class="bb-customize-form"></div>
    </div>
</div>