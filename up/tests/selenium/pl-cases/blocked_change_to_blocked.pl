my $actionIndex = $sel->get_element_index("css=select[name=\"blocked\"] option[value=\"1\"]");
$sel->click_at_ok("css=#filter_blocked_chosen", "");
$sel->click_at_ok("css=div#filter_blocked_chosen .chosen-results [data-option-array-index=" . $actionIndex . "]", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=a.js-delete-filter-note[data-filter-name=\"blocked\"]") }) { pass; last WAIT }
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
