<%
var tags = [];
var tagHead = false;
var tagDefault = false;

$(model.get('tags')).each( function (index, tag) {
    if (tag.tag == 'head') {
        tagHead = true;
    }
    else if (tag.tag == 'default') {
        tagDefault = true;
    }
    else {
        tags.push(tag.tag);
    }
});

%>
                
<div class="h1">
    <span class="fa fa-file" data-i18n><%= model.get('disk_image') %></span>
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
        <span data-i18n>Default</span>
        <div class="indented-data">
            <%
                if (tagDefault) {
            %>
                    <span data-i18n="Yes">
                        <%= i18n.t('Yes') %>
                    </span>
            <%
                }
                else {
            %>
                    <span data-i18n="No">
                        <%= i18n.t('No') %>
                    </span>
            <%
                }
            %>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <span data-i18n>Head</span>
        <div class="indented-data">
            <%
                if (tagHead) {
            %>
                    <span data-i18n="Yes">
                        <%= i18n.t('Yes') %>
                    </span>
            <%
                }
                else {
            %>
                    <span data-i18n="No">
                        <%= i18n.t('No') %>
                    </span>
            <%
                }
            %>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <span data-i18n>Tags</span>
        <div class="indented-data">
            <ul class="tags">
                <%
                $(tags).each( function (index, tag) {
                %>
                    <li><%= tag %></li>
                <%
                });
                %>
            </ul>
        </div>
    </span>
</div>