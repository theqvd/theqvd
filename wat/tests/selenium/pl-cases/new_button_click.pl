$sel->click_at_ok("css=a.js-button-new", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.js-editor-container-create") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
