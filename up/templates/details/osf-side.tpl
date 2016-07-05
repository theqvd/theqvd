<div class="side-component js-side-component1">
    <div class="side-header">
        <span class="h2" data-i18n="Disk images"></span>
        <% if (Up.C.checkACL('vm.see-main.')) { %>
        <a class="button2 button-right fa fa-arrows-h" href="#/dis/<%= Up.U.transformFiltersToSearchHash({osf_id: model.get('id')}) %>" data-i18n="Extended view"></a>
        <% } %>
    </div>
    <div class="bb-details-side1">
        <div class="mini-loading"><i class="fa fa-gear fa-spin"></i></div>
    </div>
</div>

<div class="side-component js-side-component2">
    <div class="side-header">
        <span class="h2" data-i18n="Virtual machines"></span>
        <% if (Up.C.checkACL('di.see-main.')) { %>
        <a class="button2 button-right fa fa-arrows-h" href="#/vms/<%= Up.U.transformFiltersToSearchHash({osf_id: model.get('id')}) %>" data-i18n="Extended view"></a>
        <% } %>
    </div>
    <div class="bb-details-side2">
        <div class="mini-loading"><i class="fa fa-gear fa-spin"></i></div>
    </div>
</div>

<div class="side-component js-side-component3">
    <div class="side-header">
        <span class="h2" data-i18n="Log"></span>
        <% if (Up.C.checkACL('log.see-main.')) { %>
        <a class="button2 button-right fa fa-arrows-h" href="#/logs/<%= Up.U.transformFiltersToSearchHash({qvd_object: Up.CurrentView.qvdObj, object_id: model.get('id')}) %>" data-i18n="Extended view"></a>
        <% } %>
    </div>
    <div class="bb-details-side3">
        <div class="mini-loading"><i class="fa fa-gear fa-spin"></i></div>
    </div>

    <div id="graph-log" style="width:95%;height:200px;">
        <div class="mini-loading" style="padding-top: 70px;"><i class="fa fa-bar-chart-o fa-spin"></i></div>
    </div>
</div>