var MainView = Backbone.View.extend({
    el: '.bb-content',
    config: {},
    breadcrumbs: {},
    
    initialize: function () {
        _.bindAll(this, 'render');
    },
    
    printBreadcrumbs: function (bc, bcHTML) {
        if (bc.link != undefined) {
            bcHTML += '<a href="' + bc.link + '" data-i18n>' + bc.screen + '</a>';
        }
        else {
            bcHTML += '<span data-i18n>' + bc.screen + '</span>';
        }

        if (bc.next != undefined) {
            bcHTML += ' <i class="fa fa-angle-double-right"></i> ';
            this.printBreadcrumbs (bc.next, bcHTML);
        }
        else {
            $('#breadcrumbs').html(bcHTML);
        }
    },
    
    cache: {
        stringsCache : {},
        getCached : function (col, dictionary) {
            if (dictionary != undefined && dictionary[col] !== undefined) {
                return dictionary[col];
            }
            else {
                return '';
            }
        },
        cached : false
    },
    
    activeCache: function (cache) {
        $.each($('.cacheable'), function(index, element) {
            var key = $(element).attr('data-i18n');
            var value = $(element).html();
            // Remove HTML tags from value to clean icons
            var cleanValue = value.replace(/(<([^>]+)>)/ig,"");
            cache.stringsCache[key] = cleanValue;
        });
        
        cache.cached = true;
    },
    
    
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
    }
});
