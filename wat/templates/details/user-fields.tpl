<%
switch (dFieldCode) {
    case 'global_username':
        print(Wat.C.getLoginData(model.get('name'), model.get('tenant_name')));
        break;
    case 'connected_vms':
        if (model.get('number_of_vms') > 0) {
            print(Wat.C.ifACL('<a href="#/vms/' + Wat.U.transformFiltersToSearchHash({user_id: model.get('id')}) + '">', 'vm.see-main.'));
            %>
            <span data-wsupdate="number_of_vms_connected" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms_connected') %></span>
            /
            <span data-wsupdate="number_of_vms" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms') %></span>
            <%
            print(Wat.C.ifACL('</a>', 'vm.see-main.'));
        } else {
        %>
            <span data-wsupdate="number_of_vms_connected" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms_connected') %></span>
            /
            <span data-wsupdate="number_of_vms" data-id="<%= model.get('id') %>"><%= model.get('number_of_vms') %></span>
        <%
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