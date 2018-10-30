Up.U = {
    processRemainingTime: function (rawRemainingTime) {
        if (!rawRemainingTime) {
            return {};
        }
        
        if (rawRemainingTime.months == undefined) {
            rawRemainingTime.months = 0;
        }
        
        var priorityClass = '';
        var remainingTime = '';
        var remainingTimeAttr = '';
        var returnType = ''; // exact/days/months/>year

        if (rawRemainingTime.days < 1 && rawRemainingTime.months == 0) {
            priorityClass = 'error';
            
            rawRemainingTime.hours = parseInt(rawRemainingTime.hours) < 10 ? '0' + parseInt(rawRemainingTime.hours) : rawRemainingTime.hours;
            rawRemainingTime.minutes = parseInt(rawRemainingTime.minutes) < 10 ? '0' + parseInt(rawRemainingTime.minutes) : rawRemainingTime.minutes;
            rawRemainingTime.seconds = parseInt(rawRemainingTime.seconds) < 10 ? '0' + parseInt(rawRemainingTime.seconds) : rawRemainingTime.seconds;
                
            remainingTime = rawRemainingTime.hours + ':' + rawRemainingTime.minutes + ':' + rawRemainingTime.seconds;
            returnType = 'exact';
        }
        else if(rawRemainingTime.months == 0) {
            priorityClass = 'warning';
            remainingTime = rawRemainingTime.days;
            returnType = 'days';
        }
        else if (rawRemainingTime.months < 12) {
            priorityClass = 'ok';
            remainingTime = rawRemainingTime.months;
            returnType = 'months';
        }
        else {
            priorityClass = 'ok';
            remainingTime = '>1';
            returnType = '>year';
        }
        
        remainingTimeAttr = '';
        remainingTimeAttrObj = {};
        if (rawRemainingTime.expired) {
            remainingTime = $.i18n.t("Expired");
        }
        else {
            switch (returnType) {
                case 'days':
                    remainingTimeAttr = 'data-days="' + remainingTime + '"';
                    remainingTimeAttrObj['data-days'] = remainingTime;
                    break;
                case 'months':
                    remainingTimeAttr = 'data-months="' + remainingTime + '"';
                    remainingTimeAttrObj['data-months'] = remainingTime;
                    break;
                case '>year':
                    remainingTimeAttr = 'data-years="' + remainingTime + '"';
                    remainingTimeAttrObj['data-years'] = remainingTime;
                    break;
            }

            // If remainingTimeAttr is not empty, remainingTime will be empty
            remainingTime = remainingTimeAttr ? '' : remainingTime;
        }
        
        return {
            returnType: returnType,
            remainingTime: remainingTime,            
            remainingTimeAttr: remainingTimeAttr,
            priorityClass: priorityClass,
            expired: rawRemainingTime.expired,
            rawTime: rawRemainingTime,
        };
    },
    
    getDate: function (milliseconds) {
        milliseconds = milliseconds || new Date().getTime();
        
        var dt = new Date(milliseconds);
        
        var year = dt.getFullYear();
        var month = this.padNumber(dt.getMonth()+1);
        var day = this.padNumber(dt.getDate());
        var hour = this.padNumber(dt.getHours());
        var minute = this.padNumber(dt.getMinutes());
        var second = this.padNumber(dt.getSeconds());
        
        var dtstring = year
            + '-' + month
            + '-' + day
            + ' ' + hour
            + ':' + minute
            + ':' + second;
        
        return dtstring;
    },
    
    // Get the current date plus the given diffMilliseconds
    getRelativeDate: function (diffSeconds) {
        // Obtain the relative date with the current one OF THE SERVER
        var milliseconds = new Date().getTime() + (diffSeconds * 1000) + (Up.C.serverClientTimeLag * 1000);
        
        return this.getDate(milliseconds);
    },
    
    getCurrentDate: function () {
        return this.getDate();
    },
    
    // Add 0 to the left of numbers less tan 10
    padNumber: function (number) {
        number = number < 10 ? '0' + number : number;
        
        return number;
    },
    
    // Sort acl list by translated description
    sortTranslatedACLs: function (acls) {
        var translatedAcls = [];
        
        $.each(acls, function (iAcl, acl) {
            var translatedAcl = $.i18n.t(acl.description);
            acls[iAcl].translatedACL = translatedAcl;
            translatedAcls.push(translatedAcl);
        });
        
        translatedAcls.sort();
        
        var sortedAcls = [];
        
        $.each(translatedAcls, function (iTacl, tacl) {
            $.each(acls, function (iAcl, acl) {
                if (acl.translatedACL == tacl) {
                    sortedAcls.push(acl);
                    return false;
                }
            });
        });
        
        return sortedAcls;
    },
    
    // Base64 encode and decode functions catching errors to avoid crashes
    base64: {
        encode: function (s) {
            try { 
                return btoa(s);
            } 
            catch (e) { 
                return false;
            }
        },
        decode: function (s) {
            try { 
                return atob(s);
            } 
            catch (e) { 
                return false;
            }
        },
        // Special functions to encode/decode objects
        encodeObj: function (s) {
            try { 
                return btoa(JSON.stringify(s));
            } 
            catch (e) { 
                return false;
            }
        },
        decodeObj: function (s) {
            try { 
                return JSON.parse(atob(s));
            } 
            catch (e) { 
                return {};
            }
        }
    },
    
    // Encode filters to searchHash for url
    transformFiltersToSearchHash: function (filters) {
        return this.base64.encodeObj({
            filters: filters
        });
    },
    
    // Convert a js object (a object of objects) to url parameters
    objToUrl: function (params) {
        var urlParams = '';
        
        $.each(params, function (pName, pValue) {
            urlParams += '&' + pName + '=' + JSON.stringify(pValue);
        });
        
        return urlParams;
    },
    
    // Get url basename
    basename: function (path) {
        return path.split(/[\\/]/).pop();
    },
    
    // Get local datetime from GMT+0 datetime
    getLocalDatetime: function (datetime) {
        var d = new Date (datetime);
        
        var minutesOffset = new Date().getTimezoneOffset();
        dLocal = new Date (d.getTime()-(minutesOffset*60*1000));
        
        return dLocal;
    }, 
    
    // Get local datetime formatted
    getLocalDatetimeFormatted: function (datetime) {
        var d = this.getLocalDatetime(datetime);
        var dFormatted = Up.U.getDate(d.getTime());
        
        return dFormatted;
    },

    // Get keyboard layout code (territory code) from UP configuration token kb_layout
    getKeyboardLayoutCode: function (kbLayout) {
        // English by default (United States)
        var defaultLayout = 'us';

        // If keyboard layout is auto-detected, get it from navigator API
        if (kbLayout == 'auto') {
            var navigatorLanguage = window.navigator.language;

            // Navigator language can be in two formats: I.E.: es or es_ES.
            // Clean navigator language to use territory code
            switch (navigatorLanguage.length) {
                case 2:
                    // If language is in two chars format, use mapping object o transform some languages into its default territory
                    if (LAN_MAPPING_SHORT_2_TERRITORY[navigatorLanguage]) {
                        navigatorLanguage = LAN_MAPPING_SHORT_2_TERRITORY[navigatorLanguage];
                    }
                    break;
                case 5:
                    // If language is in fiver chars format, second segment will be the territory code
                    navigatorLanguage = navigatorLanguage.substring(3).toLowerCase();
                    break;
            }

            // If clean navigator language doesnt match with any countries, use default one
            kbLayout = LAN_COUNTRIES[navigatorLanguage] ? navigatorLanguage : defaultLayout;
        }
        
        // All latino american countries will use layout 'latam'
        if ($.inArray(kbLayout, LAN_LATAM_CODES) != -1) {
            kbLayout = 'latam';
        }

        return kbLayout;
    }
}