<table>
    <tr>
        <td data-i18n="name"></td>
        <td>
            <input type="text" class="" name="name" value="<%= model.get('name') %>">
        </td>
    </tr>
    <tr>
        <td data-i18n>Disk image's tag</td>
        <td>
            <input type="text" class="" name="name" value="<%= model.get('di_tag') %>">
        </td>
    </tr>
    <tr>
        <td data-i18n>Expire</td>
        <td>
            <input type="checkbox" class="js-change-password" name="change_password" value="1">
        </td>
    </tr>
    <tr class="hidden new_password_row">
        <td data-i18n>Soft expiration</td>
        <td>
            <table>
                <thead>
                    <tr>
                        <th data-h18n>year</th>
                        <th data-h18n>month</th>
                        <th data-h18n>day</th>
                        <th data-h18n>hour</th>
                        <th data-h18n>minute</th>
                        <th data-h18n>second</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><input type="text" name="soft_year" value=""></td>
                        <td><input type="text" name="soft_month" value=""></td>
                        <td><input type="text" name="soft_day" value=""></td>
                        <td><input type="text" name="soft_hour" value=""></td>
                        <td><input type="text" name="soft_minute" value=""></td>
                        <td><input type="text" name="soft_second" value=""></td>
                    </tr>
                </tbody>
            </table>
        </td>
    </tr>
    <tr class="hidden new_password_row">
        <td data-i18n>Hard expiration</td>
        <td>
            <table>
                <thead>
                    <tr>
                        <th data-h18n>year</th>
                        <th data-h18n>month</th>
                        <th data-h18n>day</th>
                        <th data-h18n>hour</th>
                        <th data-h18n>minute</th>
                        <th data-h18n>second</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><input type="text" name="hard_year" value=""></td>
                        <td><input type="text" name="hard_month" value=""></td>
                        <td><input type="text" name="hard_day" value=""></td>
                        <td><input type="text" name="hard_hour" value=""></td>
                        <td><input type="text" name="hard_minute" value=""></td>
                        <td><input type="text" name="hard_second" value=""></td>
                    </tr>
                </tbody>
            </table>
        </td>
    </tr>
 </table>