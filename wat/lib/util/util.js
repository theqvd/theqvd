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
                    remainingTime = i18n.t('__count__ days', {'count': remainingTime});
                    break;
                case 'months':
                    remainingTimeAttr = 'data-months="' + remainingTime + '"';
                    remainingTimeAttrObj['data-months'] = remainingTime;
                    remainingTime = i18n.t('__count__ months', {'count': remainingTime});
                    break;
                case '>year':
                    remainingTimeAttr = 'data-years="' + remainingTime + '"';
                    remainingTimeAttrObj['data-years'] = remainingTime;
                    remainingTime = i18n.t('__count__ years', {'count': remainingTime});
                    break;
            }
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
    
    databaseDateToString: function (databaseDate) {
        if (databaseDate) {
            var dt = new Date(databaseDate);
            return this.dateToString(dt);
        } else {
            return '';
        }
    },
    
    stringDateToDatabase: function (string) {
        if (string) {
            return new Date(string).toJSON();
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
    },
    
    // Evaluate fields of one model to check if comply certain conditions passed as parameter
    complyConditions: function (model, conditions) {
        // Count number of success conditions
        var matchCounter = 0;
        $.each(conditions, function (field, values) {
            var matchCondition = false;
            $.each(values, function (iValue, value) {
                if (model.get(field) == value) {
                    matchCondition = true;
                }
            });

            if (matchCondition) {
                matchCounter++;
            }
        });

        // If any confition doesnt pass, ignore the category
        if (matchCounter < Object.keys(conditions).length) {
            return false;
        }
        
        return true;
    },
    
    getViewFromCid: function (cid) {
        var view = Wat.CurrentView;
        
        $.each(Wat.CurrentView.embeddedViews, function (qvdObj, eView) {
            if (eView.cid == cid) {
                view = eView;
                return false;
            }
        });
        
        return view;
    },
    
    getViewFromQvdObj: function (qvdObjSearch) {
        var view = false;
        var embeddedView = false;
        
        $.each(Wat.CurrentView.embeddedViews, function (qvdObj, eView) {
            if (qvdObjSearch == qvdObj) {
                embeddedView = eView;
                return false; // break $.each
            }
        });
        
        if (embeddedView) {
            view = embeddedView;
        }
        else {
            var sideView = false;
            
            $.each(Wat.CurrentView.sideViews, function (qvdObj, sView) {
                if (qvdObjSearch == sView.qvdObj) {
                    sideView = sView;
                    return false; // break $.each
                }
            });
            
            if (sideView) {
                view = sideView;
            }
        }
        
        return view || Wat.CurrentView;
    },
    
    setFormChangesOnModel: function (wrapperSelector, model) {
        var attributes = {};
        
        $.each($(wrapperSelector + ' [data-form-field]'), function (i, control) {
            switch ($(control).attr('type')) {
                case 'checkbox':
                    attributes[$(control).attr('name')] = $(control).is(':checked') ? 1 : 0;
                    break;
                default:
                    attributes[$(control).attr('name')] = $(control).val();
                    break;
            }
        });
        
        $.each($(wrapperSelector + ' [data-form-list]'), function (i, list) {
            var listName = $(list).attr('data-form-list');
            
            if (attributes[listName] == undefined) {
                attributes[listName] = [];
            }
            
            var listAttributes = {};
            
            $.each ($(list).find('[data-form-field-name]'), function (iField, field) {
                listAttributes[$(field).attr('data-form-field-name')] = $(field).val();
            });
            
            attributes[listName].push(listAttributes);
        });
        
        model.set(attributes);
    },
    
    // Convert seconds to format hours:minutes:seconds
    // Parameters:
    //  seconds: Number of seconds (integer)
    //  format: strShort|strLong|object
    secondsToHms: function (seconds, format) {
        var format = format || 'strShort';
        
        var secondsOnDay = 60*60*24;
        var secondsOnHour = 60*60;
        var secondsOnMinute = 60;
        
        var days = 0;
        if (seconds > secondsOnDay) {
            days = Math.round(seconds / secondsOnDay);
            seconds = seconds % secondsOnDay;
        }
        
        var hours = parseInt(Math.floor(seconds / secondsOnHour));
        seconds = seconds % secondsOnHour;
        var minutes = parseInt(Math.floor(seconds / secondsOnMinute));
        seconds = parseInt(seconds % secondsOnMinute);
        
        switch (format) {
            case 'strShort':
                var ret = '';
                
                if (days > 0) {
                    ret = $.i18n.t("__count__ days", {count: days});
                }
                
                if (hours < 10) { hours = '0' + hours }
                if (minutes < 10) { minutes = '0' + minutes }
                if (seconds < 10) { seconds = '0' + seconds }

                ret += hours + ':' + minutes + ':' + seconds;
                break;
            case 'strLong':
                var ret = '';
                
                if (days > 0) {
                    ret += $.i18n.t("__count__ days", {count: days});
                }
                
                if (hours > 0) {
                    ret += ' ' + $.i18n.t("__count__ hours", {count: hours});
                }
                
                if (minutes > 0) {
                    ret += ' ' + $.i18n.t("__count__ minutes", {count: minutes});
                }
                break;
            case 'object':
                var ret = {
                    days: days,
                    hours: hours,
                    minutes: minutes,
                    seconds: seconds
                }
                break;
        }
        
        return ret;
    },
    
    getRemainingTime: function (elapsedTime, percentage) {
        return ((100 * elapsedTime)/percentage) - elapsedTime;
    }
}