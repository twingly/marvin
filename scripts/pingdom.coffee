# Description:
#   Recieve webhook notifications from Pingdom
#
# Dependencies:
#  "hipchatter": "0.1.3"
#
# Configuration:
#   HUBOT_PINGDOM_USERNAME
#   HUBOT_PINGDOM_PASSWORD
#   HUBOT_PINGDOM_APP_KEY
#   HUBOT_PINGDOM_WEBHOOK_SECRET
#   HUBOT_PINGDOM_HIPCHAT_AUTH_TOKEN
#   HUBOT_PINGDOM_HIPCHAT_ROOM_TOKEN
#   HEROKU_URL
#
# Commands:
#   hubot pingdom set room <roomid>
#   hubot pingdom set roomapiid <room API id>
#   hubot pingdom show url
#   hubot pingdom show room
#
# URLs:
#   /pingdom/webhook/:secret
#
# TODOs:
#   Link to incident https://my.pingdom.com/ims/incidents/<incident>
#   Ping on-call person

username = process.env.HUBOT_PINGDOM_USERNAME
password = process.env.HUBOT_PINGDOM_PASSWORD
appKey = process.env.HUBOT_PINGDOM_APP_KEY
webhookSecret = process.env.HUBOT_PINGDOM_WEBHOOK_SECRET
baseUrl = process.env.HEROKU_URL or "http://localhost:8080"
hipchatAuthToken = process.env.HUBOT_PINGDOM_HIPCHAT_AUTH_TOKEN
hipchatRoomToken = process.env.HUBOT_PINGDOM_HIPCHAT_ROOM_TOKEN

Hipchatter = require "hipchatter"
hipchatter = new Hipchatter hipchatAuthToken

module.exports = (robot) ->
  robot.router.get "/pingdom/webhook/:secret", (req, res) ->
    unless rawMessage = req.param("message")
      res.end "message parameter required"
      return
    message = JSON.parse(rawMessage)
    room = robot.brain.get("pingdomRoom")
    roomApiId = robot.brain.get("pingdomRoomApiId")
    res.end ""

    unless webhookSecret == req.params.secret
      robot.messageRoom room, "Pingdom: Wrong secret"
      return

    auth = new Buffer("#{username}:#{password}").toString("base64")
    robot.http("https://api.pingdom.com")
      .headers(Authorization: "Basic #{auth}", "App-Key": appKey)
      .path("/api/2.0/checks/#{message.check}")
      .get() (err, res, body) ->
        if err
          robot.messageRoom room "Pingdom: error #{err}"
          return
        check = JSON.parse(body).check
        color = switch check.status
          when "up" then "green"
          when "down" then "red"
          else "yellow"

        console.log "Pingdom: #{check.name} is #{check.status}"

        hipchatter.notify roomApiId,
          message: "Pingdom: #{check.name} is #{check.status}"
          color: color
          token: hipchatRoomToken
        , (err) ->
          console.log err if err?
          console.log "Successfully notified the room."  unless err?
          return


  robot.respond /pingdom show url/i, (msg) ->
    msg.reply "#{baseUrl}/pingdom/webhook/#{webhookSecret}"

  robot.respond /pingdom show room/i, (msg) ->
    msg.reply robot.brain.get("pingdomRoom")

  robot.respond /pingdom set room (.*)/i, (msg) ->
    robot.brain.set "pingdomRoom", msg.match[1]

  robot.respond /pingdom set roomapiid (.*)/i, (msg) ->
    robot.brain.set "pingdomRoomApiId", msg.match[1]
