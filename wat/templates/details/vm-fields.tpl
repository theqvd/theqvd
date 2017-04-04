<%
switch (dFieldCode) {
    case 'user':
        print(Wat.C.ifACL('<a href="#/user/' + model.get('user_id') + '" data-i18n="[title]Click for details">', 'user.see-details.'));
            print(model.get('user_name'));
        print(Wat.C.ifACL('</a>', 'user.see-details.'));

        if (Wat.C.checkACL('vm.see.user-state')) { 
            if (model.get('user_state') == 'connected') {
        %>
                (<span data-i18n data-wsupdate="user_state-text" data-id="<%= model.get('id') %>">Connected</span>)
        <%
            }
            else {
        %>
                (<span data-i18n data-wsupdate="user_state-text" data-id="<%= model.get('id') %>">Disconnected</span>)
        <%
            }
        }
        break;
    case 'ip':
        print(model.get('ip'))
        break;
    case 'mac':
        print(model.get('mac'))
        break;
    case 'osf':
        print(Wat.C.ifACL('<a href="#/osf/' + model.get('osf_id') + '" data-i18n="[title]Click for details">', 'osf.see-details.'));
            print(model.get('osf_name'));
        print(Wat.C.ifACL('</a>', 'osf.see-details.'));
        break;
    case 'tag':
        print(model.get('di_tag'));
        break;
    case 'disk_image':
        print(Wat.C.ifACL('<a href="#/di/' + model.get('di_id') + '" data-i18n="[title]Click for details">', 'di.see-details.'));
            print(model.get('di_name'));
        print(Wat.C.ifACL('</a>', 'di.see-details.'));

        if (model.get('state') == 'running' && model.get('di_id') != model.get('di_id_in_use')) {
        %>
            <i class="fa fa-warning warning" data-wsupdate="di_warning_icon" data-id="<%= model.get('id') %>" data-i18n="[title]The virtual machine is running with different image - Restart it to update it to new image"></i>
        <%
        }
        %>
        <div class="second_row"><span data-i18n="Version"></span>: <%= model.get('di_version') %></span>
        <%
        break;
    case 'expiration':
        %>
        <div class="bb-vm-details-expiration" data-wsupdate="expiration_soft-row" data-id="<%= model.get('id') %>" data-expiration_soft="<%= model.get('expiration_soft') %>" data-expiration_hard="<%= model.get('expiration_hard') %>"></div>
        <%
        break;
    case 'state':
        %>
        <div data-wsupdate="state-text" data-id="<%= model.get('id') %>">
            <%= $.i18n.t(DICTIONARY_STATES[model.get('state')]) %>
        </div> 
        <%
        break;
    case 'host':
        %>
        <div data-wsupdate="host" data-id="<%= model.get('id') %>">
            <%
            var hostHtml = '-';
            if (Wat.C.checkACL('vm.see.host')) {
                hostHtml = Wat.C.ifACL('<a href="#/host/' + model.get('host_id') + '">', 'host.see-details.') + model.get('host_name') ? model.get('host_name') : '' + Wat.C.ifACL('</a>', 'host.see-details.');
            }
            print(hostHtml);
            %>
        </div>
        <%
        break;
    case 'ssh_port':
        %>
        <div data-wsupdate="ssh_port" data-id="<%= model.get('id') %>">
            <%= model.get('ssh_port') == "0" ? '-' : model.get('ssh_port') %>
        </div>
        <%
        break;
    case 'vnc_port':
        %>
        <div data-wsupdate="vnc_port" data-id="<%= model.get('id') %>">
            <%= model.get('vnc_port') == "0" ? '-' : model.get('vnc_port') %>
        </div>
        <%
        break;
    case 'serial_port':
        %>
        <div data-wsupdate="serial_port" data-id="<%= model.get('id') %>">
            <%= model.get('serial_port') == "0" ? '-' : model.get('serial_port') %>
        </div>
        <%
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