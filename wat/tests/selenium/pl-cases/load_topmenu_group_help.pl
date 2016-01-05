$sel->click_ok("css=li.menu-option.js-menu-option-help>a");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-documentation") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
