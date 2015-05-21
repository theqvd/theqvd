<div class="side-component js-side-component1">
    <div class="side-header">
        <span class="h2" data-i18n="Related log"></span>
        <% if (Wat.C.checkACL('log.see-main.') && model.get('object_id')) { %>
        <a class="button2 button-right fa fa-arrows-h" href="#/logs/<%= Wat.U.transformFiltersToSearchHash({qvd_object: model.get('qvd_object'), object_id: model.get('object_id')}) %>" data-i18n="Extended view"></a>
        <% } %>
    </div>
    <div class="bb-details-side1">
        <div class="mini-loading"><i class="fa fa-gear fa-spin"></i></div>
    </div>

    <div id="graph-log" style="width:95%;height:200px;">
        <div class="mini-loading" style="padding-top: 70px;"><i class="fa fa-bar-chart-o fa-spin"></i></div>
    </div>
</div>