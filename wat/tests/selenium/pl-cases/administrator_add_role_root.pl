$sel->click_at_ok("css=a.js-tools-roles-btn", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=table.role-template-tools") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
$sel->click_at_ok("css=input.js-add-role-button[data-role-template-id=\"1\"]", "");
$sel->click_ok("css=span.js-button-close");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div[data-role-id=\"1\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
