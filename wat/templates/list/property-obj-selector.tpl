<select name="obj-qvd-select" class="chosen-single">
    <option data-i18n="All" value="all" <%= selectedObj == "all" ? 'selected' : '' %>></option>
    <option data-i18n="Users" value="user" <%= selectedObj == "user" ? 'selected' : '' %>></option>
    <option data-i18n="Virtual machines" value="vm" <%= selectedObj == "vm" ? 'selected' : '' %>></option>
    <% if (hostPropertiesEnabled) { %>
        <option data-i18n="Nodes" value="host" <%= selectedObj == "host" ? 'selected' : '' %>></option>
    <% } %>
    <option data-i18n="OS Flavours" value="osf" <%= selectedObj == "osf" ? 'selected' : '' %>></option>
    <option data-i18n="Disk images" value="di" <%= selectedObj == "di" ? 'selected' : '' %>></option>
</select>