local humanPeds = json.decode(LoadResourceFile(GetCurrentResourceName(), 'data/human-peds.json'))
local conversations = {}

RegisterCommand('chatgpt:transcript', function(source, args, rawCommand)
  local data          = json.decode(string.sub(rawCommand, 21))
  local serverId      = string.match(data.Username, "%[(%d+)%]")
  local transcription = data.Message
  local playerState   = Player(serverId).state
  local targetedPed   = playerState.targetedPed
  local pedEntityId   = NetworkGetEntityFromNetworkId(targetedPed)
  local pedModel      = tostring(GetEntityModel(pedEntityId))

  if not targetedPed or not pedEntityId or not pedModel then
    return
  end

  if not humanPeds[pedModel] then
    return
  end

  if not transcription or string.len(transcription) < 3 then
    return
  end

  if not conversations[serverId] then
    conversations[serverId] = {}
  end

  Entity(pedEntityId).state:set('isThinking', true, true)

  if not conversations[serverId][targetedPed] then
    setupConversation(serverId, targetedPed, pedModel)
  end

  generateResponse(serverId, targetedPed, pedModel, transcription)
end)

-- Functions

function generateResponse(playerId, pedId, pedModel, message)
  table.insert(conversations[playerId][pedId], {
    role    = 'user',
    content = message
  })

  PerformHttpRequest('https://api.openai.com/v1/chat/completions', function(code, data, headers)
    if code ~= 200 then
      Entity(NetworkGetEntityFromNetworkId(pedId)).state:set('isThinking', false, true)
    end

    local _data = json.decode(data)
    local response = _data.choices[1].message.content

    table.insert(conversations[playerId][pedId], {
      role = 'assistant',
      content = response
    })

    local ttsUrl = nil

    PerformHttpRequest('https://api.v6.unrealspeech.com/synthesisTasks', function(code, data, headers)
      if code ~= 200 then
        Entity(NetworkGetEntityFromNetworkId(pedId)).state:set('isThinking', false, true)
      end

      local __data = json.decode(data)
      ttsUrl = __data.SynthesisTask.OutputUri
    end, 'POST', json.encode({
      Text = response,
      VoiceId = Config.Voices[humanPeds[pedModel].gender],
      Bitrate = "192k",
      Speed = "0",
      Pitch = "1",
      TimestampType = "sentence",
    }), {
      ['Content-Type'] = 'application/json',
      ['Authorization'] = ('Bearer %s'):format(Config.TTSAPIKey),
    })


    if not ttsUrl then
      Entity(NetworkGetEntityFromNetworkId(pedId)).state:set('isThinking', false, true)
    end

    local soundReady = false

    while not soundReady do
      PerformHttpRequest(ttsUrl, function(code)
        if code == 200 then
          soundReady = true
        end
      end, 'GET', nil, {})
      Citizen.Wait(1)
    end

    local soundId = exports.sounity:CreateSound(ttsUrl)

    exports.sounity:AttachSound(soundId, pedId)
    exports.sounity:StartSound(soundId)

    Entity(NetworkGetEntityFromNetworkId(pedId)).state:set('isThinking', false, true)
    Entity(NetworkGetEntityFromNetworkId(pedId)).state:set('isSpeaking', true, true)

    Citizen.SetTimeout(5000, function()
      Entity(NetworkGetEntityFromNetworkId(pedId)).state:set('isSpeaking', false, true)
    end)
  end, 'POST', json.encode({
    model = Config.ChatGPTModel,
    messages = conversations[playerId][pedId],
  }), {
    ['Content-Type'] = 'application/json',
    ['Authorization'] = ('Bearer %s'):format(Config.APIKey),
  })
end

function setupConversation(playerId, pedId, pedModel)
  local pedData      = humanPeds[pedModel]
  local playerState  = Player(playerId).state
  local currentTime  = exports.weathersync:getTime()
  local systemPrompt = Config.SystemPrompt

  local variables    = {
    GENDER       = pedData.gender,
    PERSONALITY  = pedData.personality,
    TIME_HOUR    = currentTime.hour,
    TIME_MINUTE  = currentTime.minute,
    WEATHER      = exports.weathersync:getWeather(),
    STREET       = playerState.curStreetName or 'Unknown',
    CROSS_STREET = playerState.curCrossStreetName or 'Unknown'
  }

  for k, v in pairs(variables) do
    systemPrompt = systemPrompt:gsub(('{%s}'):format(k), v)
  end

  conversations[playerId][pedId] = {}

  table.insert(conversations[playerId][pedId], {
    role = 'system',
    content = systemPrompt
  })
end
