<div class="side-component js-side-component1">
    <div class="side-header">
        <span class="h2" data-i18n="Virtual machines"></span>
        <% if (Wat.C.checkACL('vm.see-main.')) { %>
        <a class="button2 button-right fa fa-arrows-h" href="#/vms/<%= Wat.U.transformFiltersToSearchHash({user_id: model.get('id')}) %>" data-i18n="Extended view"></a>
        <% } %>
    </div>
    <div class="bb-details-side1">
        <div class="mini-loading"><i class="fa fa-gear fa-spin"></i></div>
    </div>
</div>

<div class="side-component js-side-component2">
    <div class="side-header">
        <span class="h2" data-i18n="Log"></span>
        <% if (Wat.C.checkACL('log.see-main.')) { %>
        <a class="button2 button-right fa fa-arrows-h" href="#/logs/<%= Wat.U.transformFiltersToSearchHash({qvd_object: Wat.CurrentView.qvdObj, object_id: model.get('id')}) %>" data-i18n="Extended view"></a>
        <% } %>
    </div>
    <div class="bb-details-side2">
        <div class="mini-loading"><i class="fa fa-gear fa-spin"></i></div>
    </div>

    <div id="graph-log" style="width:95%;height:200px;">
        <div class="mini-loading" style="padding-top: 70px;"><i class="fa fa-bar-chart-o fa-spin"></i></div>
    </div>
</div>