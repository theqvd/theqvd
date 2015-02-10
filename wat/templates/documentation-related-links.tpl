<div class="related-doc">
    <div class="related-doc-title">Related documentation</div>

    <%
    $.each(relatedDoc, function (docSection, docName) {
    %>
        <a href="javascript:" class="fa fa-book button2" data-docsection="<%= docSection %>" data-i18n="<%= docName %>"></a>
    <%
    });
    %>
</div>