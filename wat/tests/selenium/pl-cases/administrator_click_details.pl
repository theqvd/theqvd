$sel->click_ok("css=table.list tr.row-" . $administratorId . ">td.js-name");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-details-administrator") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
