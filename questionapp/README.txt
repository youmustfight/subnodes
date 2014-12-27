========================================
DRBPoll
http://www.dbscripts.net/poll/

By Don B

Version 1.8
========================================

Requirements
------------

PHP 4.4 or higher
Apache HTTP Server (recommended)

    * It is strongly recommended that register_globals be set to off 
      in your php.ini file.
    * AllowOverride must be enabled for the directory where the poll
      script is installed in your Apache httpd.config file.

Installation
------------

1) Extract the ZIP file into the desired destination folder on your website.
   Optionally, you may rename the "poll" folder to whatever name is 
   desired; you will need to change the POLL_URL variable in config.php, 
   and the include path in example.php to reflect this change.

2) Modify the settings in config.php to match your environment and desired 
   configuration.  This is where you will define your polls; some example 
   polls are included for reference.  Detailed descriptions of the settings 
   are included in the comments within that file.

3) Confirm that the "/data" subfolder has write permissions enabled.

4) Add the poll code to the desired PHP pages on your website.  The included 
   example.php file demonstrates how to do this.

Upgrade
-------

If you are already running DRBPoll and need to upgrade to the latest 
version, you must perform the following steps.

1) Backup your config.php file, the contents of your "data" folder, and any 
   files in the "template" directory that you have customized.

2) Extract the ZIP file into the desired destination folder on your website, 
   overwriting the existing files.  If you renamed the "poll" folder, 
   you may need to copy the files into the correctly named folder.
   
3) Replace your config.php file, "data" folder contents, and any customized 
   template files that you backed up.
   
Uninstall
---------

You can uninstall DRBPoll by following the steps below.

Please note that ALL DATA WILL BE LOST if you uninstall!

1) Delete the subfolder where you put the DRBPoll 
   files from your webserver.
   
2) Remove any references to DRBPoll from the pages in your website.

Customization
-------------

The included example.php file demonstrates how to add a poll form to almost 
any ordinary PHP page.  See config.php for the available customization 
options.  Also, you are free to customize the files in the template folder.  
These files control what is displayed after the rating form is submitted, and 
when the "current results" link is clicked.

Modifying the PHP files other than config.php, and those inside the template 
folder is not recommended, as this may make it difficult or impossible to 
upgrade to newer versions of DRBPoll in the future.

Flat File Database
------------------

DRBPoll stores its data in a flat file database (i.e. text files).  
It is highly recommended that you make back up copies of these files 
on a frequent basis.  These files can be found in the "data" folder.

License
-------

To use DRBPoll free of charge, all that I ask is that the "Powered by..." and 
links at the bottom of the results page not be removed or altered.

You may not distribute code modifications to DRBPoll without permission from 
the author.

DRBPoll is provided "as is", without warrant of any kind, either 
expressed or implied. 

The author is not liable for anything that results from your use of this code.
