my $startTimeCopy = $sel->get_eval($startTime);
my $endTime = $sel->get_eval("new Date().getTime()");
my $scriptExecutionTime = $sel->get_eval("(" . $endTime . " - " . $startTimeCopy . ") / 1000");
print("[end] Execution time: " . $scriptExecutionTime . " seconds" . "\n");
