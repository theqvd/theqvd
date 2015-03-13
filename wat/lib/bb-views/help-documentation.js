Wat.Views.DocView = Wat.Views.MainView.extend({
    qvdObj: 'documentation',
    selectedGuide: 'introduction',
    
    breadcrumbs: {
        'screen': 'Home',
        'link': '#',
        'next': {
            'screen': 'Help',
            'next': {
                'screen': 'Documentation'
            }
        }
    },
    
    initialize: function (params) {
        Wat.Views.MainView.prototype.initialize.apply(this, [params]);
        
        if (params.guide) {
            this.setSelectedGuide(params.guide);
        }        
                
        if (params.section) {
            this.setSelectedSection(params.section);
        }
        
        var templates = {
            docSection: {
                name: 'help-documentation'
            }
        }
        
        Wat.A.getTemplates(templates, this.render); 
    },
    
    events: {
        'keydown .js-doc-search': 'pressSearchDoc'
    },
    
    pressSearchDoc: function (e) {
        if (e.which == 13 && $(e.target).val() != '') {
            setTimeout (function () {
            Wat.CurrentView.searchDoc($(e.target).val());
            }, 1000);
            
            $('.lateral-menu-option').removeClass('lateral-menu-option--selected');
        }
    },
    
    setSelectedGuide: function (guideKey) {
        this.selectedGuide = guideKey;
    },    
    
    setSelectedSection: function (sectionKey) {
        this.selectedSection = sectionKey;
    },
    
    render: function () {        
        // Fill the html with the template
        this.template = _.template(
            Wat.TPL.docSection, {
                selectedGuide: this.selectedGuide,
                guides: Wat.C.getDocGuides(),
                cid: this.cid
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        
        this.fillDocumentation();

        Wat.T.translate();       
    },
    
    fillDocumentation: function () {    
        Wat.A.getDocBody({
            guide: this.selectedGuide,
            target: $('.bb-doc-text'),
            callback: this.goSelectedSection
        }, Wat.A.fillDocBody);
    },
    
    goSelectedSection: function () {
        var currentHash = '#documentation/' + Wat.CurrentView.selectedGuide;
        
        if (Wat.CurrentView.selectedSection) {
            $('#toc [href="#_' + Wat.CurrentView.selectedSection + '"]').trigger('click');
            currentHash += '/' + Wat.CurrentView.selectedSection;
        }
        
        // If pushState is available in browser, modify hash with current section
        if (history.pushState) {
            history.pushState(null, null, currentHash);
        }
    },
    
    searchDoc: function (searchKey) {
        var that = this;
        
        var guides = Wat.C.getDocGuides ();
        
        var target = $('.setup-block');
        
        target.html('');
        
        $.each(guides, function (guideKey, guideName) {
            Wat.A.getDocBody({
                guide: guideKey,
                guideName: guideName,
                target: $('.bb-doc-text'),
            }, function (docParams) {
                var pattern = /<body[^>]*>((.|[\n\r])*)<\/body>/im
                var array_matches = pattern.exec(Wat.TPL.docSection);

                docParams.docBody = array_matches[1];

                // Search key
                var pattern = new RegExp('((.|[\n\r])*)' + searchKey + '((.|[\n\r])*)', 'im');
                var sectionh3 = '';
                var sectionh2 = '';

                var matchsTree = {};
                
                $.each($($.parseHTML(docParams.docBody)[3])[0].childNodes, function (iElement, element) {
                    if (element.nodeName == '#text') {
                        return;
                    }
                    
                    $.each($(element)[0].childNodes, function (iChild, child) {
                        if (child.nodeName == '#text') {
                            return;
                        }
                        
                        if ($(child)[0].localName == 'h2') {
                            // Store section id removing initial underscore
                            sectionh2 = $(child)[0].id;
                            sectionh2 = sectionh2.substring(1, sectionh2.length);
                            
                            sectionh2Text = $(child)[0].innerHTML;
                            sectionh3 = '';
                            sectionh3Text = '';
                            
                            // Check if searchkey is into the name of the section
                            var content = $(child)[0].innerHTML;
                            var array_matches = pattern.exec(content);
                            if (array_matches) {
                                var matchHTML = '<a href="#documentation/' + docParams.guide + '">' + guideName + '</a>';
                                matchHTML += ' -> ';
                                matchHTML += '<a href="#documentation/' + docParams.guide + '/' + sectionh2 + '">' + sectionh2Text + '</a>';
                                
                                target.html(target.html() + matchHTML + '<br>');
                                
                                if (matchsTree[docParams.guide] == undefined) {
                                    matchsTree[docParams.guide] = {};
                                }
                                
                                if (matchsTree[docParams.guide][sectionh2] == undefined) {
                                    matchsTree[docParams.guide][sectionh2] = ['_name'];
                                }
                            }
                        }
                        else {
                            $.each($(child)[0].childNodes, function (iChild2, child2) {
                                if (child2.nodeName == '#text') {
                                    return;
                                }
                                
                                if ($(child2)[0].localName == 'div' && $(child2)[0].className == 'sect2') {
                                    $.each($(child2)[0].childNodes, function (iChild3, child3) {
                                        if (child3.nodeName == '#text') {
                                            return;
                                        }
                                        
                                        if ($(child3)[0].localName == 'h3') {
                                            // Store section id removing initial underscore
                                            sectionh3 = $($(child3)[0])[0].id;
                                            sectionh3 = sectionh3.substring(1, sectionh3.length);
                                            
                                            sectionh3Text = $(child3)[0].innerHTML;

                                            // Check if searchkey is into the name of the section
                                            var content = $(child3)[0].innerHTML;
                                            var array_matches = pattern.exec(content);
                                            if (array_matches) {
                                                var matchHTML = '<a href="#documentation/' + docParams.guide + '">' + guideName + '</a>';
                                                matchHTML += ' -> ';
                                                matchHTML += '<a href="#documentation/' + docParams.guide + '/' + sectionh2 + '">' + sectionh2Text + '</a>';
                                                matchHTML += ' -> ';
                                                matchHTML += '<a href="#documentation/' + docParams.guide + '/' + sectionh3 + '">' + sectionh3Text + '</a>';
                                                
                                                target.html(target.html() + matchHTML + '<br>');
                                                
                                                if (matchsTree[docParams.guide] == undefined) {
                                                    matchsTree[docParams.guide] = {};
                                                }

                                                if (matchsTree[docParams.guide][sectionh2] == undefined) {
                                                    matchsTree[docParams.guide][sectionh2] = [sectionh3];
                                                }
                                                else {
                                                    matchsTree[docParams.guide][sectionh2].push(sectionh3);
                                                }
                                                
                                            }
                                        }
                                        else {
                                            var content = $(child3)[0].innerHTML;
                                            var array_matches = pattern.exec(content);
                                            if (array_matches) {
                                                var matchHTML = '<a href="#documentation/' + docParams.guide + '">' + guideName + '</a>';
                                                matchHTML += ' -> ';
                                                matchHTML += '<a href="#documentation/' + docParams.guide + '/' + sectionh2 + '">' + sectionh2Text + '</a>';
                                                matchHTML += ' -> ';
                                                matchHTML += '<a href="#documentation/' + docParams.guide + '/' + sectionh3 + '">' + sectionh3Text + '</a>';

                                                target.html(target.html() + matchHTML + '<br>');
                                                
                                                if (matchsTree[docParams.guide] == undefined) {
                                                    matchsTree[docParams.guide] = {};
                                                }
                                                
                                                if (matchsTree[docParams.guide][sectionh2] == undefined) {
                                                    matchsTree[docParams.guide][sectionh2] = [sectionh3];
                                                }
                                                else {
                                                    matchsTree[docParams.guide][sectionh2].push(sectionh3);
                                                }
                                            }
                                        }
                                    });
                                }
                                else {
                                    var content = $(child2)[0].innerHTML;
                                    var array_matches = pattern.exec(content);
                                    if (array_matches) {
                                        var matchHTML = '<a href="#documentation/' + docParams.guide + '">' + guideName + '</a>';
                                        matchHTML += ' -> ';
                                        matchHTML += '<a href="#documentation/' + docParams.guide + '/' + sectionh2 + '">' + sectionh2Text + '</a>';
                                        
                                        target.html(target.html() + matchHTML + '<br>'); 
                                        
                                        if (matchsTree[docParams.guide] == undefined) {
                                            matchsTree[docParams.guide] = {};
                                        }

                                        if (matchsTree[docParams.guide][sectionh2] == undefined) {
                                            matchsTree[docParams.guide][sectionh2] = ['_self'];
                                        }
                                    }
                                }
                            });
                        }
                    });
                });
                
                //console.info(matchsTree);
                //target.html(target.html() + '<br><br>' + JSON.stringify(matchsTree) + '<br><br>');
                // TODO: Create a template that will receive matchsTree structure and draw results
            });
        });
    },
});