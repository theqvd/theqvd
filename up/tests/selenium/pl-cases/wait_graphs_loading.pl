WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.js-running-vms-data[data-finished=\"1\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.js-connected-users-data[data-finished=\"1\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.js-running-hosts-data[data-finished=\"1\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
pass;
