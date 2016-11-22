Wat.U = {
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
        
        return this.dateToString(dt);
    },
    
    dateToString: function (date) {
        if (date != null) {
            var year = date.getFullYear();
            var month = this.padNumber(date.getMonth()+1);
            var day = this.padNumber(date.getDate());
            var hour = this.padNumber(date.getHours());
            var minute = this.padNumber(date.getMinutes());
            var second = this.padNumber(date.getSeconds());
            
            var dtstring = year
                + '-' + month
                + '-' + day
                + ' ' + hour
                + ':' + minute
                + ':' + second;
            
            return dtstring;
        } else  {
            return '';
        }
    },
    
    jsonDateToString : function (string) {
        if (string) {
            var dt = new Date(string);
            return this.dateToString(dt);
        } else {
            return '';
        }
    },
    
    // Get the current date plus the given diffMilliseconds
    getRelativeDate: function (diffSeconds) {
        // Obtain the relative date with the current one OF THE SERVER
        var milliseconds = new Date().getTime() + (diffSeconds * 1000) + (Wat.C.serverClientTimeLag * 1000);
        
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
        var dFormatted = Wat.U.getDate(d.getTime());
        
        return dFormatted;
    },
    
    // Parse an URL to get required parameter
    getURLParameter: function (url, parameter) {
        var regex = /[?&]([^=#]+)=([^&#]*)/g,
            url = url,
            params = {},
            match;
        while(match = regex.exec(url)) {
            params[match[1]] = match[2];
        }
        
        return params[parameter];
    },
    
    // Get instanciated model from qvdObj as user, vm, osf...
    getModelFromQvdObj: function (qvdObj) {
        switch (qvdObj) {
            case 'user':
                    var model = new Wat.Models.User();
                break;
            case 'osf':
                    var model = new Wat.Models.OSF();
                break;
            case 'vm':
                    var model = new Wat.Models.VM();
                break;
            case 'di':
                    var model = new Wat.Models.DI();
                break;
        }
        
        return model;
    },
    
    // Get the field name used for the element name depending on the qvd object
    getNameFieldFromQvdObj: function (qvdObj) {
        switch (qvdObj) {
            case 'di':
                return 'disk_image';
                break;
            default:
                return 'name';
                break;
        }
    },
    
    // HTML strings encode function
    htmlEncode: function (value) {
      //create a in-memory div, set it's inner text(which jQuery automatically encodes)
      //then grab the encoded contents back out. The div never exists on the page.
      return $('<div/>').text(value).html();
    },

    // HTML strings dencode function
    htmlDecode: function (value) {
      return $('<div/>').html(value).text();
    },
    
    // Sort a given object by the key of one of its fields
    sortObjectByField: function (obj, field) {
        return obj.sort(function(a,b) {
            return (a[field] > b[field]) ? 1 : ((b[field] > a[field]) ? -1 : 0);
        });
    }
}