$sel->click_ok("css=a[name=\"selected_actions_button_delete\"]");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=.ui-dialog-buttonpane .js-button-cancel") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
$sel->click_ok("css=.ui-dialog-buttonpane .js-button-accept");
