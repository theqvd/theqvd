Wat.U = {
    processRemainingTime: function (rawRemainingTime) {
        if (!rawRemainingTime) {
            return {};
        }
        
        var priorityClass = '';
        var remainingTime = '';
        var remainingTimeAttr = '';
        var returnType = ''; // exact/days/months/>year

        if (rawRemainingTime.days < 1 && rawRemainingTime.months == 0) {
            priorityClass = 'error';
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
            priorityClass: priorityClass
        };
    }
}