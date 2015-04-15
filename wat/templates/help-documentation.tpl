<div class="wrapper-content <%= cid %>"> 
    <div class="menu secondary-menu setup-side">
        <div class="doc-search-box">
            <label for="doc_search" data-i18n="Search"></label>
            <input name="doc_search" class="js-doc-search" value="<%= searchKey %>"/>
        </div>
        
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
        
        <ul>
            <li class="lateral-menu-option-discrete">
                <a href="http://docs.theqvd.com/" target="_blank" data-i18n="Read the QVD online documentation"></a>.
            </li>
        </ul>
    </div>
    
    <div class="setup-block">
        <div class="bb-doc-text doc-text"></div>
    </div>

</div>

<a class="back-top-button js-back-top-button js-back-top-doc-button fa fa-arrow-up button2" style="display:none;" data-i18n>Go top</a>

