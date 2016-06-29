Configuration file
==================

As the WAT application, the QUnit tests have a configuration file named config.json.

This config file has the following format:

    {
        "apiAddress": "172.20.126.16",
        "apiPort": "3000"
    }

This is a JSON formated parameters to get the testing API Address and Port.

This file makes possible have a different QVD installation (including API) for WAT and testing scripts.

Necessary data in database
==========================

To make tests we need have a predefined data in database of QVD. 

This data can be charged in Database with a specify SQL script after QVD installation. 

Execution
=========

The QUnit tests can be executed in two ways:

Browser execution
-----------------

To run the tests in our browser we only need to execute the html file of the tests loading one of the the following URLs:

http://[WAT-URL]/tests/qunit/index-superadmin.html

http://[WAT-URL]/tests/qunit/index-truman.html


Command line execution
----------------------

To execute QUnit tests in command line we need to have installed phantomjs. 

We install it with the following command:

    apt-get install phantomjs
    
Then, we can execute any QUnit test using QUnit PhantomJS runner plugin with the following commands:

    phantomjs --web-security=no lib/thirds/qunit-phantomjs-runner/runner.js index-superadmin.html
    
    phantomjs --web-security=no lib/thirds/qunit-phantomjs-runner/runner.js index-truman.html
    
With these commands we will get as output a XML formatted string with the tests result. 

Additionally we will get a final summary line similar to the following one:

    Took 58812ms to run 659 tests. 659 passed, 0 failed.

Integrate with Jenkins
======================

To integrate our tests in Jenkins, we will use the Jenkins JUnit Plugin.
    
    https://wiki.jenkins-ci.org/display/JENKINS/JUnit+Plugin
    
The XML format of the phantomjs QUnit plugin in command line execution is JUnit compatible, so we only need to give it to Jenkins in a file.

Executing the following commands we get the necessary JUnit XML file:

    phantomjs --web-security=no lib/thirds/qunit-phantomjs-runner/runner-mute.js index-superadmin.html > superadmin-test.xml
    
    phantomjs --web-security=no lib/thirds/qunit-phantomjs-runner/runner-mute.js index-truman.html > truman-test.xml
    
Note that in this case we use a different script: 
    
    lib/thirds/qunit-phantomjs-runner/runner-mute.js 
    
This is a modified runner.js script that avoid print the summary and any other undesired output to obtain a correct XML formatted string.