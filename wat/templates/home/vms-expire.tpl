<div class="home-title" data-i18n="VMs close to expire"></div>
<div class="scrollable">
    <%
    if (vms_with_expiration_date.length == 0) {
    %>
        <div class="no-elements" data-i18n="There are no VMS close to expire"></div>
    <%
    }
    else {
    %>
        <table class="summary-table">

        <% 
            $.each(vms_with_expiration_date, function (iExp, exp) {
                var processedRemainingTime = Wat.U.processRemainingTime(exp.remaining_time);
                
                %>
                <tr>
                    <td class="max-1-icons">
                        <i class="fa fa-warning <%= processedRemainingTime.priorityClass %>"></i>
                    </td>                    
                    <td>
                        <%= Wat.C.ifACL('<a href="#/vm/' + exp.id + '">', 'vm.see-details.') %>
                            <%= exp.name %>
                        <%= Wat.C.ifACL('</a>', 'vm.see-details.') %>
                    </td>
                    <td>
                        <span class="summary-data js-summary-users" <%= processedRemainingTime.remainingTimeAttr %> data-countdown data-raw="<%= Wat.U.base64.encodeObj(exp.remaining_time) %>"><%= processedRemainingTime.remainingTime %></span>
                    </td>
                </tr>
                <%
            }); 
        %>
        </table>
    <%
    }
    %>
</div>