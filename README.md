# CitrixXenAppLogging

A quick and dirty script to log Citrix XenApp sessions when your license doesn't allow logging.

# Quick Start

Download the .ps1 file and place it in a folder. Modify the GLOBALS section to reflect your environment. Schedule the script to run as a scheduled task every X minutes.

# Background

When migrating a legacy Citrix XenApp farm to CVAD, you need to know who is running each published app and how often. What apps can be eliminated? What are your most and least used apps? When are your heaviest and lightest usage times? Depending on your XenApp license, you are likely not allowed to log that data. And I mean it is literally not logged at all. There is no secret DB you can manually query.

Years ago, I spent a lot of time investigating potential ways to log that info and mostly came up empty. I eventually created a process that captured that info by capturing and logging ASP user agent info from Web Interface, combining files from all WI servers into a single file, writing it to a SQL DB and then creating and emailing scheduled weekly Excel reports. I documented the process and threw it on TechNet Script Gallery (RIP). It worked surprisingly well for years with little-to-no intervention but, to be honest, it was a ton of work to setup and involved modifying Web Interface files which always makes me nervous.

When I had to repeat this task on an additional XenApp farm, I decided to look for an easier way. I had considered logging current sessions during my initial investigation but didn't think out the details at the time. There are several ways to list all current XenApp sessions, but I found PowerShell to be the cleanest. The key step that makes this process work is eliminating duplicates records.

# How It Works

These are the properties I capture in my script with an example of the results:

"Application","SessionId","User","LogOnTime","ClientName","State"

"Internet Explorer","5","JSmith","3/15/2021 11:39:48 AM","PC-125","Active"

In the example session, all six of those properties will remain the same during each query, until the session ends. At each run, we will have this JSmith session logged and then the script will load the results CSV, look for duplicates and remove the second instance of the JSmith session. If JSmith logs out and launches a new session, the LogOnTime and likely SessionId properties will be different, indicating it is a new unique session.

Configure the script to run every X minutes as a scheduled task and the log files will roll over each day and week. How often should you run the task? My suggestion would be to time how long it takes for a cycle of the script to complete in your environment. I have successfully run it every one minute in a smaller environment with under 100 sessions. Keep in mind, as the log files get bigger and bigger as the day passes, it takes longer to search for and eliminate duplicates.

There is probably not a reason to run this script more than once every two minutes. It takes about 30-45 seconds to even launch an app, you need to do some action in the app and then close it. If I told you to launch a web browser, navigate to web site, login, click a few things and then close the browser, you're not doing all of that in under two minutes. If someone launches an app and closes it immediately, it was likely a mistaken click.

Once you have the log files, you can open them in Excel and manipulate the data. Keep in mind, you are only seeing apps listed that were run throughout the day. You would need to run a report of all published apps and do some subtraction to figure out what apps are not being used. After that, I usually zero in on apps only being used by one or a few users. If an app is only needed by a single user, Citrix is likely not the best place for that app to live.

Once your apps have been published on the new CVAD farm and you have told your users to start using the new farm, these reports allow you to find the stragglers that just can't seem to let go of the legacy farm. Once the bulk of the users have switched, disable all apps on the legacy farm and the remaining users will get the message.


