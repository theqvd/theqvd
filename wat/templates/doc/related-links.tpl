<div class="related-doc">
    <%
    $.each(relatedDoc, function (docSection, docName) {
        if (Wat.I.docSections[docSection] == undefined || !Wat.C.isValidDocGuide(Wat.I.docSections[docSection].guide)) {
            return;    
        }
    %>
        <a href="javascript:" class="fa fa-book button2" data-docsection="<%= docSection %>" data-i18n="<%= docName %>"></a>
    <%
    });
    %>
</div>