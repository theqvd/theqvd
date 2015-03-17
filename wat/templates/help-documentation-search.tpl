<div class="h1"><span class="js-search-summary" data-i18n="Searching matches for"></span>: "<%= searchKey %>"</div>
<%= HTML_MID_LOADING %>

<%
    $.each(guides, function (guideKey, guideName) {  
        %>
        <div class="bb-<%= guideKey %> js-guide-search" style="display: none;"></div>
        <%
    });
%>