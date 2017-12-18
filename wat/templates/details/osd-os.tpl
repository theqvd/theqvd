<div class="fleft setting-row os-row js-os-row js-os-details" data-os="<%= pluginData.get('name') %>">
    <div class="settings-box-element-value" >
        <span class="os-name"><%= pluginData.get('name') %></span>
    </div>
</div>
<% if (mode != 'full') { %>
    <a class="button2 fright fa fa-chevron-<%= mode == 'shrinked' ? 'down' : 'up' %> js-expand-os-conf">More</a>
<% } %>