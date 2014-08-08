Wat.A = {
    getTemplate: function(templateName) {
        if ($('#template_' + templateName).html() == undefined) {
            var tmplDir = 'templates';
            var tmplUrl = tmplDir + '/' + templateName + '.tpl';
            var tmplString = '';

            $.ajax({
                url: tmplUrl,
                method: 'GET',
                async: false,
                contentType: 'text',
                success: function (data) {
                    tmplString = data;
                }
            });

            $('head').append('<script id="template_' + templateName + '" type="text/template">' + tmplString + '<\/script>');
        }

        return $('#template_' + templateName).html();
    },
    
    performAction: function (action, filters, arguments) {
        var baseUrl = "http://172.20.126.12:3000/?login=benja&password=benja";
        var actions = this.getApiActions ();
        action = actions[action];

        var filters = JSON.stringify(filters);
        var arguments = JSON.stringify(arguments);

        var url = baseUrl + 
            '&action=' + action +
            '&filters=' + filters +
            '&arguments=' + arguments;

        $.ajax({
            url: url,
            type: 'POST',
            async: false,
            dataType: 'json',
            processData: false,
            parse: true,
            success: function (data) {
                console.info(data);
            }
        });
    },

    getApiActions: function () {
        return {
            'update_user': 'user_update_custom',
            'update_vm': 'vm_update_custom'
        };
    }
};