$sel->click_ok("css=div.js-platform-menu.menu > ul > li.menu-option[data-target=\"vms\"]");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-list-vm") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
