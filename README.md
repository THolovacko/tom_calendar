# My Tech Stack

* Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-1048-aws x86_64)
* ruby 2.7.1p83 (2020-03-31 revision a0c7c23c9c)
  * aws-sdk (3.0.2) gem
  * google-api-client (0.53.0) gem (maybe after update just need google-apis-generator (0.2.0)?)
  * jwt (2.2.3) gem
  * tzinfo (2.0.4) gem
* Apache/2.4.41
* AWS DynamoDB
* gcc version 9.3.0 (Ubuntu 9.3.0-10ubuntu2)

# Setup

* clone repo in decided server directory then give it read and execute permissions for configured apache user
* add `Alias "/favicon.ico" "/decided/path/tom_calendar/public/favicon.ico"` to apache virtual host config
* add `Alias "/public" "/decided/path/tom_calendar/public/"` to apache virtual host config
* add `ErrorDocument 404 https://DecidedWebsiteName.com/not_found` to apache virtual host config
* enable apache cgi mods
* add `ScriptAliasMatch "^/.{0}$" "/decided/path/tom_calendar/actions/index.html"` to apache virtual host config
* add `ScriptAliasMatch "^/dashboard" "/decided/path/tom_calendar/actions/dashboard"` to apache virtual host config
* add `ScriptAliasMatch "^/robots.txt" "/decided/path/tom_calendar/actions/robots.txt"` to apache virtual host config
* add `ScriptAliasMatch "/" "/decided/path/tom_calendar/lib/tomcalendar_app_server/tomcalendar_forward.tomexe"` to apache virtual host config
* create symbolic link /usr/bin/ruby pointing to ruby
* enable google calendar API in google developer console
* enable google places API in google developer console
* set environment variables in /etc/environment and using SetEnv in apache virtual host config
  * ROOT_DIR_PATH
  * AWS_ACCESS_KEY_ID
  * AWS_SECRET_ACCESS_KEY
  * AWS_REGION
  * AWS_SDK_CONFIG_OPT_OUT
  * GOOGLE_OAUTH_CLIENT_ID
  * GOOGLE_OAUTH_CLIENT_SECRET
  * SESSION_HASH_LEFT_PADDING (arbitrary sized random string)
  * SESSION_HASH_RIGHT_PADDING (arbitrary sized random string)
  * GOOGLE_MAPS_API_KEY
  * ELASTICSEARCH_ENDPOINT
* create tables in DynamoDB (will list tables later)

# Deployment Requirements

* execute script `compile_ruby.sh`
* execute script `lib/tomcalendar_app_server/build.sh`
* execute script `tasks/generate_dashboard desktop`
* execute script `tasks/generate_dashboard mobile`
* execute script `lib/tomcalendar_app_server/restart.sh`
* execute script `lib/tom_memcache/restart.sh`
* execute `sudo systemctl restart apache2`
