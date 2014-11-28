<div class="home-title" data-i18n>VMs close to expire</div>
<%
if (vms_with_expiration_date.length == 0) {
%>
    <div class="no-elements" data-18n>There are not VMS close to expire</div>
<%
}
else {
%>
    <table class="summary-table">

    <% 
        $.each(vms_with_expiration_date, function (iExp, exp) {
            var priorityClass = '';
            var remainingTime = '';
            var remainingTimeAttr = '';
            if (exp.remaining_time.days < 1) {
                priorityClass = 'error';
                remainingTime = exp.remaining_time.hours + ':' + exp.remaining_time.minutes + ':' + exp.remaining_time.seconds;
            }
            else if(exp.remaining_time.days < 7) {
                priorityClass = 'warning';
                remainingTimeAttr = 'data-days="' + exp.remaining_time.days + '"';
            }
            else {
                priorityClass = 'ok';
                remainingTimeAttr = 'data-days="+7"';
            }                    
            %>
            <tr>
                <td class="max-1-icons">
                    <i class="fa fa-warning <%= priorityClass %>"></i>
                </td>                    
                <td>
                    <%= Wat.C.ifACL('<a href="#/vm/' + exp.id + '">', 'vm.see-details.') %>
                        <%= exp.name %>
                    <%= Wat.C.ifACL('</a>', 'vm.see-details.') %>
                </td>
                <td>
                    <span class="summary-data js-summary-users" <%= remainingTimeAttr %>><%= remainingTime %></span>
                </td>
            </tr>
            <%
        }); 
    %>
    </table>
<%
}
%>