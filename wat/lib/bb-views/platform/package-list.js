Wat.Views.PackageListView = Wat.Views.ListView.extend({
    qvdObj: 'package',
    configVisible: false,
    
    // This events will be added to view events
    listEvents: {
        'click .js-package-conf-btn': 'showPackageConfiguration',
        'click .js-add-package-btn': 'addPackage',
        'click .js-delete-package-btn': 'deletePackage',
        'click .js-order-package-down': 'sortDown',
        'click .js-order-package-up': 'sortUp',
        'keypress [name="packages_search"]': 'filter'
    },
    
    initialize: function (params) { 
        this.collection = new Wat.Collections.Packages(params);
        
        Wat.Views.ListView.prototype.initialize.apply(this, [params]);
    },
    
    //Render list with controls (list block)
    renderListBlock: function (that) {
        var that = that || this;
        
        var template = _.template(
            Wat.TPL.packageBlockWrapper, {
                cid: that.cid
            }
        );
        
        $(that.listBlockContainer).html(template);
        
        that.listBlockContainer = '.bb-packages-list';
        
        Wat.Views.ListView.prototype.renderListBlock.apply(that, []);
    },
    
    showPackageConfiguration: function (e) {
        var package = $(e.target).attr('data-package');
        var currentView = Wat.I.getCurrentView('package');
        
        if (!currentView.configVisible) {
            $(e.target).removeClass('button2').addClass('button');
            $('.js-package-buttonset').show();
            currentView.configVisible = true;
        }
        else {
            $(e.target).removeClass('button').addClass('button2');
            $('.js-package-buttonset').hide();
            currentView.configVisible = false;
        }
        
    },
    
    addPackage: function (e) {
        var package = $(e.target).attr('data-package');
        var currentView = Wat.I.getCurrentView('package');
        
        $('.js-add-package-btn[data-package="' + package + '"]').hide();
        $('.js-add-package-check[data-package="' + package + '"]').show();
        var template = _.template(
            Wat.TPL.editor_package, {
                package: package,
                configVisible: currentView.configVisible
            }
        );
        $('ul.js-installed-packages').append(template);
        
        if ($('ul.js-installed-packages>li').length == 1) {
            $('.js-installed-packages-not-found').hide();
        }
        
        if ($('ul.js-installed-packages>li').length >=2) {
            $('.js-package-conf-btn').show();
        }
    },

    deletePackage: function (e) {
        var package = $(e.target).attr('data-package');
        var currentView = Wat.I.getCurrentView('package');

        $('li.js-installed-package[data-package="' + package + '"]').remove();
        $('.js-add-package-btn[data-package="' + package + '"]').show();
        $('.js-add-package-check[data-package="' + package + '"]').hide();
        
        switch ($('ul.js-installed-packages>li').length) {
            case 0:
                $('.js-installed-packages-not-found').show();
                break;
            case 1:
                if (currentView.configVisible) {
                    $('.js-package-conf-btn').trigger('click');
                }
                break;
        }
        
        if ($('ul.js-installed-packages>li').length < 2) {
            $('.js-package-conf-btn').hide();
        }
    },
    
    sortDown: function (e) {
        var item = $(e.target).closest('li');
        var itemNext = item.next();
        
        item.insertAfter(itemNext);
    },
    
    sortUp: function (e) {
        var item = $(e.target).closest('li');
        var itemPrev = item.prev();
        
        item.insertBefore(itemPrev);
    },
    
    filter: function (e) {
        if (e.keyCode == 13) {
            var currentView = Wat.I.getCurrentView('package');

            currentView.collection.filters.search = $('input[name="packages_search"]').val();

            currentView.fetchList();
        }
    }
});