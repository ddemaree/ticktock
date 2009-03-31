# Welcome to Ticktock #

Ticktock is a simple web service for logging what you're doing throughout the day, from which you can generate calendars and stats to help you understand where the time has gone. It can be used for personal or business projects, such as:

* Billing clients for your time
* Keeping up with a fitness program
* Keeping a food log, like if you're dieting

Ticktock can be accessed through an elegant, powerful browser-based UI, as well as through RESTful XML and JSON APIs which will enable developers to create kick-ass time-journaling apps for desktop and mobile platforms.


## A couple of developer notes ##

* Our target browser platforms are: Internet Explorer 7 and 8 (Windows XP/Vista), Firefox (all OSes), Safari 3.2/4.0b (Windows and Mac OS X). Whenever possible, other Gecko- or WebKit-based browsers (such as Google Chrome) should be supported, though bugs for those browsers are not priority unless they can be duplicated in one of our A-grade supported ones.

* TT currently uses Rails 2.3.2; plugins, gems, app servers, etc., will need to support Rails 2.3 to be used with Ticktock.

* TT's JavaScript code is managed using [Sprockets](http://github.com/sstephenson/sprockets), served up using the sprockets-rails plugin. Unless a particular bit of JS code needs to be used on only one/a few screens, it should be placed in the `/app/javascripts` directory and included into `application.js`.


## Setting up Ticktock locally ##

Eventually I plan to set up some rake tasks/scripts for bootstrapping a local environment. For now, just install required gems (using rake gems:install).

You'll need to add some entries to your hosts file, since TT uses subdomains to determine which account (if any) you're accessing. It can handle TLDs with more than two parts (like *.local.practical.cc) so you can use a local DNS server (or even a DNS record pointed at 127.0.0.1) to set this up.

Signups are always done via http://[whatever].[tld]/signup. The account names `signup`, `www` and `admin` are reserved, so these are good ones to use for creating your first account. (The 'official' signup URL in production is <http://signup.ticktockapp.com/signup>.)