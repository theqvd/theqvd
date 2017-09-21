<%
switch (dFieldCode) {
    case 'memory':
        print(model.get('memory') + " MB");
        break;
    case 'cpus':
        print(i18n.t('Unknown'));
        break;
    case 'user_storage':
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
        break;
    case 'overlay':
        model.get('overlay') ? print('<span class="fa fa-check"></span>') : print('<span class="fa fa-remove"></span>');
        break;
    case 'vms':
        print(Wat.C.ifACL('<a href="#/vms/' + Wat.U.transformFiltersToSearchHash({osf_id: model.get('id')}) + '">', 'vm.see-main.'));
        %> <span data-wsupdate="number_of_vms" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms') %></span> <%
        print(Wat.C.ifACL('</a>', 'vm.see-main.'));
        break;
    case 'dis':
        print(Wat.C.ifACL('<a href="#/dis/' + Wat.U.transformFiltersToSearchHash({osf_id: model.get('id')}) + '">', 'di.see-main.'));
        %> <span data-wsupdate="number_of_dis" data-id="<%= model.get('id') %>"><%= model.get('number_of_dis') %></span> <%
        print(Wat.C.ifACL('</a>', 'di.see-main.'));
        break;
    case 'dis_log':
        print('<div class="bb-dis-log js-dis-log"></div>');
        break;
    default:
        var commonField = _.template(
            Wat.TPL.detailsFieldsCommon, {
                dFieldCode: dFieldCode,
                model: model
            }
        );
        print(commonField);
        break;
}
%>