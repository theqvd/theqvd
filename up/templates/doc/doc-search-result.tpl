<div class="h2">
    <span data-i18n="Guide"></span>:
    <span data-i18n="<%= guideName %>"></span>:
    (<%= guideMatches %>)
</div>

<div class="search-matchs">
<%
$.each(matchsTree, function (section, params) {
    var matchUrl = '#documentation/' + guide;

    if (params.guide_introduction == undefined) {
        matchUrl += '/' + section;
    }
    %>
        <a href="<%= matchUrl %>"><%= matchsDictionary[section] + ' (' + params.nmatches + ')' %></a><br>
    <%
}); 
%>
</div>