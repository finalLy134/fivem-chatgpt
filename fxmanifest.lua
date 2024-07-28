fx_version 'cerulean'
game 'gta5'

author 'finalLy <amitaidvora81@gmail.com>'
description 'Lets you talk to NPCs using ChatGPT API.'
version '1.0.0'

dependencies {
    'pma-voice',
    'weathersync',
    'sounity'
}

shared_script 'config.lua'
client_script 'client/client.lua'
server_scripts {
    'server/server.lua',
}

files {
    'data/human-peds.json',
    'voice-recognition/*',
}
