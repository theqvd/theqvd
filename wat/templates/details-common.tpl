<%
var customProps = model.get('customProps');
%>

<div class="wrapper-content">
    <div class="details-side bb-details-side js-side">
    </div>
    <div class="details-block">
        <div class="bb-details"></div>
        <div class="custom-props-container">
            <table class="custom-props">
                <tbody>
                    <% _.each(customProps, function(val, key) { %>
                        <tr>
                            <td data-i18n><%= key %></td>
                            <td>
                                <%= val %>
                            </td>
                        </tr>
                    <% }); %>

                </tbody>
            </table>
        </div>
    </div>
</div>
<div class="bb-editor-content-test"></div>