# Description:
#   Recieve webhook notifications from Atlas
#
# Dependencies:
#  "hipchatter": "0.1.3"
#
# Configuration:
#   HUBOT_ATLAS_WEBHOOK_SECRET
#   HUBOT_ATLAS_HIPCHAT_AUTH_TOKEN
#   HUBOT_ATLAS_HIPCHAT_ROOM_TOKEN
#   HEROKU_URL
#
# Commands:
#   hubot atlas set room <roomid>
#   hubot atlas set roomapiid <room API id>
#   hubot atlas show url
#   hubot atlas show room
#
# URLs:
#   /atlas/webhook/:secret
#

webhookSecret = process.env.HUBOT_ATLAS_WEBHOOK_SECRET
baseUrl = process.env.HEROKU_URL or "http://localhost:8080"
hipchatAuthToken = process.env.HUBOT_ATLAS_HIPCHAT_AUTH_TOKEN
hipchatRoomToken = process.env.HUBOT_ATLAS_HIPCHAT_ROOM_TOKEN

Hipchatter = require "hipchatter"
hipchatter = new Hipchatter hipchatAuthToken

module.exports = (robot) ->
  robot.router.post "/atlas/webhook/:secret", (req, res) ->
    alert = req.body.consul_alert

    room = robot.brain.get("atlasRoom")
    roomApiId = robot.brain.get("atlasRoomApiId")
    res.end "ok"

    unless webhookSecret == req.params.secret
      robot.messageRoom room, "Atlas: Wrong secret"
      return

    status = alert.status
    node = alert.health_check.node
    checkname = alert.health_check.check_name

    color = switch status
      when "passing" then "green"
      when "critical" then "red"
      else "yellow"

    hipchatMessage = "Atlas: #{checkname} is #{status} on #{node}"
    console.log hipchatMessage

    hipchatter.notify roomApiId,
      message: hipchatMessage
      color: color
      token: hipchatRoomToken
    , (err) ->
      console.log err if err?
      console.log "Successfully notified the room."  unless err?
      return

  robot.respond /atlas show url/i, (msg) ->
    msg.reply "#{baseUrl}/atlas/webhook/#{webhookSecret}"

  robot.respond /atlas show room/i, (msg) ->
    msg.reply robot.brain.get("atlasRoom")

  robot.respond /atlas set room (.*)/i, (msg) ->
    robot.brain.set "atlasRoom", msg.match[1]

  robot.respond /atlas set roomapiid (.*)/i, (msg) ->
    robot.brain.set "atlasRoomApiId", msg.match[1]
