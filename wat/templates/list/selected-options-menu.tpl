<a class="fright fa fa-times button button-icon js-uncheck-all desktop" style="font-size: 0.8em;" data-cid="<%= cid %>"></a>
<div data-i18n="Actions over selected items" class="title desktop"></div>
        <% 
        $.each(selectedActions, function(action, actionConfig) { 
            if (actionConfig.isEnabledById != undefined && !actionConfig.isEnabledById(selectedItems)) {
                return;
            }
        %>
    <% 
        var visibilityConditionAttrs = Wat.I.getVisibilityConditionAttrs(actionConfig.visibilityCondition);
    %>

    <a class="js-traductable_button 
            js-selected-actions-button 
            actions_button 
            <%= actionConfig.darkButton ? 'button' : 'button2' %> 
            button-icon--mobile 
            <%= actionConfig.iconClass %> 
            <%= actionConfig.otherClass %>" 
        data-cid="<%= cid %>" 
        data-action="<%= action %>" 
        style="width: 100%; 
            margin-bottom: 15px;" 
        name="selected_actions_button_<%= action %>" 
        <%= visibilityConditionAttrs %>
    >
        <span class="desktop" 
            data-cid="<%= cid %>" 
            data-i18n="<%= actionConfig.text %>"
        ></span>
    </a>
        <% }); %>
<div class="selected-elements js-selected-elements">
    <i class="fa fa-check-square-o mobile"></i>
    <span class="fa fa-check-square-o desktop" data=i18n="Selected"><%= $.i18n.t('Selected') %></span>:
    <span class="elements-selected" data-cid="<%= cid %>">0</span>
</div>
<div class="clear mobile"></div>