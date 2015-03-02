<div class="wrapper-content <%= 'cid' %>"> 
    <div class="menu secondary-menu setup-side">
    <%
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
    
    Read the <a href="http://docs.theqvd.com/" target="_blank">QVD online documentation</a>.

    </div>
    
    <div class="setup-block">
        <div class="bb-doc-text doc-text"></div>
    </div>

</div>

<a class="back-top-button js-back-top-button fa fa-arrow-up button2" style="display:none;" data-i18n>Go top</a>

