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

</div>
<div class="bb-customize-form">
</div>