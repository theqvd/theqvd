<div class="<%= cid %> sec-list-<%= qvdObj %>">
    <div class="list-navigation">
        <div class="fleft col-width-80 desktop">
            <span data-i18n="Active configuration"></span>: <select style="width: 20%"; name="active_configuration_select"></select>
        </div>
        <% if (pagination) { %>
            <div class="pagination js-pagination">
                <a class="fa fa-step-backward first button2"></a>
                <a class="fa fa-caret-left prev button2"></a>
                <span class="pagination_current_page"><input type="text" class="js-current-page current-page" val="1"/></span> / <span class="pagination_total_pages">1</span>
                <a class="fa fa-caret-right next button2"></a>
                <a class="fa fa-step-forward last button2"></a>
            </div>
        <% } %>
    </div>
    <div class="list bb-list js-list">

    </div>
    <% if (pagination) { %>
        <div class="shown-elements js-shown-elements second_row">
            <span data=i18n="Shown"><%= $.i18n.t('Shown') %></span>:
            <span class="elements-shown"></span>
            /
            <span class="elements-total"></span>
        </div>
    <% } %>
    <div class="clear"></div>
    <div class="fright desktop" style="padding-left: 50%; padding-top: 120px; width: 100%;">
        <a class="button fleft <%= viewMode == 'grid' ? 'disabled' : '' %> fa fa-th-large js-change-viewmode" name="viewmode-grid" data-viewmode="grid" href="javascript:">Grid</a>
        <a class="button fleft <%= viewMode == 'list' ? 'disabled' : '' %> fa fa-th-list js-change-viewmode" name="viewmode-list" data-viewmode="list" href="javascript:" style="margin-left: 10px;">List</a>
        <!--
        <a class="button button-icon <%= viewMode == 'grid' ? 'disabled' : '' %> fa fa-th-large js-change-viewmode" name="viewmode-grid" data-viewmode="grid" href="javascript:"></a>
        <a class="button button-icon <%= viewMode == 'list' ? 'disabled' : '' %> fa fa-th-list js-change-viewmode" name="viewmode-list" data-viewmode="list" href="javascript:"></a>
        -->
    </div>
</div>