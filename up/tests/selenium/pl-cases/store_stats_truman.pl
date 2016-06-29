my $nVMs = $sel->get_text("css=span.js-summary-vms");
my $nOSFs = $sel->get_text("css=span.js-summary-osfs");
my $nDIs = $sel->get_text("css=span.js-summary-dis");
my $nBlockedVMs = $sel->get_text("css=span.js-summary-blocked-vms");
my $nBlockedDIs = $sel->get_text("css=span.js-summary-blocked-dis");
my $nRunningVMs = $sel->get_text("css=div.js-running-vms-data span.data");
