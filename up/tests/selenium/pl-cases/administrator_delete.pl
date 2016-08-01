$sel->click_at_ok("css=a.js-button-delete", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.ui-dialog-buttonset") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
$sel->click_ok("css=span.js-button-accept");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-list-administrator") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { !$sel->is_element_present("css=tr[data-id=\"" . $administratorId . "\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
