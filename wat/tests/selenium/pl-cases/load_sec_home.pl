$sel->click_ok("css=div.logo");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-home") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
