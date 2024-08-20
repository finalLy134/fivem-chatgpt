# fivem-chatgpt
A FiveM Script that lets you talk to NPCs ingame.

## Requirements & What are we Using
- pma-voice
- voice-recognition ([FiveM-Mumble-Auto-Moderation](https://github.com/Dalrae1/FiveM-Mumble-Auto-Moderation))
- ChatGPT's API
- Unreal Speech's TTS API

## Credits
Huge credit to CharlesHacks's YouTube Video on his project about this.

And of course to these amazing resources that are used in this project.

## How to setup?
First of all you need to get an API Key for the ChatGPT's API.
This thing costs money, for testing I just deposited 5$ into the API just to see if it works.
You can find it [Here](https://platform.openai.com/settings/organization/billing/overview)

Next up after you got your API key, you need to make an Unreal Speech API Key, this is for free for trial if im not wrong.
This is for the Text to speech system, you can find it [Here](https://unrealspeech.com/)

After you've done all of that you'd need to navigate to your server.cfg where you'll find a convar saying `openai_api_key` change it to your ChatGPT api key, and another api key there saying `unrealspeech_api_key`. Change it too.

After you've set all of these things up, You're ready to start using the script.
Make sure you've started the script in your server.cfg and he's started and then open this file: `/voice-recognition/setup.bat` and after the installation has finished open `/voice-recognition/start.bat`
It will start a server that will hook into your mumble voice chat and listen to every thing players say.

After all of this you can just walk up to NPCs and see if it works.
**ALSO NOTE** that since Unreal Speech in his free plan is a very slow API you'll get a response from the NPC after something like 10 seconds or so, so it doesn't mean it is not working it means that there's delay and it is okay.

## Important
Since we are using Unreal Speech's TTS API and he's very slow at giving us the response for our TTS you might wait ~15s everytime you talk to an NPC.
So this project isn't really for regular servers (Roleplay/DM whatever). He's more for the educational part and actually talking to NPCs in the game.
So just note, the conversations are slow :D
