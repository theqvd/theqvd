Wat.D = {
    // Get a documentation guide from template and return <body> of this document to be ebeded in WAT
    // Params:
    //      selectedGuide: guide name.
    getDocBody: function (docParams, callBack) {        
        var lan = Wat.C.getEffectiveLan();

        var templates = Wat.I.T.getTemplateList('docSection', {lan: lan, guide: docParams.guide});
        
        Wat.A.getTemplates(templates, callBack, docParams);
    },
    
    processDocBody: function (docParams) {
        var pattern = /<body[^>]*>((.|[\n\r])*)<\/body>/im
        var array_matches = pattern.exec(Wat.TPL.docSection);
        
        docParams.docBody = array_matches[1];
        
        Wat.D.processDocSection(docParams);
    }, 
    
    fillDocBody: function (docParams) {
        var pattern = /<body[^>]*>((.|[\n\r])*)<\/body>/im
        var array_matches = pattern.exec(Wat.TPL.docSection);
        
        docParams.docBody = array_matches[1];
        
        Wat.D.fillTemplateString(docParams.docBody, docParams.target, true, docParams);
    },
    
    fillTemplateString: function (string, target, toc, docParams) {
        if (!string) {
            return;
        }
        
        target.html(target.html() + string);  

        if (toc) {
            asciidoc.toc(3);
        }
        
        if (docParams.callback) {
            docParams.callback();
        }
    },
    
    // Get a documentation guide´s section from guide
    // Params:
    //      guide: guide name.
    //      sectionId: Id of the section of the guide to be parsed.
    //      toc: boolean to specify if include or not Table of Contents (Default: False).
    //      imagesPrefix: prefix to be added to each src attribute in images.
    //      target: target where the doc section will be load.
    fillDocSection: function (guide, sectionId, toc, imagesPrefix, target) {
        var docParams = {
            guide: guide,
            sectionId: sectionId,
            toc: toc,
            imagesPrefix: imagesPrefix,
            target: target
        };
        
        if (guide == 'multitenant' && !Wat.C.isSuperadmin()) {
            this.fillTemplateString (null, target, toc, docParams);
            return;
        }
        
        this.getDocBody(docParams, this.processDocBody);
    },
    
    processDocSection: function (docParams) {  
        var toc = docParams.toc;
        
        if (toc == undefined) {
            toc = false;
        }
        
        if (toc) {
            var guideHeader = $.parseHTML(docParams.docBody)[1].outerHTML;
            var guideToc = $.parseHTML(guideHeader)[1].childNodes[3].outerHTML;
        }
        
        var pattern = new RegExp('(<h[1|2|3|4] id="' + docParams.sectionId + '"[^>]*>((.|[\n\r])*))', 'im');
        var array_matches2 = pattern.exec(docParams.docBody); 
        
        if (!array_matches2) {
            return null;
        }
        
        // When doc sections are retrieved from different path than standard (i.e. tests), we can add a prefix to the images path
        if (docParams.imagesPrefix) {
            array_matches2[1] = array_matches2[1].replace(/src="images/g, 'src="' + docParams.imagesPrefix + 'images');
        }
        
        var secBody = $.parseHTML('<div>' + array_matches2[1])[0].innerHTML;
        var secTitle = '';
        
        if (toc) {
            var content = '<div id="content">' + guideToc + secTitle + secBody + '</div>';
        }
        else {
            var content = '<div class="doc-text">' + secBody + '</div>';
        }
        
        this.fillTemplateString(content, docParams.target, false, docParams)
    },
}