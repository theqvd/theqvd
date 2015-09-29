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
            
            rawRemainingTime.hours = rawRemainingTime.hours < 10 ? '0' + rawRemainingTime.hours : rawRemainingTime.hours;
            rawRemainingTime.minutes = rawRemainingTime.minutes < 10 ? '0' + rawRemainingTime.minutes : rawRemainingTime.minutes;
            rawRemainingTime.seconds = rawRemainingTime.seconds < 10 ? '0' + rawRemainingTime.seconds : rawRemainingTime.seconds;
                
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

        return {
            returnType: returnType,
            remainingTime: remainingTime,
            priorityClass: priorityClass,
            expired: rawRemainingTime.expired
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
    }
}