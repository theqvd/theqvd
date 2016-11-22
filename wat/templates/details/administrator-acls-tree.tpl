<span data-i18n="Classified by"></span>
<select class="js-acl-tree-selector acl-tree-selector" name="tree_mode">
    <option value="sections" data-i18n="Sections"></option>
    <option value="actions" data-i18n="Actions"></option>
</select>

<div class="acls-tree js-acls-tree js-sections-tree">
    <%
    var nBranches = 0;
    $.each(sections, function (branch, branchName) {
        var pattern = aclPatterns[branch];
        
        var disabledClass = '';
        var invisibleClass = '';
        var hiddenClass = '';
        if (branchStats[pattern].effective == 0) {
            disabledClass = 'disabled-branch';
            invisibleClass = 'invisible';
            hiddenClass = 'hidden';
        }
        else {
            nBranches++;
        }
    %>
        <div class="acls-branch js-acls-branch <%= hiddenClass %>" data-branch="<%= branch %>">
            <a class="js-branch-button branch-button fa fa-plus-square-o <%= invisibleClass %>" href="javascript:" data-branch="<%= branch %>" data-tree-kind="sections" data-open="0"></a>
            <span class="branch-text js-branch-text event" data-i18n="<%= branchName %>"><%= $.i18n.t(branchName) %></span>
        </div>
    <%
    });
    if (nBranches == 0) {
    %>
        <span class="no-elements" data-i18n="There are no elements">
            <%= i18n.t('There are no elements') %>
        </span>
    <%
    }
    %>
</div>
<div class="acls-tree js-acls-tree js-actions-tree hidden">
    <%
    var nBranches = 0;
    $.each(actions, function (branch, branchName) {
        var pattern = aclPatterns[branch];
        
        var disabledClass = '';
        var invisibleClass = '';
        var hiddenClass = '';
        
        if (branchStats[pattern].effective == 0) {
            disabledClass = 'disabled-branch';
            invisibleClass = 'invisible';
            var hiddenClass = 'hidden';
        }
        else {
            nBranches++;
        }
    %>
        <div class="acls-branch js-acls-branch <%= hiddenClass %>" data-branch="<%= branch %>">
            <a class="js-branch-button branch-button fa fa-plus-square-o <%= invisibleClass %>" href="javascript:" data-branch="<%= branch %>" data-tree-kind="actions" data-open="0"></a>
            <span class="branch-text js-branch-text event" data-i18n="<%= branchName %>"><%= $.i18n.t(branchName) %></span>
        </div>
    <%
    });
    if (nBranches == 0) {
    %>
        <span class="no-elements" data-i18n="There are no elements">
            <%= i18n.t('There are no elements') %>
        </span>
    <%
    }
    %>
</div>