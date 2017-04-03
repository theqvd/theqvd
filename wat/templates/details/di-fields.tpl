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