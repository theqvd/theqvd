// Interface languages
UP_LANGUAGES = {
    "en": "English",
    "es": "Español"
};

UP_LANGUAGE_OPTIONS = $.extend({
    "auto": "Auto-detected by browser"
}, UP_LANGUAGES);

// Correspondence of ISO country codes with country names
var LAN_COUNTRIES = {
	"af": "Afghanistan",
	"al": "Albania",
	"dz": "Algeria",
	"ar": "Argentina",
	"am": "Armenia",
	"au": "Australia",
	"at": "Austria",
	"az": "Azerbaijan",
	"bd": "Bangladesh",
	"by": "Belarus",
	"be": "Belgium",
	"bt": "Bhutan",
	"bo": "Bolivia",
	"ba": "Bosnia and herzegovina",
	"bw": "Botswana",
	"br": "Brazil",
	"bg": "Bulgaria",
	"kh": "Cambodia",
	"cm": "Cameroon",
	"ca": "Canada",
	"cl": "Chile",
	"cn": "China",
	"co": "Colombia",
	"cd": "Congo, the democratic republic of the",
	"cr": "Costa rica",
	"hr": "Croatia",
	"cu": "Cuba",
	"cz": "Czech republic",
	"dk": "Denmark",
	"do": "Dominican republic",
	"ec": "Ecuador",
	"sv": "El salvador",
	"ee": "Estonia",
	"et": "Ethiopia",
	"fo": "Faroe islands",
	"fi": "Finland",
	"fr": "France",
	"ge": "Georgia",
	"de": "Germany",
	"gh": "Ghana",
	"gr": "Greece",
	"gt": "Guatemala",
	"gn": "Guinea",
	"hn": "Honduras",
	"hu": "Hungary",
	"is": "Iceland",
	"in": "India",
	"id": "Indonesia",
	"ir": "Iran, islamic republic of",
	"iq": "Iraq",
	"ie": "Ireland",
	"il": "Israel",
	"it": "Italy",
	"jp": "Japan",
	"kz": "Kazakhstan",
	"ke": "Kenya",
	"kr": "Korea, republic of",
	"kg": "Kyrgyzstan",
	"la": "Lao people's democratic republic (laos)",
	"lv": "Latvia",
	"lt": "Lithuania",
	"mk": "Macedonia, the former yugoslav republic of",
	"my": "Malaysia",
	"mv": "Maldives",
	"ml": "Mali",
	"mt": "Malta",
	"mx": "Mexico",
	"md": "Moldova, republic of",
	"mn": "Mongolia",
	"me": "Montenegro",
	"ma": "Morocco",
	"mm": "Myanmar",
	"np": "Nepal",
	"nl": "Netherlands",
	"ni": "Nicaragua",
	"ng": "Nigeria",
	"no": "Norway",
	"pk": "Pakistan",
	"pa": "Panama",
	"py": "Paraguay",
	"pe": "Peru",
	"ph": "Philippines",
	"pl": "Poland",
	"pt": "Portugal",
	"pr": "Puerto rico",
	"ro": "Romania",
	"ru": "Russian federation",
	"sn": "Senegal",
	"rs": "Serbia",
	"sk": "Slovakia",
	"si": "Slovenia",
	"za": "South africa",
	"es": "Spain",
	"lk": "Sri lanka",
	"se": "Sweden",
	"ch": "Switzerland",
	"sy": "Syrian arab republic",
	"tw": "Taiwan",
	"tj": "Tajikistan",
	"tz": "Tanzania, united republic of",
	"th": "Thailand",
	"tg": "Togo",
	"tr": "Turkey",
	"tm": "Turkmenistan",
	"ua": "Ukraine",
	"gb": "United kingdom",
	"us": "United states",
	"uy": "Uruguay",
	"uz": "Uzbekistan",
	"ve": "Venezuela",
	"vn": "Viet nam"
};

UP_KB_LAYOUT__OPTIONS = $.extend({
    "auto": "Auto-detected by browser"
}, LAN_COUNTRIES);

// Country codes that match with "latam" kb code
var LAN_LATAM_CODES = [
	"ar",
	"bo",
	"cl",
	"co",
    "cr",
	"cu",
	"do",
	"ec",
	"sv",
	"gt",
	"hn",
	"mx",
	"ni",
	"pa",
	"py",
	"pe",
	"pr",
	"uy",
	"ve"
];

// Country codes that match second segment of locale code (I.E. en_GB) with default territory for its group of locales
var LAN_MAPPING_SHORT_2_TERRITORY = {
    "en": "US",
    "ar": "ae",
    "zh": "cn",
    "gd": "ie",
    "ms": "my",
    "sv": "se"
}