<div class="<%= cid %> list-wrapper">
<h1 class="h1 fleft"><i class="fa fa-cloud"></i><span data-i18n="My virtual machines"></span></h1>
<fieldset class="profile-select js-profile-select fright">
    <legend class="left" data-i18n="Connection profile" style="margin-bottom: 3px;"></legend>
    <select name="connection_profile">
        <option>Office</option>
        <option>Home</option>
        <option>Outdoor (Public network)</option>
    </select>
</fieldset>
<div style="clear: both;"></div>
<div class="list-navigation">
        <div class="fleft col-width-40 desktop">
            <a class="button button-icon <%= viewMode == 'grid' ? 'disabled' : '' %> fa fa-th-large js-change-viewmode" name="viewmode-grid" data-viewmode="grid" href="javascript:"></a>
            <a class="button button-icon <%= viewMode == 'list' ? 'disabled' : '' %> fa fa-th-list js-change-viewmode" name="viewmode-list" data-viewmode="list" href="javascript:"></a>
        </div>
        <div class="pagination">
            <a class="fa fa-step-backward first button2"></a>
            <a class="fa fa-caret-left prev button2"></a>
            <span class="pagination_current_page">1</span>/<span class="pagination_total_pages">1</span>
            <a class="fa fa-caret-right next button2"></a>
            <a class="fa fa-step-forward last button2"></a>
        </div>
    </div>
    <div class="list bb-list">

    </div>
    <div class="shown-elements second_row">
        <span data=i18n="Shown"><%= $.i18n.t('Shown') %></span>:
        <span class="elements-shown"></span>
        /
        <span class="elements-total"></span>
    </div>
</div>
