# vc-cron-scripts

These scripts are used for Discord integration. they can be used by creating a "web hook" on a specific channel and then passing that URL to the script as the last parameter.

They will work on Linux or BSD. Runing under WSL on Windows is unknown. If you try it, let me know if it works.

**NOTE:** None of these scripts use proper escaping of the message before placing it into the Payload that is sent to Discord. If the message is not a properly escaped JSON string, then discord may fail to process it.

## discord-webhook-VC.sh

This is a generic webhook script that can be used to send a message. 

Parameters:

1. Message to send
1. Webhook URL

General usage is:

```sh
discord-webhook-VC.sh 'My awesome Message!!!1!' 'https://discordapp.com/api/webhooks/API/Key'
```

## discord-webhook-ABB.sh

This script is geared towards notifying when the next Alliance Battle round will be starting. It will not notifiy if the next round is more than 1 hour away. It's generally geard toward running on a schedule like [Cron](https://en.wikipedia.org/wiki/Cron).

The script accepts up to 5 parameters:

1. Year of the start date of the ABB
1. Month of th estart date of the ABB
1. Day of the start date of the ABB
1. Discord Mention format
1. Webhook URL

The first 4 parameters are required, but can be left blank. If left blank, then they will use default values hard coded in the script. This can be useful if you have multiple jobs calling the script and wish to change the date in only one place.

Simple Call:

```sh
discord-webhook-ABB.sh '' '' '' '' 'https://discordapp.com/api/webhooks/API/Key'
```

Call using a mention:

```sh
discord-webhook-ABB.sh '' '' '' '<@&2345987235896029>' 'https://discordapp.com/api/webhooks/API/Key'
```

Call using a specific start date and mention:

```sh
discord-webhook-ABB.sh '2020' '11' '26' '<@&2345987235896029>' 'https://discordapp.com/api/webhooks/API/Key'
```

Example Cron Jobs are below. Here I use the date configured in the script so I only need to change the date in 1 location insead of 3 every month. You will also notice that I don't limit the cron job to specific dates or hours of the day. The script itself checks for correct timing befor outputting a message. However, the script will never output a message longer in advance of 1 hour.

```sh
# ABB START (and 60 minute warning)
0 * * * * discord-webhook-ABB.sh '' '' '' '<@&2345987235896029>' 'https://discordapp.com/api/webhooks/API/Key'
# ABB 10 minute warning
50 * * * * discord-webhook-ABB.sh '' '' '' '<@&2345987235896029>' 'https://discordapp.com/api/webhooks/API/Key'
# ABB 5 minute warning
55 * * * * discord-webhook-ABB.sh '' '' '' '<@&2345987235896029>' 'https://discordapp.com/api/webhooks/API/Key'
```

These can also be combined onto a single cron line. Configuring this way will also allow you to use the date setting in the CRON job instead of the script.

```sh
# ABB notices (60, 10, 5, and 0 minute warnings)
0,50,55 * * * * discord-webhook-ABB.sh '2020' '11' '27' '<@&2345987235896029>' 'https://discordapp.com/api/webhooks/API/Key'
```

Example messages from the above cron jobs as seen in Discord:

> ABB Round 1 in 60 minutes! @members

> ABB Round 1 in 10 minutes! @members

> ABB Round 1 in 5 minutes! @members

> ABB Round 1 START! @members


## discord-webhook-CastleTime.sh

This script is geared towards notifying when Free Vitality is available through the Castle in game. The script is meant to be run every hour, however it will only output at the correct times.

The script accepts up to 1 parameter:

1. Webhook URL

Example Cron Jobs are below. Here I use the date configured in the script so I only need to change the date in 1 location insead of 3 every month:

```sh
# VC Castle Vit notice
0 * * * discord-webhook-CastleTime.sh 'https://discordapp.com/api/webhooks/API/Key'
```

Example messages from the above cron jobs as seen in Discord:

> One free Castle vitality starting now, ending in 2 hours