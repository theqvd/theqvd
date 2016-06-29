$sel->mouse_over_ok("css=li.menu-option.js-menu-option-help");
$sel->click_ok("css=a.js-submenu-option-documentation");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-documentation") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
