<%
var properties = model.get('properties');
%>

<div class="wrapper-content <%= cid %>">
    <div class="details-side bb-details-side js-details-side js-side">
    </div>
    <div class="details-block js-details-block">
        <div class="bb-details details"></div>
        <%
            if (enabledProperties) {
        %>
            <div class="custom-props-container">
                <span class="details-item">
                    <span data-i18n="Other properties"></span>
                    <%
                    if (jQuery.isEmptyObject(properties)) {
                    %>
                    <div class="indented-data no-elements">
                        <span class="no-elements" data-i18n="There are not properties"></span>
                    </div>
                    <%
                    }
                    else {
                    %>
                        <table class="custom-props indented-data">
                            <tbody>
                                <% _.each(properties, function(val, key) { %>
                                    <tr>
                                        <td><%= key %></td>
                                        <td>
                                            <%= val %>
                                        </td>
                                    </tr>
                                <% }); %>

                            </tbody>
                        </table>

                    <%
                    }
                    %>
                </span>
            </div>
        <%
            }
        %>
    </div>
</div>