<div class="home-title" data-i18n="VMs close to expire"></div>
<%
if (vms_with_expiration_date.length == 0) {
%>
    <div class="no-elements" data-i18n="There are not VMS close to expire"></div>
<%
}
else {
%>
    <table class="summary-table">

    <% 
        $.each(vms_with_expiration_date, function (iExp, exp) {
            var processedRemainingTime = Wat.U.processRemainingTime(exp.remaining_time);
    
            var priorityClass = processedRemainingTime.priorityClass;
            var remainingTime = '';
            var remainingTimeAttr = '';
            
            switch (processedRemainingTime.returnType) {
                case 'exact':
                    remainingTime = processedRemainingTime.remainingTime;
                    break;
                case 'days':
                    remainingTimeAttr = 'data-days="' + processedRemainingTime.remainingTime + '"';
                    break;
                case 'months':
                    remainingTimeAttr = 'data-months="' + processedRemainingTime.remainingTime + '"';
                    break;
                case '>year':
                    remainingTimeAttr = 'data-years="' + processedRemainingTime.remainingTime + '"';
                    break;
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