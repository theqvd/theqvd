<%
switch (dFieldCode) {
    case 'version':
        print(model.get('version'));
        break;
    case 'osf':
        print(Wat.C.ifACL('<a href="#/osf/' + model.get('osf_id') + '" data-i18n="[title]Click for details">', 'osf.see-details.'));
        print(model.get('osf_name'));
        print(Wat.C.ifACL('</a>', 'osf.see-details.'));
        break;
    case 'default':
        %>
            <div class="second_row" data-i18n="Default image for this OSF"></div>
        <%
        break;
    case 'head':
        %>
            <div class="second_row" data-i18n="Last image created on this OSF"></div>
        <%
        break;
    case 'state':
            var statusStr = Wat.I.detailsFields.di.general.fieldList.state.options[model.get('state')].text;
            var icon = Wat.I.detailsFields.di.general.fieldList.state.options[model.get('state')].icon;
            
            if (model.get('status_message')) {
                statusStr += ': ' + model.get('status_message');
            }
            %>
            <span data-wsupdate="state-text" data-id="<%= model.get('id') %>"><%= statusStr %></span>
            
            <div class="bb-di-progress" data-id="<%= model.get('id') %>"></div>
            <%
        break;
    case 'tags':
        if (!model.get('tags')) {
        %>
            <span class="no-elements" data-i18n="There are no tags"></span>
        <%
        }
        %>
        <ul class="tags">
            <%
            if (model.get('tags')) {
                $(model.get('tags').split(',')).each( function (index, tag) {
            %>
                    <li class="fa fa-tag"><%= tag %></li>
            <%
                });
            }
            %>
        </ul>
        <%
        break;
    case 'auto_publish':
        if (model.get('auto_publish')) {
        %>
            <span data-i18n="When publish"></span>
        <%
        }
        else {
        %>
            <span data-i18n="No"></span>
        <%
        }
        break;
    case 'expire_vms':
        if (model.get('expiration_time_hard') === null) {
        %>
            <span data-i18n="No"></span>
        <%
        }
        else if (model.get('expiration_time_hard') === 0) {
        %>
            <span data-i18n="When publish"></span>
        <%
        }
        else if (model.get('expiration_time_hard') > 0) {
            var expirationTime = Wat.U.secondsToHms(model.get('expiration_time_hard'), 'strLong');
            print(i18n.t('__time__ after publication', {
                        time: expirationTime
                    }));
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