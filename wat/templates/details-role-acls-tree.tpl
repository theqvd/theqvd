<span data-i18n>Classified by</span>
<select class="js-acl-tree-selector acl-tree-selector">
    <option value="sections" data-i18n>Sections</option>
    <option value="actions" data-i18n>Actions</option>
</select>

<div class="acls-tree js-acls-tree js-sections-tree">
    <%
    $.each(sections, function (branch) {
    %>
        <div class="acls-branch">
            <a class="js-branch-button branch-button fa fa-plus-square-o" href="javascript:" data-branch="<%= branch %>" data-tree-kind="sections" data-open="0"></a>
            <% if (Wat.C.checkACL('role.update.assign-acl')) { %>
                <input type="checkbox" class="js-branch-check branch-check" data-branch="<%= branch %>" data-tree-kind="sections"/>
            <% } %>
                <span class="branch-text">
                    <%= branch %>  
                </span>
        </div>
    <%
    });
    %>
</div>
<div class="acls-tree js-acls-tree js-actions-tree hidden">
    <%
    $.each(actions, function (branch) {
    %>
        <div class="acls-branch">
            <a class="js-branch-button branch-button fa fa-plus-square-o" href="javascript:" data-branch="<%= branch %>" data-tree-kind="actions" data-open="0"></a>
            <% if (Wat.C.checkACL('role.update.assign-acl')) { %>
                <input type="checkbox" class="js-branch-check branch-check" data-branch="<%= branch %>" data-tree-kind="actions"/>
            <% } %>
                <span class="branch-text">
                    <%= branch %>  
                </span>
        </div>
    <%
    });
    %>
</div>