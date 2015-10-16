$sel->click_ok("css=table.list tr.row-517>td.js-name");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-details-vm") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
