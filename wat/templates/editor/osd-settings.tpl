<table class="js-editor-table editor-table <%= cid %>">
    <tr>
        <td>
            <table class="col-width-100 list">
                <tr class="js-form-field--settingrow" data-field-name="audio">
                    <th class="col-width-25 center">
                        <i class="fa fa-volume-up"></i>
                        <div data-i18n="Allow sound">Allow sound</div>
                    </th>
                    <th class="col-width-25 center">
                        <i class="fa fa-print"></i>
                        <div data-i18n="Allow printing">Allow printing</div>
                    </th>
                    <th class="col-width-50 center">
                        <i class="fa fa-folder-open-o" style="width: auto;"></i>
                        <i class="fa fa-usb" style="width: auto;"></i>
                        <div data-i18n="Allow folders and USB sharing">Allow folders and USB sharing</div>

                    </th>

                </tr>
                <tr class="js-form-field--settingrow" data-field-name="printers">
                    <td class="cell-check center">
                        <input 
                            type="checkbox" 
                            name="vma.vma_allow_sound" 
                            data-form-field 
                            js-autosave-field
                            <%= model.get('vma_allow_sound') ? 'checked="checked"' : '' %> 
                            class="js-form-field js-form-field--setting" 
                            data-subfield="settings">
                    </td>
                    <td class="cell-check center">
                        <input 
                            type="checkbox" 
                            name="vma.vma_allow_printing" 
                            data-form-field 
                            js-autosave-field
                            <%= model.get('vma_allow_printing') ? 'checked="checked"' : '' %> 
                            class="js-form-field js-form-field--setting" 
                            data-subfield="settings">
                    </td>
                    <td class="cell-check center">
                        <input 
                            type="checkbox" 
                            name="vma.vma_allow_sharing" 
                            data-form-field 
                            js-autosave-field
                            <%= model.get('vma_allow_sharing') ? 'checked="checked"' : '' %> 
                            class="js-form-field js-form-field--setting js-share-folders-check" 
                            data-subfield="settings">
                    </td>
                </tr>
            </table>
        </td>
</table>