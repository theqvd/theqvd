$sel->click_ok("css=td.js-name>a");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.js-details-block") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
