<div class="related-doc">
    <%
    $.each(relatedDoc, function (docSection, docName) {
        if (Up.I.docSections[docSection] == undefined || !Up.C.isValidDocGuide(Up.I.docSections[docSection].guide)) {
            return;    
        }
    %>
        <a href="javascript:" class="fa fa-book button2" data-docsection="<%= docSection %>" data-i18n="<%= docName %>"></a>
    <%
    });
    %>
</div>