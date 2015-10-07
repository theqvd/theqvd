$sel->is_element_present_ok("css=li.menu-option .js-menu-submenu-user[style*=\"display: none;\"]");
$sel->mouse_over_ok("css=li.menu-option.js-menu-option-user");
$sel->is_element_present_ok("css=li.menu-option .js-menu-submenu-user");
ok(not $sel->is_element_present("css=li.menu-option .js-menu-submenu-user[style*=\"display: none;\"]"));
$sel->mouse_out_ok("css=li.menu-option.js-menu-option-user");
