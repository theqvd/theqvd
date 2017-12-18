<div class="js-vma-details" data-audio="<%= pluginData.get('audio') ? 1 : 0 %>">
    <i class="fa <%= pluginData.get('audio') ? 'fa-check' : 'fa-times' %>"></i><span data-i18n="Allow sound">Allow sound<span>
</div>
<div class="js-vma-details" data-printing="<%= pluginData.get('printing') ? 1 : 0 %>">
    <i class="fa <%= pluginData.get('printing') ? 'fa-check' : 'fa-times' %>"></i><span data-i18n="Allow printing">Allow printing<span>
</div>
<div class="js-vma-details" data-port-forwarding="<%= pluginData.get('portForwarding') ? 1 : 0 %>">
    <i class="fa <%= pluginData.get('portForwarding') ? 'fa-check' : 'fa-times' %>"></i><span data-i18n="Allow folders and USB sharing">Allow folders and USB sharing<span> 
</div>
