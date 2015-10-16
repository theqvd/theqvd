WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=table.js-vm-execution-table[data-state=\"stopping\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
pass;
