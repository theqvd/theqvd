<% 
    var footerLinksList = [];

    $.each(footerLinks, function (iFlink, fLink) {
        // If neither label or link are present, ignore
        if (!fLink.label && !fLink.src) {
            return;
        }

        // Links without label will adopt link as label
        if (!fLink.label) {
            fLink.label = fLink.src;
        }

        var label = fLink.label[lan] ? fLink.label[lan] : fLink.label.default;


        if (fLink.src) {
            var src = fLink.src[lan] ? fLink.src[lan] : fLink.src.default;
            footerLinksList.push('<a href="' + src + '" target="_blank" data-i18n="' + label + '">' + label + '</a>');
        }
        else {
            // Links without link will be shown as plain label
            footerLinksList.push('<span data-i18n="' + label + '">' + label + '</span>');
        }
    });
%>

<%= footerLinksList.join(' | ') %>