

$sel->open_ok("/wat/");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("name=admin_tenant") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
$sel->type_ok("name=admin_tenant", "*");
$sel->type_ok("name=admin_user", "superadmin");
$sel->type_ok("name=admin_password", "superadmin");
$sel->click_ok("link=Log-in");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div.sec-home") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}


