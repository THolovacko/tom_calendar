# My Tech Stack

* Ubuntu 20.04 LTS (GNU/Linux 5.4.0-1017-aws x86_64)
* ruby 2.7.1p83 (2020-03-31 revision a0c7c23c9c)
	* aws-sdk (3.0.1) gem
	* google-api-client (0.41.1) gem
* Apache/2.4.41
* AWS DynamoDB

# Setup

* clone repo in server directory then give it read and execute permissions for configured apache user
* add `Alias "/favicon.ico" "/decided/path/tom_calendar/public/favicon.ico"` to apache virtual host config
* add `Alias "/public" "/decided/path/tom_calendar/public/"` to apache virtual host config
* enable apache cgi mods then add `ScriptAlias "/" "/decided/path/tom_calendar/controllers/"` to apache virtual host config
* create symbolic link /usr/bin/ruby pointing to ruby
* set apache user environment variables
	* AWS_ACCESS_KEY_ID
	* AWS_SECRET_ACCESS_KEY
  * AWS_REGION
  * AWS_SDK_CONFIG_OPT_OUT
  * GOOGLE_OAUTH_CLIENT_ID
  * GOOGLE_OAUTH_CLIENT_SECRET
* create tables in DynamoDB (will list tables later)
