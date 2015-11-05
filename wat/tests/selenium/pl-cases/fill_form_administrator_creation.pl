WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=select[name=\"tenant_id\"] option") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
my $actionIndex = $sel->get_element_index("css=select[name=\"tenant_id\"] option[value=\"1\"]");
$sel->click_at_ok("css=#tenant_editor_chosen", "");
$sel->click_at_ok("css=div#tenant_editor_chosen .chosen-results [data-option-array-index=" . $actionIndex . "]", "");
$sel->type_ok("css=div.js-editor-container-create input[name=\"name\"]", "selenita");
$sel->type_ok("css=div.js-editor-container-create textarea[name=\"description\"]", "My description");
$sel->type_ok("css=div.js-editor-container-create input[name=\"password\"]", "selenita");
$sel->type_ok("css=div.js-editor-container-create input[name=\"password2\"]", "selenita");
$sel->click_at_ok("css=span.js-button-create", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=tr[data-name=\"selenita\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
