$sel->is_element_present_ok("css=li.menu-option .js-menu-submenu-wat[style*=\"display: none;\"]");
$sel->mouse_over_ok("css=li.menu-option.js-menu-option-wat");
$sel->is_element_present_ok("css=li.menu-option .js-menu-submenu-wat");
ok(not $sel->is_element_present("css=li.menu-option .js-menu-submenu-wat[style*=\"display: none;\"]"));
$sel->mouse_out_ok("css=li.menu-option.js-menu-option-wat");
