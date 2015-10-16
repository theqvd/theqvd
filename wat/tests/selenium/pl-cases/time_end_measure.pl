my $startTime = $sel->get_eval("${startTime}");
my $endTime = $sel->get_eval("new Date().getTime()");
my $scriptExecutionTime = $sel->get_eval("(" . $endTime . " - " . $startTime . ") / 1000");
print("[time_end] Execution time: " . $scriptExecutionTime . " seconds" . "\n");
