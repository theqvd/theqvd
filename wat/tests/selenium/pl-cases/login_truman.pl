$sel->type_ok("name=admin_tenant", "qvd");
$sel->type_ok("name=admin_user", "truman");
$sel->type_ok("name=admin_password", "truman");
$sel->click_ok("link=Log-in");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-home") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
