Wat.I.L = {
    // Countdown update of interfaces elements second by second
    countdown: function () {        
        setInterval(function () {   
            $.each($('[data-countdown]'), function (iElement, element) {
                // Get raw data from element (base64 format)
                var rawData = $(element).attr('data-raw');
                
                // Decode from base64 to Object
                var data = Wat.U.base64.decodeObj(rawData);
                
                // Calculate remaining time in seconds
                var seconds = parseInt(data.seconds) + (parseInt(data.minutes) * 60) + (parseInt(data.hours) * 60 * 60) + (parseInt(data.days) * 60 * 60 * 24);
                
                // If is expired do not continue
                if (seconds == 0) {
                    $(element).html($.i18n.t("Expired"));
                    return;
                }
                
                // Substract 1 second from the total
                seconds = seconds - 1;
                
                // Split remaining time into days, hours, minutes and seconds
                data.days = Math.floor(seconds / (60 * 60 * 24));
                seconds = seconds % (60 * 60 * 24);
                data.hours = Math.floor(seconds / (60 * 60));
                seconds = seconds % (60 * 60);
                data.minutes = Math.floor(seconds / 60);
                seconds = seconds % 60;
                data.seconds = seconds;
                
                // Encode remaining time in base64 and store in DOM
                rawData = Wat.U.base64.encodeObj(data);
                $(element).attr('data-raw', rawData);
                
                // Process time
                var processedTime = Wat.U.processRemainingTime(data);
                
                // Update attributes used to translate not exact times
                $(element).removeAttr('data-days data-months data-years');
                $.each(remainingTimeAttrObj, function (attrName, attrValue) {
                    $(element).attr(attrName, attrValue);
                });
                
                // Update priority class of element and his siblings
                $(element).removeClass('ok warning error').addClass(processedTime.priorityClass);
                $(element).siblings().removeClass('ok warning error').addClass(processedTime.priorityClass);
                
                // If processed time is exact, print into DOM. Otherwise will be translated 
                if (processedTime.returnType == 'exact') {
                    $(element).html(processedTime.remainingTime);
                }
                else {
                    // Translate not exact dates
                    Wat.T.translateXDays();
                    Wat.T.translateXMonths();
                    Wat.T.translateXYears();
                }
                
                // If is expired, remove attr to avoid future useless checks
                if (processedTime.expired) {
                    $(element).removeAttr('data-countdown');
                }
            });
        }, 1000);
    }
}
