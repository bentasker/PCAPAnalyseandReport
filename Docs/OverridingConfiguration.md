Overriding Configuration
=========================

This documentation details how to override elements of the scripts default configuration to meet your needs



Config File Location
----------------------

The configuration file should be called *config.sh* and *must* be located in the same directory as PCAP_Analysis



Interesting Referers/Paths
-----------------------------

As of [PAS-3](http://projects.bentasker.co.uk/jira_projects/browse/PAS-3.html) the script will build two CSVs (*interestingdomains.csv* and *interestingdomains-full.csv*) containing a list of all "interesting" paths visited via HTTP or HTTPS (where referers have disclosed the path)

In order to customise the paths you find interesting, the following should be defined within *config.sh*

      INTERESTING_PATHS="^((https:\/\/|http:\/\/)?)(www|np|m|i)\.reddit\.com\/(r|u)\/([^\/]*)|^((https:\/\/|http:\/\/)?)www\.google\.([^\/]*)|^((https:\/\/|http:\/\/)?)www\.bbc\.co\.uk|^((https:\/\/|http:\/\/)?)t.co/"

Where the value is an regex to be passed to *egrep* (using -e).

The formatting of the data being checked will vary depending on the field being examined, so you should probably prefix all expressions with

      ^((https:\/\/|http:\/\/)?)

See [this comment](http://projects.bentasker.co.uk/jira_projects/browse/PAS-3.html#comment1299105) for more information on the reasoning for that.

The final consideration to take into account, is the generation of *interestingdomains.csv*. It is a simple CSV containing only the pattern which matched, for example, assuming a filter of

      ^((https:\/\/|http:\/\/)?)(www|np|m|i)\.reddit\.com\/(r|u)\/([^\/]*)

Matched the string *https://www.reddit.com/r/awww/comments/3u2s90/no_i_didnt_drink_it/*, only *https://www.reddit.com/r/awww* will be written to *interestingdomains.csv*. The full value (including how it was obtained) will be written to *interestingdomains-full.csv*

The aim of this feature is to allow you to specify specific information you may be interested in extracting (to stick with the Reddit example, we can start to build an idea of the subreddits a user may be subscribed to).







