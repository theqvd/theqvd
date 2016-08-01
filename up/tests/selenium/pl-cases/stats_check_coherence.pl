$sel->text_is("css=div.js-running-hosts-data span.data-total", $nHosts);
$sel->text_is("css=div.js-connected-users-data span.data-total", $nUsers);
$sel->text_is("css=div.js-running-vms-data span.data-total", $nVMs);
