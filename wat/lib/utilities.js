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
    }
}