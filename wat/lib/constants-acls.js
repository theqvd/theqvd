// Acl classification sections and actions

ACL_SECTIONS = {
    "administrator": "Administrators",
    "config": "Configuration",
    "di": "Disk images",
    "host": "Nodes",
    "log": "Log",
    "osf": "OS Flavours",
    "role": "Roles",
    "tenant": "Tenants",
    "user": "Users",
    "views": "Views",
    "vm": "Virtual machines"
};

ACL_SECTIONS_PATTERNS = {
    "administrator": "administrator.%",
    "config": "config.%",
    "di": "di.%",
    "host": "host.%",
    "osf": "osf.%",
    "role": "role.%",
    "tenant": "tenant.%",
    "user": "user.%",
    "views": "views.%",
    "vm": "vm.%",
    "log": "log.%"
};

ACL_ACTIONS = {
    "create": "Create",
    "delete": "Delete one by one",
    "delete-massive": "Delete massively",
    "see": "See",
    "see-details": "See details view",
    "see-main": "See main section",
    "update": "Update one by one",
    "update-massive": "Update massively",
    "filter": "Filters",
    "stats": "Statistics"
}

ACL_ACTIONS_PATTERNS = {
    "create": "%.create.%",
    "delete": "%.delete.%",
    "delete-massive": "%.delete-massive.%",
    "see": "%.see.%",
    "see-details": "%.see-details.%",
    "see-main": "%.see-main.%",
    "update": "%.update.%",
    "update-massive": "%.update-massive.%",
    "filter": "%.filter.%",
    "stats": "%.stats.%"
}
