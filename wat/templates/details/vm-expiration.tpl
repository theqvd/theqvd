<%
    if (!expiration_soft && !expiration_hard) {
%>
        <div class="no-elements" data-i18n="No"></div>
<%
    }
    else {
        if (remainingTimeHard.expired) {
%>
            <td class="js-details-expiration"><span class="error" data-i18n="Expired"></span></div>
<%
        }
        else {
%>
            <div class="inner-table" class="js-details-expiration">
                <table class="expiration-table">
                    <tbody>
                        <%
                            if (expiration_soft) {
                        %>
                            <tr>
                                <td class="center <%= remainingTimeSoft.priorityClass %>" data-i18n="Soft"></th>
                                <td class="<%= remainingTimeSoft.priorityClass %>"><%= expiration_soft.replace('T',' ') %>
                                <div>
                                    <%
                                        var softRemainingTimeSpan = '<span ' + remainingTimeSoft.remainingTimeAttr + ' data-countdown data-raw="' + time_until_expiration_soft_raw + '">' + remainingTimeSoft.remainingTime + '</span>';
                                    %>
                                    <%= $.i18n.t('Within __remaining_time__', { remaining_time: softRemainingTimeSpan }) %>
                                </div>
                                </td>
                            </tr>
                        <%
                            }
                            if (expiration_hard) {
                        %>
                            <tr>
                                <td class="center <%= remainingTimeHard.priorityClass %>" data-i18n="Hard"></th>
                                <td class="<%= remainingTimeHard.priorityClass %>"><%= expiration_hard.replace('T',' ') %>
                                <div>
                                    <%
                                        var hardRemainingTimeSpan = '<span ' + remainingTimeHard.remainingTimeAttr + ' data-countdown data-raw="' + time_until_expiration_hard_raw + '">' + remainingTimeHard.remainingTime + '</span>';
                                    %>
                                    <%= $.i18n.t('Within __remaining_time__', { remaining_time: hardRemainingTimeSpan }) %>
                                </div>
                                </td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
<%
        }
    }
%>