#!/bin/bash 
# Slack incoming web-hook URL and user name
url='CHANGEME'    # example: https://hooks.slack.com/services/QW3R7Y/D34DC0D3/BCADFGabcDEF123
# export https_proxy=https://your.proxy.here    ## Comment in if you use a proxy
username='Zabbix'

## Values received by this script:
# To = $1 (Slack channel or user to send the message to, specified in the Zabbix web interface; "@username" or "#channel")
# Subject = $2 (usually either PROBLEM or RECOVERY/OK)
# Message = $3 (whatever message the Zabbix action sends, preferably something like "Zabbix server is unreachable for 5 minutes - Zabbix server (127.0.0.1)")

# Get the Slack channel or user ($1) and Zabbix subject ($2 - hopefully either PROBLEM or RECOVERY/OK)
to="$1"
subject="$2"
body="$3"

# If the start of the subject is an alternative channel or username, send to that instead
if [[ "$subject" =~ ^\@.*|^\#.* ]]; then
   # send to is now the first word
   subjects=( $subject )
   to=${subjects[0]}
   # Remove the first element
   subjects=("${subjects[@]:1}")
   # join with commas
   short_subject=$(printf " %s" "${subjects[@]}")
   # string
   subject=${short_subject:1}
fi

# Change message colour depending on subject
if [[ "$subject" == OK* ]]; then
   colour='good'
elif [[ "$subject" == PROBLEM* ]]; then
   colour='danger'
else
   colour='#439FE0'
fi

# Build our JSON payload and send it as a POST request to the Slack incoming web-hook URL
payload="payload={\"channel\": \"${to//\"/\\\"}\", \"username\": \"${username//\"/\\\"}\", \"attachments\": [ { \"fallback\": \"${subject//\"/\\\"}\", \"color\": \"${colour}\", \"title\": \"${subject//\"/\\\"}\", \"text\": \"${body//\"/\\\"}\"} ] }"

curl -m 5 -X POST --data-urlencode "${payload}" $url -A 'zabbix-slack-alertscript / https://github.com/amoma-com/zabbix-slack-alertscript'
