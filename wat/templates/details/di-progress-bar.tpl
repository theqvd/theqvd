<div data-wsupdate="percentage" data-id="<%= id %>" class="progressbar js-progressbar hidden" data-percent="<%= percentage %>" data-remaining="<%= remainingTime %>" data-elapsed="<%= elapsedTime %>">
    <div class="progress-label js-progress-label">
        <span class="js-progress-label--state"></span>
        <span class="js-progress-label--percentage"></span>
    </div>
</div>
<div class="second_row">
    <div class="js-progressbar-times js-progressbar-times--elapsed hidden">
        <span class="fa fa-hourglass-start">
            <span data-i18n="Elapsed time"></span>: <span class="progress-elapsed">-</span>
        </span>
    </div>
    <div class="js-progressbar-times js-progressbar-times--remaining hidden">
        <span class="fa fa-hourglass-end">
            <span data-i18n="Remaining time"></span>: <span class="progress-remaining">-</span>
        </span>
    </div>
</div>
<% if (state == 'generating' || state == 'uploading') { %>
    <fieldset class="js-progressbar-log-wrapper" data-id="<%= id %>" style="padding: 0px;">
    <legend class="center" data-i18n="Log"></legend>
        <div class="js-progressbar-log progressbar-log">
    </fieldset>
<% } %>
</div>