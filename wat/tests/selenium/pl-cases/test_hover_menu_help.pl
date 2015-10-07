$sel->is_element_present_ok("css=li.menu-option .js-menu-submenu-help[style*=\"display: none;\"]");
$sel->mouse_over_ok("css=li.menu-option.js-menu-option-help");
$sel->is_element_present_ok("css=li.menu-option .js-menu-submenu-help");
ok(not $sel->is_element_present("css=li.menu-option .js-menu-submenu-help[style*=\"display: none;\"]"));
$sel->mouse_out_ok("css=li.menu-option.js-menu-option-help");
