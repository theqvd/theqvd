<%
if (!Wat.C.checkACL('property.manage.')) {
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
                <div class="filter-control desktop" data-fieldname="tenant">
                    <label for="obj-qvd-select" data-i18n>Tenant</label>
                    <select name="tenant-select">
                    </select>
                </div>
                <% } %>
                <div class="filter-control desktop" data-fieldname="qvd-obj">
                    <label for="obj-qvd-select" data-i18n="Section"></label>
                    <div class="bb-property-obj-selector"></div>
                </div>
            </div>    

            <div class="bb-property-list list-block"></div>
        </div>
    </div>
<%
}
%>