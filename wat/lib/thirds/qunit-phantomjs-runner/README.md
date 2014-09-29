# PhantomJS Runner QUnit Plugin #

> A PhantomJS-powered headless test runner, providing basic console output for QUnit tests.

The runner requires [PhantomJS](http://phantomjs.org/). If you don't want to deal with installing PhantomJS or using Grunt to run your tests, try [node-qunit-phantomjs](https://github.com/jonkemp/node-qunit-phantomjs).

### Usage ###
```bash
$ phantomjs runner.js [url-of-your-qunit-testsuite] [timeout-in-seconds]
```

Show test cases:

```bash
$ phantomjs runner-list.js [url-of-your-qunit-testsuite] [timeout-in-seconds]
```

### Notes ###
 - Requires [PhantomJS](http://phantomjs.org/) 1.6+ (1.7+ recommended).
 - QUnit plugins are also available for [gulp](https://github.com/jonkemp/gulp-qunit) and [Grunt](https://github.com/gruntjs/grunt-contrib-qunit).
