$sel->click_ok("css=.js-need-help");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-documentation") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { !$sel->is_text_present("css=div.sec-documentation .js-doc-text>div.content") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
