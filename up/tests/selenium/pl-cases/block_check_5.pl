$sel->text_is("css=span.elements-shown", "5");
$sel->is_element_present_ok("css=table.list tr:nth-child(5)");
ok(not $sel->is_element_present("css=table.list tr:nth-child(6)"));
$sel->text_isnt("css=span.pagination_total_pages", "1");
