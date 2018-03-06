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
    "vm": "Virtual machines",
    "property": "Custom properties"
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
    "log": "log.%",
    "property": "property.%"
};

ACL_ACTIONS = {
    "create": "Create",
    "delete": "Delete",
    "see": "See",
    "see-details": "See details view",
    "see-main": "See main section",
    "update": "Update",
    "stats": "Statistics",
    "manage": "Manage"
}

ACL_ACTIONS_PATTERNS = {
    "create": "%.create.%",
    "delete": "%.delete.%",
    "see": "%.see.%",
    "see-details": "%.see-details.%",
    "see-main": "%.see-main.%",
    "update": "%.update.%",
    "stats": "%.stats.%",
    "manage": "%.manage.%"
}
