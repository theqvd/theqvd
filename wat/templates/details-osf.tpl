<div class="details-header">
    <span class="fa fa-flask h1" data-i18n><%= model.get('name') %></span>
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
        <span data-i18n>Overlay</span>
        <div class="indented-data">
            <%= model.get('overlay') %>
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <span data-i18n>Memory</span>
        <div class="indented-data">
            <%= model.get('memory') %> MB
        </div>
    </span>
    <span class="details-item fa fa-angle-right">
        <span data-i18n>User storage</span>
        <div class="indented-data">
            <%
            if (!model.get('user_storage')) {
            %>
                <span data-i18n="No">
                    <%= i18n.t('No') %>
                </span>
            <%
            }
            else {
                print(model.get('user_storage')  + " MB");
            }
            %>
        </div>
    </span>
</div>