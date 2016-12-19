WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input.vm-state-" . $vmId . "[value=\"starting\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
pass;
