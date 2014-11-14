<div class="wrapper-content <%= cid %>">
    <div class="setup-side bb-setup-side js-side">
        <ul class="side-menu">
            <% 
                _.each(setupMenu, function(option, optionName) {
                    var selectedClass = '';
                    if (optionName == selectedOption) {
                        selectedClass = 'selected-option';
                    }
            %>
                    <li>
                        <a href="<%= option.link %>" class="<%= option.iconClass %> <%= selectedClass %>" data-i18n="<%= option.text %>"><%= $.i18n.t(option.text) %></a>
                    </li>
            <%
                });
            %>
        </ul>
    </div>
    <div class="setup-block">
        <div class="bb-setup setup"></div>
    </div>
</div>