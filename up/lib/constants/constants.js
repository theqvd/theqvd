// Debugging purposes

// If true, the internal or fixed roles cannot be edited from WAT
RESTRICT_TEMPLATES = true;

// Connection timeout
CONNECTION_TIMEOUT = 60;

// Debug constants
DEBUG_ACL_FAILS = false;

// Websockets status
WS_CONNECTING = 0;
WS_OPEN = 1;
WS_CLOSING = 2;
WS_CLOSED = 3;

// App configuration
APP_PATH = './';


// Client settings parameters mapping with field names
CLIENT_PARAMS_MAPPING = {
    connection: { 
        value: 'client.link'
    },
    audio: { 
        value: 'client.audio.enable'
    },
    fullscreen: { 
        value: 'client.fullscreen'
    },
    printers: { 
        value: 'client.printing.enable'
    }
}

// Filters
FILTER_ALL = -10;

// Recover user
RECOVER_USER_ID = 0;
SUPERTENANT_ID = 0;
COMMON_TENANT_ID = -1;

// Default values
DEFAULT_OSF_MEMORY = 256;

// Config
UNCLASSIFIED_CONFIG_CATEGORY = 'unclassified';

// Html pieces
HTML_MINI_LOADING = '<div class="mini-loading"><i class="fa fa-gear fa-spin"></i></div>';
HTML_LOADING = '<div class="loading"><i class="fa fa-gear fa-spin"></i></div>';
HTML_MID_LOADING = '<div class="loading-mid"><i class="fa fa-gear fa-spin"></i></div>';
HTML_MID_LOADING_DELETE = '<div class="loading-mid"><i class="fa fa-trash fa-spin"></i></div>';
HTML_SORT_ICON = '<i class="fa fa-sort sort-icon"></i>';

// Languages
UP_LANGUAGES = {
    "en": "English",
    "es": "Español"
};

UP_LANGUAGE_OPTIONS = $.extend({
    "auto": "Auto-detected by browser"
}, UP_LANGUAGES);

// Block sizes
WAT_BLOCK_SIZES = {
    "5": "5",
    "10": "10",
    "20": "20",
    "50": "50",
    "100": "100"
};
WAT_BLOCK_SIZES_ADMIN = $.extend({
    "0": "Default"
}, WAT_BLOCK_SIZES);


// Documentation
DOC_AVAILABLE_LANGUAGES = ['es'];
DOC_DEFAULT_LANGUAGE = 'es';

// Number of bytes on a KiloByte
BYTES_ON_KB = 1000;

// Log constants

LOG_TYPE_ACTIONS = {
    create: 'Created',
    update: 'Updated',
    create_or_update: 'Setted',
    delete: 'Deleted',
    exec: 'Executed',
    login: 'Logged-in',
    see: 'Visualized'
};

LOG_TYPE_OBJECTS = {
    user: 'User',
    vm: 'Virtual machine',
    host: 'Node',
    osf: 'OS Flavour',
    di: 'Disk image',
    role: 'Role',
    tenant: 'Tenant',
    administrator: 'Administrator',
    admin_view: 'Administrator view',
    tenant_view: 'Default view',
    config: 'Configuration',
    log: 'Log',
};

LOG_TYPE_OBJECTS_ICONS = {
    user: CLASS_ICON_USERS,
    vm: CLASS_ICON_VMS,
    host: CLASS_ICON_HOSTS,
    osf: CLASS_ICON_OSFS,
    di: CLASS_ICON_DIS,
    role: CLASS_ICON_ROLES,
    tenant: CLASS_ICON_TENANTS,
    administrator: CLASS_ICON_ADMINS,
    admin_view: CLASS_ICON_VIEWS,
    tenant_view: CLASS_ICON_VIEWS,
    config: CLASS_ICON_QVDCONFIG,
};

// Antiquity standard options for selects
ANTIQUITY_OPTIONS = [
    {
        'value': FILTER_ALL,
        'text': 'All',
        'selected': true
    },
    {
        'value': 3600,
        'text': '<1 hour'
    },
    {
        'value': 21600,
        'text': '<6 hours'
    },
    {
        'value': 43200,
        'text': '<12 hours'
    },
    {
        'value': 86400,
        'text': '<1 day'
    },
    {
        'value': 604800,
        'text': '<1 week'
    },
    {
        'value': 2592000,
        'text': '<1 month'
    },
    {
        'value': 31536000,
        'text': '<1 year'
    },
];

// Filters that will be fussioned in one filter note
FUSSION_NOTES = {
    object__object_id: {
        label: 'object',
        value: 'object_id',
        qvdObj: 'log',
        replaceValue: 'object_name'
    }
};

// Role templates
ROLE_TEMPLATE_SCOPE = ['Users', 'VMs', 'Nodes', 'OSFs', 'Images', 'Administrators', 'Roles', 'Tenants', /*'Logs',*/ 'Views', 'QVD Config', 'WAT Config', 'QVD', 'WAT'];
ROLE_TEMPLATE_ACTIONS = ['Reader', 'Operator', 'Creator', 'Updater', 'Eraser', 'Manager'];

// Dictionaries


DICTIONARY_STATES = {
    running: 'Running',
    stopped: 'Stopped',
    starting: 'Starting',
    stopping: 'Stopping',
    zombie: 'Zombie'
};

SEPARATORS_DEFAULT = ["@", "#"];
