<%
switch (dFieldCode) {
    case 'state':
        %>
        <div data-wsupdate="state-text" data-id="<%= model.get('id') %>">
            <%= $.i18n.t(DICTIONARY_STATES[model.get('state')]) %>
        </div>
        <%
        break;
    case 'address':
        print(model.get('address'))
        break;
    case 'connected_vms':
        if (model.get('number_of_vms_connected') > 0) {
            print(Wat.C.ifACL('<a href="#/vms/' + Wat.U.transformFiltersToSearchHash({host_id: model.get('id')}) + '">', 'vm.see-main.'));
            %> <span data-wsupdate="number_of_vms_connected" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms_connected') %></span> <%
            print(Wat.C.ifACL('</a>', 'vm.see-main.'));
        } else {
            %> <span data-wsupdate="number_of_vms_connected" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms_connected') %></span> <%
        }
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