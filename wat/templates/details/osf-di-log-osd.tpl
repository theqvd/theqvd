<%
if (Object.keys(images).length == 0) { 
%>
    -
<% 
} 
else { 
%>
    <table class="col-width-100 list js-images-log-list">
        <%
        $.each(images, function (i, image) {
        %>
            <tr data-id="<%= image.id %>">
                <td>
                    <%= image.name + '_' + image.id %>
                </td>
                <td>
                    <div class="progressbar" data-percent="<%= image.percent %>" data-remaining="<%= image.remainingTime %>" data-elapsed="<%= image.elapsedTime %>">
                        <div class="progress-label"><span data-i18n="Loading"></span>...</div>
                    </div>
                    <div class="second_row">
                        <div><span data-i18n="Elapsed time">Elapsed time</span>: <span class="progress-elapsed">-</span></div>
                        <div><span data-i18n="Remaining time">Remaining time</span>: <span class="progress-remaining">-</span></div>
                    </div>
                </td>
            </tr>
        <%
        });
        %>
    </table>
<%
}
%>