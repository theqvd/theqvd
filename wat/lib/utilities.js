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
        var milliseconds = new Date().getTime() + (diffSeconds * 1000);
        
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
            var translatedAcl = $.i18n.t(ACLS[acl.name]);
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
}