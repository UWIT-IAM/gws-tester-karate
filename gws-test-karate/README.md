# Prerequisites

* UWCA cert(s)
* Dev system with Maven
* https://github.com/intuit/karate/  (this is just a reference link...library is pulled in via your dependency manager, 
generally)

# Configuration

rename karate-config.js.tmpl to remove .tmpl extension.

create a .pfx certificate file with public and private keys authorized for GWS.  This file should be in the same 
folder as karate-config.js.  The cert file should have a passphrase (make sure to put it in karate-config).  

You need two certs:

* One is defined in ```var certConfig``` in karate-config.js.  This is the main "default" cert that will be used for 
connections.  Unless you "configure ssl" in a scenario then this cert will be used.  
* Another is defined as a key ```NoAccessConfig``` in the ```var config``` JSON blob.  This is used when we want
to test access control by connecting with a different cert.  This is done within a scenario by calling
```configure ssl = NoAccessConfig```

You could define more certs if you needed them.  

Adjust ```basestem``` and ```baseurl``` in karate-config as appropriate.  You need to create the basestem group with 
cert above authorized as an admin.  Use the baseurl to choose between dev, eval and prod systems.

Global variables to be used in tests can be put in the "var config" json blob in karate-config.  

# Running a single test

Use the ```testone``` script to run a single feature test.

# Running/Reading Tests

Dev tools like Intellij will show you the output nicely in the "Run" view, although it can be hard to read (if they all pass you're good,
but if one fails it is hard to see exactly which one failed...a lot of red herrings).  In Intellij set up a "JUnit" 
run config using GroupsRunner.java as the class.  

You can also run "mvn clean package" on the project to run all the tests (with or without IntelliJ or any kind of IDE).  

Running JUnit as above will give you nicely formatted HTML reports in basefolder/target/surefire-reports.  The reports
will contain the detailed traffic of what happened during the tests.  

Running via "mvn clean package" will also give you reports in basefolder/target/surefire-reports.  You'll get a basic XML 
report of what passed, and detailed traffic in the JSON report, but it's hard to read.  Both reports are in standardized
 format and can be fed to various reporting/testing tools independently to produce reports.  This is in fact what we do
 for the automated Bamboo tests--run "mvn clean package" and then feed the logs to Bamboo for analysis.  Unfortunately 
 Bamboo doesn't do a good job showing exactly where the failure was so I usually end up checking with JUnit in IntelliJ
 to figure out exactly where the problem is.    
 
 Note for test failures:  The automated GWS tests always show an additional failure of "testParallel" when any other 
 test fails.  Don't worry about finding the cause of this--it's just the parent test case "failing" because some of
 the other tests failed (see GroupsTest.java).  

# Notes

Some test group information is stored in various static files, testgroupxx.json.  These files have two main parts, "verify" and "put".  

* "put" is the actual payload sent to the API.  
* "verify" includes keys that aren't sent to the API but *are* returned from it.  Many of them are dynamic.  

# Developing New Tests

groups_meta.feature can be called to verify the "basic" group attributes of a group.  There are some examples of this
in groupsAffiliates.feature.  Look for the "call" keyword.  

Basically use an existing test as a template and include it in the same folder with all the other tests--it will be 
picked up automatically.  The "background" config at the start of the test is pretty self-explanatory--set up some
boilerplate config here to save yourself typing later.  java functions can also be defined here (see Karate docs for
details).  

Because of the tests build on one another I generally have one "scenario" with a bunch of tests in it, but this isn't
really the way they recommend to do this.  Recommendation is a scenario should be a discreet test.  I might do
this differently today.  (mattjm)

I use scenarios heavily when certain things have to change--e.g. to change the ssl config you have to start a new 
scenario.  

# Getting Help

There is a slack channel and the standard bug report tools on Github.  The developer is pretty responsive and open to 
pull requests.  
