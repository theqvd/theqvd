$sel->click_at_ok("css=a.js-button-edit", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.js-editor-container-edit") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
my $actionIndex = $sel->get_element_index("css=select[name=\"language\"] option[value=\"es\"]");
$sel->click_at_ok("css=#language_chosen", "");
$sel->click_at_ok("css=div#language_chosen .chosen-results [data-option-array-index=" . $actionIndex . "]", "");
$sel->click_at_ok("css=span.js-button-update", "");
WAIT: {
    for (1..60) {
        if (eval { !$sel->is_element_present("css=div.js-editor-container-edit") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
