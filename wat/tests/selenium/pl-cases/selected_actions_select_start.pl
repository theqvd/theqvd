$sel->click_at_ok("css=div.action-selected-select>div.chosen-container", "");
my $actionIndex = $sel->get_element_index("css=select[name=\"selected_actions_select\"] option[value=\"start\"]");
$sel->click_at_ok("css=div.action-selected-select>div.chosen-container .chosen-results [data-option-array-index=" . $actionIndex . "]", "");
