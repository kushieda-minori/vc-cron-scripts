
import requests
import argparse

#parse the command line args
parser = argparse.ArgumentParser(description='Send a POST request.')
parser.add_argument('url', type=str, default='http://localhost', help='The URL to send the POST request to. This should be in a format of "https://discordapp.com/api/webhooks/API/Key"')
parser.add_argument('message', type=str, default='Sample Message', help='The message that the webhook will post to the channel')
args = parser.parse_args()

# Prepare the data
data = {'content': args.message}

# Send the POST request
requests.post(args.url, json=data)
# if you want to log the response or use it for something, you can do this.
#response = requests.post(args.url, json=data)
#log.debug(response.json())
