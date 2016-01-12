my $actionIndex = $sel->get_element_index("css=select[name=\"state\"] option[value=\"running\"]");
$sel->click_at_ok("css=#filter_state_chosen", "");
$sel->click_at_ok("css=div#filter_state_chosen .chosen-results [data-option-array-index=" . $actionIndex . "]", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.loading-mid") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { !$sel->is_element_present("css=div.loading-mid") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
