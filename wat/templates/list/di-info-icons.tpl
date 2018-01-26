<% $.each(statesList, function (key, values) { %>
    <i class="<%= values.icon %> js-progress-icon js-progress-icon--<%= key %> <%= model.get('state') != key ? 'hidden' : '' %>" data-i18n="[title]<%= values.text %>"></i>
<% }); %>

<i class="fa fa-road js-future-tags-icon <%= hiddenIfPublished %>" data-model-function="renderFutureTags" data-id="<%= model.get('id') %>"></i>

<%
if (model.get('tags') && (!infoRestrictions || infoRestrictions.tags)) {
%>
    <i class="fa fa-tags js-tags-icon <%= hiddenIfNotPublished %>" data-model-function="renderTags" data-id="<%= model.get('id') %>"></i>
<%
}

if (model.get('head') && (!infoRestrictions || infoRestrictions.head)) {
%>
    <i class="fa fa-flag-o js-head-icon <%= hiddenIfNotPublished %>" title="head"></i>
<%
}

if (model.get('default') && (!infoRestrictions || infoRestrictions.default)) {
%>
    <i class="fa fa-home js-default-icon <%= hiddenIfNotPublished %>" title="default"></i>
<%
}

if (model.get('blocked') && (!infoRestrictions || infoRestrictions.block)) {
%>
    <i class="fa fa-lock" data-i18n="[title]Blocked" title="<%= i18n.t('Blocked') %>"></i>
<%
}

if (model.get('auto_publish')) {
%>
    <i class="fa fa-rocket js-auto-publish-icon <%= hiddenIfReadyOrPublished %>" data-i18n="[title]Will be published after generation" title="<%= i18n.t('Will be published after publication') %>"></i>
<%
}

if (model.get('expiration_time_hard') != null) {
    var expirationTime = Wat.U.secondsToHms(model.get('expiration_time_hard'), 'strLong');
%>
    <i class="fa fa-hourglass-half js-expiration-icon <%= hiddenIfPublished %>" title="<%= i18n.t('Affected machines will expire') %>: <%= i18n.t('__time__ after publication', {
        time: expirationTime
    }) %>"></i>
<%
}
%>