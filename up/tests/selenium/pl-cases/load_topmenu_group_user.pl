$sel->click_ok("css=li.menu-option.js-menu-option-user>a");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-profile") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
