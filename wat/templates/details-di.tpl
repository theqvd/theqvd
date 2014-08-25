<div class="details-header">
    <span class="fa fa-dot-circle-o h1" data-i18n><%= model.get('disk_image') %></span>
    <a class="button button-right js-button-edit fa fa-pencil" href="javascript:" data-i18n>Edit</a>
</div>

<div class="details-list">
    <span class="details-item fa fa-angle-right">
        <span data-i18n>Id</span>
        <div class="indented-data">
            <%= model.get('id') %>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <span data-i18n>OS Flavour</span>
        <div class="indented-data">
            <a href="#/osf/<%= model.get('osf_id') %>">
                <%= model.get('osf_name') %>
            </a>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <% 
        if (model.get('blocked')) {
        %>
            <i class="fa fa-lock" data-i18n>Blocked</i>
        <%
        }
        else {
        %>
            <i class="fa fa-unlock" data-i18n>Unblocked</i>
        <%
        }
        %>
    </span>
    
    <%
        if (model.get('default')) {
    %>
            
            <span class="details-item fa fa-angle-right">
                <i class="fa fa-home" data-i18n>Default</i>
            </span>
    
    <%
        }
    %>
            
    <%
        if (model.get('head')) {
    %>
            
            <span class="details-item fa fa-angle-right">
                <i class="fa fa-flag-o" data-i18n>Head</i>
                <div class="indented-data">
                    <div class="second_row" data-i18n="Last image created on this OSF"></div>
                </div>
            </span>
    
    <%
        }
    %>
    
    <span class="details-item fa fa-angle-right">
        <span data-i18n>Tags</span>
        <div class="indented-data">
        <%
            if (!model.get('tags')) {
        %>
                <span class="no-elements" data-i18n="There are not tags"></span>
        <%
            }
        %>
            <ul class="tags">
                <%
                if (model.get('tags')) {
                    $(model.get('tags').split(',')).each( function (index, tag) {
                %>
                        <li class="fa fa-tag"><%= tag %></li>
                <%
                    });
                }
                %>
            </ul>
        </div>
    </span>
</div>