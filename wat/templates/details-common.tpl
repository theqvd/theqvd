<%
var properties = model.get('properties');
%>

<div class="wrapper-content <%= cid %>">
    <div class="details-side bb-details-side js-side">
    </div>
    <div class="details-block">
        <div class="bb-details details"></div>
        <div class="custom-props-container">
            <span class="details-item fa fa-angle-right">
                <span data-i18n>Other properties</span>
                <%
                if (jQuery.isEmptyObject(properties)) {
                %>
                <div class="indented-data" data-i18n>No properties found</div>
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
    </div>
</div>
<div class="bb-editor-content-test"></div>