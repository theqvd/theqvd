$sel->click_ok("css=.js-list table>tbody>tr:first-child input.js-check-it");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=fieldset.js-action-selected[style=\"display: block;\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
