<span data-i18n="Classified by"></span>
<select class="js-acl-tree-selector acl-tree-selector">
    <option value="sections" data-i18n="Sections"></option>
    <option value="actions" data-i18n="Actions"></option>
</select>

<div class="acls-tree js-acls-tree js-sections-tree">
    <%
    $.each(sections, function (branch, branchName) {
        var pattern = aclPatterns[branch];
        
        var isEditable = Up.C.checkACL('role.update.assign-acl') && (!model.get('fixed') || !RESTRICT_TEMPLATES);
        
        // If there are not ACLS in system for this pattern, not draw branch
        if (branchStats[pattern].total == 0) {
            return;
        }
        
        var disabledClass = '';
        var hiddenClass = '';
        if (branchStats[pattern].effective == 0) {
            if (isEditable) {
            disabledClass = 'disabled-branch';
        }       
            else {
                hiddenClass = 'hidden';
            }
        }       
        
        var checked = '';
        if (branchStats[pattern].effective == branchStats[pattern].total) {
            checked = 'checked';
        }   
    %>
        <div class="acls-branch js-acls-branch <%= disabledClass %> <%= hiddenClass %>" data-branch="<%= branch %>">
            <% if (isEditable) { %>
                <input type="checkbox" class="js-branch-check branch-check" data-branch="<%= branch %>" data-tree-kind="sections" <%= checked %>/>
            <% } %>
            <a class="js-branch-button branch-button fa fa-plus-square-o" href="javascript:" data-branch="<%= branch %>" data-tree-kind="sections" data-open="0"></a>
                <span class="branch-text js-branch-text event" data-i18n="<%= branchName %>"><%= $.i18n.t(branchName) %></span>
                <span class="js-count-wrapper count-wrapper <%= branchStats[pattern].effective != branchStats[pattern].total ? 'count-wrapper--disabled' : '' %>">
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
        
        var isEditable = Up.C.checkACL('role.update.assign-acl') && (!model.get('fixed') || !RESTRICT_TEMPLATES);
        
        // If there are not ACLS in system for this pattern, not draw branch
        if (branchStats[pattern].total == 0) {
            return;
        }
        
        var disabledClass = '';
        var hiddenClass = '';
        if (branchStats[pattern].effective == 0) {
            if (isEditable) {
            disabledClass = 'disabled-branch';
        }       
            else {
                hiddenClass = 'hidden';
            }
        }       
        
        var checked = '';
        if (branchStats[pattern].effective == branchStats[pattern].total) {
            checked = 'checked';
        }  
    %>
        <div class="acls-branch js-acls-branch <%= disabledClass %> <%= hiddenClass %>" data-branch="<%= branch %>">
            <% if (isEditable) { %>
                <input type="checkbox" class="js-branch-check branch-check" data-branch="<%= branch %>" data-tree-kind="actions" <%= checked %>/>
            <% } %>
            <a class="js-branch-button branch-button fa fa-plus-square-o" href="javascript:" data-branch="<%= branch %>" data-tree-kind="actions" data-open="0"></a>
                <span class="branch-text js-branch-text event" data-i18n="<%= branchName %>"><%= $.i18n.t(branchName) %></span>
                <span class="js-count-wrapper count-wrapper <%= branchStats[pattern].effective != branchStats[pattern].total ? 'count-wrapper--disabled' : '' %>">
                    (<span class="js-effective-count"><%= branchStats[pattern].effective %></span>/<span class="js-effective-count"><%= branchStats[pattern].total %></span>)
                </span>
        </div>
    <%
    });
    %>
</div>