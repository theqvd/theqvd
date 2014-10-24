<span data-i18n>Classified by</span>
<select class="js-acl-tree-selector acl-tree-selector">
    <option value="sections" data-i18n>Sections</option>
    <option value="actions" data-i18n>Actions</option>
</select>

<div class="acls-tree js-acls-tree js-sections-tree">
    <%
    $.each(sections, function (branch, branchName) {
    %>
        <div class="acls-branch">
            <a class="js-branch-button branch-button fa fa-plus-square-o" href="javascript:" data-branch="<%= branch %>" data-tree-kind="sections" data-open="0"></a>
                <span class="branch-text" data-i18n="<%= branchName %>"></span>
        </div>
    <%
    });
    %>
</div>
<div class="acls-tree js-acls-tree js-actions-tree hidden">
    <%
    $.each(actions, function (branch, branchName) {
    %>
        <div class="acls-branch">
            <a class="js-branch-button branch-button fa fa-plus-square-o" href="javascript:" data-branch="<%= branch %>" data-tree-kind="actions" data-open="0"></a>
                <span class="branch-text" data-i18n="<%= branchName %>"></span>
        </div>
    <%
    });
    %>
</div>