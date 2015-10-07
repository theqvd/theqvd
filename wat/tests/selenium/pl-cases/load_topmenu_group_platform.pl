$sel->click_ok("css=li.menu-option.js-menu-option-platform>a");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-list-user") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
