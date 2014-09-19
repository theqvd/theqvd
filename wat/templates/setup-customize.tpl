 <div class="customize-section-selectors">
    <div class="customize-section-selector">
        <label for="obj-qvd-select">Section</label>
        <select name="obj-qvd-select" class="chosen-single">
            <option data-i18n="Users" value="user" <%= selectedSection == "user" ? 'selected' : '' %>></option>
            <option data-i18n="Virtual machines" value="vm" <%= selectedSection == "vm" ? 'selected' : '' %>></option>
            <option data-i18n="Nodes" value="host" <%= selectedSection == "host" ? 'selected' : '' %>></option>
            <option data-i18n="OS Flavours" value="osf" <%= selectedSection == "osf" ? 'selected' : '' %>></option>
            <option data-i18n="Disk images" value="di" <%= selectedSection == "di" ? 'selected' : '' %>></option>
        </select>
    </div>
    <div class="customize-section-selector">
        <label for="tenant-select">Tenant</label>
        <select name="tenant-select" class="chosen-single"></select>
    </div>
</div>
<div class="bb-customize-form">
</div>