$sel->click_ok("css=div.js-user-menu.menu > ul > li.menu-option[data-target=\"myviews\"]");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-custom-views-admin") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
