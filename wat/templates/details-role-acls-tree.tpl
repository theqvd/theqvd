<div class="acls-tree">
    <%
    $.each(sections, function (branch) {
        if (branch == '-1') {
            return;
        }
    %>
        <div class="acls-branch">
            <input type="checkbox" class="js-branch-check" data-branch="<%= branch %>"/>
            <a class="js-branch-button branch-button fa fa-plus-square-o" href="javascript:" data-branch="<%= branch %>" data-open="0"></a>
                <%= branch %>  
        </div>
    <%
    });
    %>
</div>