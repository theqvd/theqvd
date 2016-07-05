<div class="<%= remainingTime.priorityClass %>" <%= remainingTime.remainingTimeAttr %> data-countdown data-raw="<%= time_until_expiration_raw %>">
    <%= remainingTime.remainingTime %>
</div>
<div class="second_row">
    <%= expiration ? expiration.replace('T',' ') : '' %>
</div>