Players = new Meteor.Collection('players')
Terrain = new Meteor.Collection('terrain')

if Meteor.isClient
  terrainLayer = undefined
  playerLayer = undefined
  cursorLayer = undefined
  stage = undefined

  _.extend Template.newPlayer,
    events:
      'click button' : ->
        #unless (typeof console is 'undefined')
        #console.log("You pressed the button")
        if ($('#nameInput').val().length < 3)
          console.log("Name must be 3 or more characters.")
        if (Players.findOne({name: $('#nameInput').val()}))
          console.log("That name already exists.")
        else
          Session.set('playerID', Players.insert({name: $('#nameInput').val(), loc: [0, 0]}))
          console.log("Character created!")
          drawMap()
        $('#nameInput').val('')

  _.extend Template.gameContainer,
    player: ->
      playing()

    rendered: ->
      if stage is undefined
        stage = new Kinetic.Stage
          container: 'canvasContainer',
          width: 700,
          height: 500
        stage.on 'mousemove', () ->
          cursor = cursorLayer.getChildren()[0]
          mousePos = stage.getMousePosition()
          x = Math.floor(mousePos.x / 50) * 50
          y = Math.floor(mousePos.y / 50) * 50
          cursor.setAttrs {x: x, y: y}
          cursorLayer.draw()
        stage.on 'click', () ->
          if Session.get('playerID') is undefined
            console.log "No playerID."
            return
          player = playerLayer.get(".#{Session.get('playerID')}")[0]
          mousePos = stage.getMousePosition()
          x = Math.floor(mousePos.x / 50) * 50 + 25
          y = Math.floor(mousePos.y / 50) * 50 + 25
          player.setAttrs {x: x, y: y}
          Players.update(Session.get('playerID'), {$set: {loc: [x, y]}})
      if terrainLayer is undefined
        terrainLayer = new Kinetic.Layer
        stage.add(terrainLayer)
      if cursorLayer is undefined
        cursorLayer = new Kinetic.Layer
        stage.add(cursorLayer)
        cursor = new Kinetic.Rect
          x: 0,
          y: 0,
          height: 50,
          width: 50,
          stroke: "black",
          strokeWidth: 4,
          draggable: true
        cursorLayer.add(cursor)
        cursorLayer.draw()
      if playerLayer is undefined
        playerLayer = new Kinetic.Layer
        stage.add(playerLayer)

  _.extend Template.playing,
    playerName: ->
      Players.findOne({_id: Session.get('playerID')})?.name

  Meteor.autosubscribe () ->
    loc = undefined

    Meteor.subscribe 'loadTerrain', () ->
      Terrain.find({}).forEach (tile) ->
        terrainLayer.add new Kinetic.Rect
          x: tile.x * 50
          y: tile.y * 50
          fill: tile.type
          width: 50
          height: 50
      terrainLayer.draw()

    if Session.get('playerID')
      Meteor.subscribe 'loadPlayer', Session.get('playerID'), () ->
        console.log "subscribed..."
        loc = Players.findOne(Session.get('playerID')).loc
        Meteor.subscribe 'localPlayers', loc

    Players.find().observe
      added: () ->
        console.log "added..."
        drawMap()
      changed: () ->
        console.log "changed..."
        drawMap()
      removed: () ->
        console.log "removed..."
        drawMap()

  drawMap = () ->
    if playerLayer is undefined then return
    playerLayer.removeChildren()
    Players.find().forEach (player) ->
      icon = new Kinetic.Circle
        x: player.loc[0]
        y: player.loc[1]
        radius: 25
        fill: if player._id is Session.get('playerID') then "white" else "black"
        name: player._id
      playerLayer.add(icon)
    playerLayer.moveToTop()
    playerLayer.draw()

  playing = () ->
    Session.get('playerID')?

if Meteor.isServer
	Meteor.startup = () ->
		Terrain.remove({})
		terrainTypes = ["blue", "green", "red"]
		for y in [0..9]
			for x in [0..13]
				Terrain.insert
					x: x,
					y: y,
					type: terrainTypes[Math.floor(Math.random() * terrainTypes.length)]

  Meteor.publish 'loadPlayer', (id) ->
    Players.find(id)

  Meteor.publish 'localPlayers', (loc) ->
    Players.find({loc: {$near: loc, $maxDistance:200}})

  Meteor.publish 'loadTerrain', () ->
    Terrain.find({})

  Meteor.publish 'playersNear', (box) ->
    uuid = Meteor.uuid()
    handle = Players.find({loc: [25,25]}).observe () ->
      change: () ->
        console.log "Changed..."
        this.flush()