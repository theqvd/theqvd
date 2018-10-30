// Debugging purposes

// If true, the internal or fixed roles cannot be edited from WAT
RESTRICT_TEMPLATES = true;

// Connection timeout
CONNECTION_TIMEOUT = 40;

// Debug constants
DEBUG_ACL_FAILS = false;

// noVNC include URI
INCLUDE_URI = "lib/thirds/noVNC/include/";
VNC_MIN_HEIGHT = 400;
VNC_MIN_WIDTH = 600;

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

// Settings available on HTML5 client
HTML5_SETTINGS = ['client', 'fullscreen'];


// Connection level
CL_NOT_READY = 0;
CL_READY = 1;