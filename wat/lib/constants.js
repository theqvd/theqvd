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
    "administrator": "administrator",
    "config": "config",
    "di": "di",
    "host": "host",
    "osf": "osf",
    "role": "role",
    "tenant": "tenant",
    "user": "user",
    "views": "views",
    "vm": "vm"
};

ACL_ACTIONS = {
    "create": "create",
    "delete": "delete",
    "delete-massive": "delete-massive",
    "see": "see",
    "see-details": "see-details",
    "see-main": "see-main",
    "update": "update",
    "filter": "filter",
    "stats": "stats",
    "update-massive": "update-massive"
}