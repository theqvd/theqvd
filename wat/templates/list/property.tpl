<%
if (!Wat.C.checkGroupACL('propertiesManagement')) {
%>
<div class="second_row" data-i18n="Custom properties management is not available"></div>
<%
}
else {
%>    
    <div class="wrapper-content">
     <div class="js-custom-views-container <%= cid %> sec-properties">
             <div class="filter js-side">
                <% if (Wat.C.isSuperadmin()) { %>
                <div class="filter-control desktop">
                    <label for="obj-qvd-select" data-i18n>Tenant</label>
                    <select name="tenant-select" class="chosen-single">
                    </select>
                </div>
                <% } %>
                <div class="filter-control desktop">
                    <label for="obj-qvd-select" data-i18n="Section"></label>
                    <select name="obj-qvd-select" class="chosen-single">
                            <option data-i18n="All" value="all" <%= selectedObj == "all" ? 'selected' : '' %>></option>

                        <%
                        if (Wat.C.checkACL('property.manage.user')) {
                        %>
                            <option data-i18n="Users" value="user" <%= selectedObj == "user" ? 'selected' : '' %>></option>
                        <%
                        }
                        if (Wat.C.checkACL('property.manage.vm')) {
                        %>
                            <option data-i18n="Virtual machines" value="vm" <%= selectedObj == "vm" ? 'selected' : '' %>></option>
                        <%
                        }
                        if (Wat.C.checkACL('property.manage.host')) {
                        %>
                            <option data-i18n="Nodes" value="host" <%= selectedObj == "host" ? 'selected' : '' %>></option>
                        <%
                        }
                        if (Wat.C.checkACL('property.manage.osf')) {
                        %>
                            <option data-i18n="OS Flavours" value="osf" <%= selectedObj == "osf" ? 'selected' : '' %>></option>
                        <%
                        }
                        if (Wat.C.checkACL('property.manage.di')) {
                        %>
                            <option data-i18n="Disk images" value="di" <%= selectedObj == "di" ? 'selected' : '' %>></option>
                        <%
                        }
                        %>
                    </select>
                </div>
            </div>    

            <div class="bb-property-list list-block"></div>
        </div>
    </div>
<%
}
%>