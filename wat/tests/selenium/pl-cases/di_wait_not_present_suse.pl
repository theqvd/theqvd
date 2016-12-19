WAIT: {
    for (1..60) {
        if (eval { !$sel->is_element_present("css=tr[data-name=\"opensuse-12.3-qvd.tar.gz\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
pass;
