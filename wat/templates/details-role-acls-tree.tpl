<span data-i18n="Classified by"></span>
<select class="js-acl-tree-selector acl-tree-selector">
    <option value="sections" data-i18n="Sections"></option>
    <option value="actions" data-i18n="Actions"></option>
</select>

<div class="acls-tree js-acls-tree js-sections-tree">
    <%
    $.each(sections, function (branch, branchName) {
        var pattern = aclPatterns[branch];
        
        var disabledClass = '';
        if (branchStats[pattern].effective == 0) {
            disabledClass = 'disabled-branch';
        }       
        
        var checked = '';
        if (branchStats[pattern].effective == branchStats[pattern].total) {
            checked = 'checked';
        }   
    %>
        <div class="acls-branch js-acls-branch <%= disabledClass %>" data-branch="<%= branch %>">
            <a class="js-branch-button branch-button fa fa-plus-square-o" href="javascript:" data-branch="<%= branch %>" data-tree-kind="sections" data-open="0"></a>
            <% if (Wat.C.checkACL('role.update.assign-acl') && (!model.get('fixed') || !RESTRICT_INTERNAL_ROLES)) { %>
                <input type="checkbox" class="js-branch-check branch-check" data-branch="<%= branch %>" data-tree-kind="sections" <%= checked %>/>
            <% } %>
                <span class="branch-text" data-i18n="<%= branchName %>"><%= $.i18n.t(branchName) %></span>
                <span class="second_row">
                    (<span class="js-effective-count" data-branch="<%= branch %>"><%= branchStats[pattern].effective %></span>/<span class="js-total-count" data-branch="<%= branch %>"><%= branchStats[pattern].total %></span>)
                </span>
        </div>
    <%
    });
    %>
</div>
<div class="acls-tree js-acls-tree js-actions-tree hidden">
    <%
    $.each(actions, function (branch, branchName) {
        var pattern = aclPatterns[branch];
        
        var disabledClass = '';
        if (branchStats[pattern].effective == 0) {
            disabledClass = 'disabled-branch';
        }       
        
        var checked = '';
        if (branchStats[pattern].effective == branchStats[pattern].total) {
            checked = 'checked';
        }  
    %>
        <div class="acls-branch js-acls-branch <%= disabledClass %>" data-branch="<%= branch %>">
            <a class="js-branch-button branch-button fa fa-plus-square-o" href="javascript:" data-branch="<%= branch %>" data-tree-kind="actions" data-open="0"></a>
            <% if (Wat.C.checkACL('role.update.assign-acl') && (!model.get('fixed') || !RESTRICT_INTERNAL_ROLES)) { %>
                <input type="checkbox" class="js-branch-check branch-check" data-branch="<%= branch %>" data-tree-kind="actions" <%= checked %>/>
            <% } %>
                <span class="branch-text" data-i18n="<%= branchName %>"><%= $.i18n.t(branchName) %></span>
                <span class="second_row">
                    (<span class="js-effective-count"><%= branchStats[pattern].effective %></span>/<span class="js-effective-count"><%= branchStats[pattern].total %></span>)
                </span>
        </div>
    <%
    });
    %>
</div>