$sel->open_ok("/");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("name=admin_tenant") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
