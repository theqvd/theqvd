$sel->click_ok("css=div.js-config-menu.menu > ul > li.menu-option[data-target=\"config\"]");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-qvd-config") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
