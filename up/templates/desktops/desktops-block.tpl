<div class="list-block <%= cid %>">
    <div class="list-navigation">
        <div class="fleft col-width-80 desktop">
            <span data-i18n="Active configuration"></span>: <select style="width: 20%"; name="active_configuration_select"></select>
        </div>
        <div class="bb-pagination"></div>
    </div>
    <div class="list bb-list js-list"></div>
    <div class="bb-pagination-info"></div>
    <div class="clear"></div>
    <div class="fright desktop" style="padding-left: 50%; padding-top: 20px; width: 100%;">
        <a class="button fleft <%= viewMode == 'grid' ? 'disabled' : '' %> fa fa-th-large js-change-viewmode" name="viewmode-grid" data-viewmode="grid" href="javascript:">Grid</a>
        <a class="button fleft <%= viewMode == 'list' ? 'disabled' : '' %> fa fa-th-list js-change-viewmode" name="viewmode-list" data-viewmode="list" href="javascript:" style="margin-left: 10px;">List</a>
    </div>
</div>