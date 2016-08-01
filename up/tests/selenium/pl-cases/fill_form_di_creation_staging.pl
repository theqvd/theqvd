WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=select[name=\"tenant_id\"] option") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
my $actionIndex = $sel->get_element_index("css=select[name=\"tenant_id\"] option[value=\"1\"]");
$sel->click_at_ok("css=#tenant_editor_chosen", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=div#tenant_editor_chosen .chosen-results [data-option-array-index=" . $actionIndex . "]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
$sel->click_at_ok("css=div#tenant_editor_chosen .chosen-results [data-option-array-index=" . $actionIndex . "]", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=select[name=\"osf_id\"] option") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
$sel->type_ok("css=div.js-editor-container-create textarea[name=\"description\"]", "My DI description");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=select[name=\"images_source\"] option") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
my $selectIndex = $sel->get_element_index("css=select[name=\"images_source\"] option[value=\"staging\"]");
$sel->click_at_ok("css=#images_source_chosen", "");
$sel->click_at_ok("css=div#images_source_chosen .chosen-results [data-option-array-index=" . $selectIndex . "]", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=select[name=\"disk_image\"] option") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
my $selectIndex = $sel->get_element_index("css=select[name=\"disk_image\"] option[value=\"testing-qvd.tar.gz\"]");
$sel->click_at_ok("css=#disk_image_chosen", "");
$sel->click_at_ok("css=div#disk_image_chosen .chosen-results [data-option-array-index=" . $selectIndex . "]", "");
$sel->click_at_ok("css=span.js-button-create", "");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input[data-di-uploading=\"inprogress-0\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input[data-di-uploading=\"inprogress-10\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input[data-di-uploading=\"inprogress-25\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input[data-di-uploading=\"inprogress-35\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input[data-di-uploading=\"inprogress-50\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input[data-di-uploading=\"inprogress-60\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input[data-di-uploading=\"inprogress-75\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input[data-di-uploading=\"inprogress-85\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input[data-di-uploading=\"inprogress-95\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=tr[data-name=\"testing-qvd.tar.gz\"]") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
