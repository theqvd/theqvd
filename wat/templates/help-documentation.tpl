<div class="wrapper-content <%= 'cid' %>"> 
    <div class="menu secondary-menu setup-side">
    <%
        guides = {
            'introduction': 'Introduction',
            'stepbystep': 'WAT Step by step', 
            'user': 'User guide',
            'multitenant': 'Multitenant guide'
        };

        $.each(guides, function (guideKey, guideText) {
        var currentClass = '';
        if (selectedGuide == guideKey) {
            currentClass = 'lateral-menu-option--selected';
        }
    %>
            <ul>
                    <li class="lateral-menu-option js-doc-option <%= currentClass %>" data-guide="<%= guideKey %>">
                        <span data-i18n data-guide="<%= guideKey %>"><%= guideText %></span>
                    </li>
            </ul>
    <%
        });
    %>
    
    </div>
    
    <div class="setup-block">
        <div class="bb-doc-text doc-text"></div>
    </div>

</div>

Read the <a href="http://docs.theqvd.com/" target="_blank">QVD online documentation</a>.

