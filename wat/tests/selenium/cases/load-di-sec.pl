$sel->click_ok("css=div.js-platform-menu.menu > ul > li.menu-option[data-target=\"dis\"]");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-list-di") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
