$sel->click_ok("css=a.js-delete-filter-note");
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
