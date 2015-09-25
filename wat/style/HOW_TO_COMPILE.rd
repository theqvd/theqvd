This application use SASS preprocessor. 

If you wanna make any change on CSS, you need to update the desired value in scss files (those with scss extension) and compile main SASS file: style.scss

To compile it you need to get installed a sass compiler or a code editor with this feature.

Example of CLI sass compiler (Ubuntu)
-------------------------------------

You can install the Rubby SASS compiler available in official ubuntu repositories with the following command:

sudo apt-get install ruby-sass

Once installed, compile and overwrite the style sheet with this command:

sass style.scss > style.css
