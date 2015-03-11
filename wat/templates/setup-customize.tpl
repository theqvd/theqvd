 <div class="js-custom-views-container" style="display: none;">
     <%
     if (viewKind == 'tenant') {
     %>
        <div class="info-header">
            <span data-i18n class="fa fa-info-circle">Definition of default elements shown in WAT's sections</span>.<br> 
            <span data-i18n class="fa fa-info-circle">Each administrator will be able to customize his own views overriding this configuration</span>.
        </div>
     <%
     }
     %>
     <fieldset class="action-selected">
        <div class="customize-section-selectors">
            <div class="customize-section-selector">
                <label for="obj-qvd-select">Section</label>
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
                    %>
                </select>
            </div>

            <div class="customize-section-selector">    
                <%
                if (viewKind == 'tenant' && Wat.C.isSuperadmin()) {
                %>
                    <label for="tenant-select">Tenant</label>
                    <select name="tenant-select" class="chosen-single"></select>    
                <%
                }
                else if (viewKind == 'tenant') {
                %>
                    <input type="hidden" name="tenant-select" value="<%= Wat.C.tenantID %>"/>
                <%
                }
                %>
            </div>
            <div class="customize-section-selector">    
                <a href="javascript:" class="button fa fa-eraser js-reset-views" data-i18n="Reset views to default configuration"></a>
            </div>
        </div>    
    </fieldset>

    <div class="bb-customize-form">
    </div>
</div>