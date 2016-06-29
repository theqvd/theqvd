WAT application use SASS preprocessor to give styles. 

If you wanna make any change on CSS, you have various methods:

Editing SASS files
==================

You need to update the desired value in scss files (those with scss extension) and compile main SASS file: style.scss

To compile it you need to get installed a sass compiler or a code editor with this feature.

Example of CLI sass compiler (Ubuntu)
-------------------------------------

You can install the Rubby SASS compiler available in official ubuntu repositories with the following command:

    sudo apt-get install ruby-sass

Once installed, compile and overwrite the style sheet with this command:

    sass style.scss > style.css

Overwritting some styles
========================

The styles sheet loaded in WAT application is 'style.css', but after it another style sheet is loaded. This is the case of 'custom_style.css'.

custom_style.css is initially empty, but as it is loaded after style.css, any value on this style sheet will override the regular style sheet.

You can add to it any modification of the styles without afraid of lost your changes in future WAT upgrades (except important style changes).

Using Style Customizer Tool
===========================

WAT has a specific UI tool to customize logos and colors of the interface. 

You have a detailed user guide about this feature in the documentation. 

You can find out this guide in two ways:

* In the embeded WAT documentation (Menu->Help->Documentation)
* Visiting the online QVD documentation site (http://docs.theqvd.com/docs/)