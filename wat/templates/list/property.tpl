 <div class="js-custom-views-container <%= cid %>">
     <fieldset>
        <div class="customize-section-selectors">
            <div class="customize-section-selector">
                <label for="obj-qvd-select" data-i18n>Section</label>
                <select name="obj-qvd-select" class="chosen-single">
                        <option data-i18n="All" value="all" <%= selectedObj == "all" ? 'selected' : '' %>></option>
                        
                    <%
                    if (!limitByACLs || Wat.C.checkACL('user.see-main.')) {
                    %>
                        <option data-i18n="Users" value="user" <%= selectedObj == "user" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('vm.see-main.')) {
                    %>
                        <option data-i18n="Virtual machines" value="vm" <%= selectedObj == "vm" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('host.see-main.')) {
                    %>
                        <option data-i18n="Nodes" value="host" <%= selectedObj == "host" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('osf.see-main.')) {
                    %>
                        <option data-i18n="OS Flavours" value="osf" <%= selectedObj == "osf" ? 'selected' : '' %>></option>
                    <%
                    }
                    if (!limitByACLs || Wat.C.checkACL('di.see-main.')) {
                    %>
                        <option data-i18n="Disk images" value="di" <%= selectedObj == "di" ? 'selected' : '' %>></option>
                    <%
                    }
                    %>
                </select>
            </div>
            <% if (Wat.C.isSuperadmin()) { %>
            <div class="customize-section-selector">
                <label for="obj-qvd-select" data-i18n>Tenant</label>
                <select name="tenant-select" class="chosen-single">
                </select>
            </div>
            <% } %>
        </div>    
    </fieldset>

    <div class="bb-property-list list-block col-width-100">
    </div>
</div>