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
        
        if (params.searchKey) {
            this.setCurrentSearchKey(params.searchKey);
            this.setSelectedGuide('');
        }
        
        var templates = {
            docSection: {
                name: 'help-documentation'
            },
            docSearch: {
                name: 'help-documentation-search'
            },
            docSearchResult: {
                name: 'help-documentation-search-result'
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
    
    setCurrentSearchKey: function (searchKey) {
        this.currentSearchKey = searchKey;
    },
    
    render: function () {        
        // Fill the html with the template
        this.template = _.template(
            Wat.TPL.docSection, {
                selectedGuide: this.selectedGuide,
                guides: Wat.C.getDocGuides(),
                searchKey: this.currentSearchKey,
                cid: this.cid
            }
        );
        
        $(this.el).html(this.template);
        
        this.printBreadcrumbs(this.breadcrumbs, '');
        this.renderRelatedDocs();

        if (this.currentSearchKey) {
            var that = this;
            
            // Little delay to give time to render interface
            setTimeout(function () {
                that.searchDoc(that.currentSearchKey);
            }, 300);
        }
        else {
            this.fillDocumentation();
        }

        Wat.T.translate();       
    },
    
    // Fill guide doc content
    fillDocumentation: function () {    
        Wat.A.getDocBody({
            guide: this.selectedGuide,
            target: $('.bb-doc-text'),
            callback: this.goSelectedSection
        }, Wat.A.fillDocBody);
    },
    
    // Simulate click on guide that is stored as selected
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
    
    // Search a given string on each documentation guide and print it on screen
    searchDoc: function (searchKey) {
        var that = this;
        
        // If pushState is available in browser, modify hash with current search
        if (history.pushState) {
            history.pushState(null, null, '#documentation/search/' + searchKey);
        }
        
        // Get available guides
        var guides = Wat.C.getDocGuides ();
        
        var target = $('.setup-block');
        
        // Fill the html with the general search template with layer for each guide results
        var template = _.template(
            Wat.TPL.docSearch, {
                guides: guides,
                searchKey: searchKey,
            }
        );

        target.html(template);
                           
        // Translate rendered strings
        Wat.T.translate();       

        // Initialize counters for global search
        var totalMatches = 0;
        var guidesCompleted = 0;
        
        // Go over each guide to get it and perform searching
        $.each(guides, function (guideKey, guideName) {
            // Get guide file content
            Wat.A.getDocBody({
                guide: guideKey,
                guideName: guideName,
                target: $('.bb-doc-text'),
            }, function (docParams) {
                // Get body content of the guide document
                var pattern = /<body[^>]*>((.|[\n\r])*)<\/body>/im
                var array_matches = pattern.exec(Wat.TPL.docSection);

                docParams.docBody = array_matches[1];

                // Search key
                var pattern = new RegExp('((.|[\n\r])*)' + searchKey + '((.|[\n\r])*)', 'im');
                
                // Initialize variables for guide searching
                var sectionh3 = '';
                var sectionh2 = '';
                var matchsTree = {};
                var matchsDictionary = {};
                var guideMatches = 0;
                
                // Convert HTML to js object
                var parsedDocBody = $.parseHTML(docParams.docBody);

                // We go over ASCIIDOC structure to retrieve each section and subsections
                // IMPORTANT: If we change asciidoc generation script, this search process may fail
                
                // Get content from parsed doc body.
                // This doc have structure #text,#header,#text,#content,#text,#footnotes,#text,#footer,#text
                // #text represent carriage returns and other empty html fragments
                // Position 3 is content, so we get this position directly
                var level0 = parsedDocBody[3];
                var level0Data = $(level0)[0];
                
                // The structure of #content branch is:
                
                //  #content                        LEVEL 0
                //      #preamble (opt)
                //      .sect1                      LEVEL 1    
                //          h2                      LEVEL 2
                //          .sectionbody            
                //              .paragraph (opt)    LEVEL 3
                //              .sect2
                //                  h3              LEVEL 4
                //                  [other tags]    LEVEL N
                
                // Get child nodes of the doc content
                var level1Nodes = level0Data.childNodes;
                
                // ////////////////////
                // LEVEL 1
                // ////////////////////

                // Go over content child nodes to search keysearch on each section/subsection
                $.each(level1Nodes, function (iL1, level1) {
                    // #text are empty fragments of the html code, so we avoid them
                    if (level1.nodeName == '#text') {
                        return;
                    }
                    
                    var level1Data = $(level1)[0];
                    var level2Nodes = level1Data.childNodes;
                    
                    // If element id is preamble, it is the guide introduction before any section
                    if (level1.id == 'preamble') {
                        var content = level1Data.innerHTML;
                        var array_matches = pattern.exec(content);
                        if (array_matches) {                             
                            if (matchsTree['guide_' + docParams.guide] == undefined) {
                                matchsTree['guide_' + docParams.guide] = {
                                    'nmatches': 1,
                                    'guide_introduction': 1
                                };
                            }
                            else {
                                matchsTree['guide_' + docParams.guide].nmatches++;
                            }   

                            var dictKey = 'guide_' + docParams.guide;
                            var dictVal = $.i18n.t('Guide introduction');

                            guideMatches++;

                            // Store pairs key-text to rendering process
                            matchsDictionary[dictKey] = dictVal;
                        }
                    }
                    // If element is not preamble, go to next level
                    else {
                        // ////////////////////
                        // LEVEL 2 (H2)
                        // ////////////////////

                        $.each(level2Nodes, function (iL2, level2) {
                            // #text are empty fragments of the html code, so we avoid them
                            if (level2.nodeName == '#text') {
                                return;
                            }
                            
                            var level2Data = $(level2)[0];
                            var level3Nodes = level2Data.childNodes;

                            // In level 2 we can found H2 and other contents
                            // If element is H2 tag, store for know where we are and check search on section name
                            
                            if (level2Data.localName == 'h2') {
                                // Store section id removing initial underscore
                                sectionh2 = level2Data.id;
                                sectionh2 = sectionh2.substring(1, sectionh2.length);
                                sectionh2Text = level2Data.innerHTML;

                                // For each new h2, reset h3 to initial values
                                sectionh3 = '';
                                sectionh3Text = '';

                                // Check if searchkey is into the name of the section
                                var content = level2Data.innerHTML;
                                var array_matches = pattern.exec(content);
                                if (array_matches) {
                                    matchsTree[sectionh2] = {
                                        'nmatches': 1,
                                        'name': 1
                                    };

                                    guideMatches++;

                                    // Store pairs key-text to rendering process
                                    matchsDictionary[sectionh2] = sectionh2Text;
                                }
                            }
                            // If element is not H2 tag, go to next level
                            else {
                                // ////////////////////
                                // LEVEL 3
                                // ////////////////////

                                $.each(level3Nodes, function (iL3, level3) {
                                    // #text are empty fragments of the html code, so we avoid them
                                    if (level3.nodeName == '#text') {
                                        return;
                                    }

                                    var level3Data = $(level3)[0];
                                    var level4Nodes = level3Data.childNodes;

                                    // If element is sect2, go to next level
                                    if (level3Data.localName == 'div' && level3Data.className == 'sect2') {

                                        // ////////////////////
                                        // LEVEL 4 (H3)
                                        // ////////////////////

                                        $.each(level4Nodes, function (iL4, level4) {
                                            // #text are empty fragments of the html code, so we avoid them
                                            if (level4.nodeName == '#text') {
                                                return;
                                            }

                                            var level4Data = $(level4)[0];

                                            // In level 4 we can found H3 and other contents
                                            // If element is H3 tag, store for know where we are and check search on section name
                                            if (level4Data.localName == 'h3') {
                                                // Store section id removing initial underscore
                                                sectionh3 = $(level4Data)[0].id;
                                                sectionh3 = sectionh3.substring(1, sectionh3.length);
                                                sectionh3Text = level4Data.innerHTML;

                                                // Check if searchkey is into the name of the section
                                                var content = level4Data.innerHTML;
                                                var array_matches = pattern.exec(content);
                                                if (array_matches) {
                                                    if (matchsTree[sectionh3] == undefined) {
                                                        matchsTree[sectionh3] = {
                                                            'nmatches': 1
                                                        };
                                                    }
                                                    else {
                                                        matchsTree[sectionh3].nmatches++;
                                                    }

                                                    guideMatches++;

                                                    // Store pairs key-text to rendering process
                                                    matchsDictionary[sectionh3] = sectionh3Text;
                                                }
                                            }
                                            // If element is not H3, this is the content of the subsection
                                            else {
                                                // Check if searchkey is into the content of the subsection
                                                var content = level4Data.innerHTML;
                                                var array_matches = pattern.exec(content);
                                                if (array_matches) {
                                                    if (matchsTree[sectionh3] == undefined) {
                                                        matchsTree[sectionh3] = {
                                                            'nmatches': 1
                                                        };
                                                    }
                                                    else {
                                                        matchsTree[sectionh3].nmatches++;
                                                    }

                                                    guideMatches++;

                                                    // Store pairs key-text to rendering process
                                                    matchsDictionary[sectionh3] = sectionh3Text;
                                                }
                                            }
                                        });
                                    }
                                    // If element is not sect2, this is the content of the section
                                    else {
                                        var content = level3Data.innerHTML;
                                        var array_matches = pattern.exec(content);
                                        if (array_matches) {
                                            var dictKey = sectionh2;
                                            var dictVal = sectionh2Text;

                                            if (matchsTree[sectionh2] == undefined) {
                                                matchsTree[sectionh2] = {
                                                    'nmatches': 1
                                                };
                                            }
                                            else {
                                                matchsTree[sectionh2].nmatches++;
                                            }

                                            guideMatches++;

                                            // Store pairs key-text to rendering process
                                            matchsDictionary[dictKey] = dictVal;
                                        }
                                    }
                                });
                            }
                        });
                    }
                });
                
                // Fill the html with the template
                var template = _.template(
                    Wat.TPL.docSearchResult, {
                        matchsTree: matchsTree,
                        matchsDictionary: matchsDictionary,
                        guide: docParams.guide,
                        guideName: docParams.guideName,
                        guideMatches: guideMatches
                    }
                );

                $('.bb-' + guideKey).html(template);
                
                guidesCompleted++;
                totalMatches += guideMatches;
                
                // Hide loading animation and show results
                if (guidesCompleted == Object.keys(guides).length) {
                    Wat.T.translate();       
                    $('.js-search-summary').html(i18n.t('__count__ matches found for', {'count': totalMatches}));
                    target.find('.loading-mid').remove();
                    $('.js-guide-search').show();
                }
            });
        });
    },
});