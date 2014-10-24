// Status codes returned by the API
STATUS_SUCCESS = 0;
STATUS_FORBIDDEN = 8;
STATUS_NOT_LOGIN = 29;

// App configuration
APP_PATH = './';

// Icons
CLASS_ICON_USERS = 'fa fa-users';
CLASS_ICON_VMS = 'fa fa-cloud';
CLASS_ICON_HOSTS = 'fa fa-hdd-o';
CLASS_ICON_OSFS = 'fa fa-flask';
CLASS_ICON_DIS = 'fa fa-dot-circle-o';
CLASS_ICON_LOGOUT = 'fa fa-power-off';

// Colours
COL_BRAND = '#cb540a';
COL_BRAND_DARK = '#9a4008';

// Classification of Qvd Objects
QVD_OBJS_WITH_PROPERTIES = ['user', 'vm', 'host', 'osf', 'di'];
QVD_OBJS_CLASSIFIED_BY_TENANT = ['user', 'vm', 'osf', 'di', 'administrator'];
QVD_OBJS_EXIST_IN_SUPERTENANT = ['role', 'administrator'];

// Html pieces
HTML_MINI_LOADING = '<div class="mini-loading"><i class="fa fa-gear fa-spin"></i></div>';

// Acl classification sections and actions
ACL_SECTIONS = {
    "administrator": "Administrators",
    "my-admin-area": "My area",
    "config": "Configuration",
    "di": "Disk images",
    "host": "Nodes",
    "osf": "OS Flavours",
    "role": "Roles",
    "tenant": "Tenants",
    "user": "Users",
    "views": "Views",
    "vm": "Virtual machines"
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