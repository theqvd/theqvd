Up.Models.Connection = Up.Models.Model.extend({
    actionPrefix: 'connection',
    
    defaults: {
    },
    
    url: function () {
        var url = Up.C.getBaseUrl() + 'account/last_connection';
        
        return url;
    },
    
    processResponse: function (response) {
        response = Up.Models.Model.prototype.processResponse.apply(this, [response]);        
        
        ////// Set associated icons to the connection data //////
        // Browser
        // Possible values: chrome, firefox, ie, opera, safari, adm, applecoremedia, blackberry, brave, browsex, dalvik, elinks, links, lynx, emacs, epiphany, galeon, konqueror, icab, lotusnotes, mosaic, mozilla, netfront, netscape, n3ds, dsi, obigo, polaris, pubsub, realplayer, seamonkey, silk, staroffice, ucbrowser, webtv
        
        if (response.browser) {
            var browser = response.browser.split(' ')[0].toLowerCase();

            switch(browser) {
                case 'chrome':
                    response.browserIcon = 'fa fa-chrome';
                    break;
                case 'firefox':
                    response.browserIcon = 'fa fa-firefox';
                    break;
                case 'ie':
                    response.browserIcon = 'fa fa-internet-explorer';
                    break;
                case 'opera':
                    response.browserIcon = 'fa fa-opera';
                    break;
                case 'safari':
                    response.browserIcon = 'fa fa-safari';
                    break;
            }       
        }
        
        // OS
        // Possible values: windows, winphone, mac, macosx, linux, android, ios, os2, unix, vms,chromeos, firefoxos, ps3, psp, rimtabletos, blackberry, amiga, brew
        
        if (response.os) {
            var os = response.os.split(' ')[0].toLowerCase();
            
            switch(os) {
                case 'windows':
                case 'winphone':
                    response.osIcon = 'fa fa-windows';
                    break;
                case 'mac':
                case 'macosx':
                case 'ios':
                    response.osIcon = 'fa fa-apple';
                    break;
                case 'linux':
                    response.osIcon = 'fa fa-linux';
                    break;
                case 'android':
                    response.osIcon = 'fa fa-android';
                    break;
                case 'chromeos':
                    response.osIcon = 'fa fa-chrome';
                    break;
                case 'firefoxos':
                    response.osIcon = 'fa fa-firefox';
                    break;
            }
        }
                
        // Device
        // Possible values: desktop, tablet, mobile
        
        if (response.device) {
            var device = response.device.toLowerCase();
            
            switch(device) {
                case 'desktop':
                    response.deviceIcon = 'fa fa-desktop';
                    break;
                case 'tablet':
                    response.deviceIcon = 'fa fa-tablet';
                    break;
                case 'mobile':
                    response.deviceIcon = 'fa fa-mobile';
                    break;
            }
        }
        
        // Process latitude and longitude
        if (response.location) { 
            var coordinates = response.location.split(',');
            response.latitude = coordinates[0];
            response.longitude = coordinates[1];
        }
        
        return response;
    }
});