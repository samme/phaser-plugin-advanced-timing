"use strict"

{dat, Phaser} = this

{SECOND} = Phaser.Timer

BUNNY_COUNT = 1e4
BUNNY_LIFESPAN = 10 * SECOND
BUNNY_INTERVAL = 100
BUNNIES_PER_EMIT = 10
RENDER_MODE = Phaser.WEBGL

debugSettings =
  "debug.gameInfo()": no
  "debug.gameTimeInfo()": no

debugSettingsGui = (_debugSettings, gui) ->
  for key in Object.keys(_debugSettings)
    gui.add _debugSettings, key
  gui

emitterGui = (emitter, gui) ->
  gui.add emitter, "_flowQuantity", 0, 100, 5
  gui.add emitter, "frequency", 0, 1 * SECOND, 50
  gui.add emitter, "lifespan", 0, 10 * SECOND, 100
  gui.add emitter, "makeBunnies"
  gui.add emitter, "maxParticles"
  gui.add emitter, "length"
    .listen()
  gui.add emitter, "removeAll"
  gui.add emitter, "on"
  gui

gameGui = (game, gui) ->
  gui.add game, "disableStep"
  gui.add game, "enableStep"
  gui.add game, "forceSingleUpdate"
  gui.add game, "lockRender"
  gui.add game, "paused"
  gui.add game, "step"
  gui

gameScaleGui = (scale, gui) ->
  gui.add scale, "fullScreenScaleMode",
    NO_SCALE: Phaser.ScaleManager.NO_SCALE
    RESIZE: Phaser.ScaleManager.RESIZE
    SHOW_ALL: Phaser.ScaleManager.SHOW_ALL
  gui.add scale, "scaleMode",
    NO_SCALE: Phaser.ScaleManager.NO_SCALE
    RESIZE: Phaser.ScaleManager.RESIZE
    SHOW_ALL: Phaser.ScaleManager.SHOW_ALL
  gui.add scale, "startFullScreen"

gameTimeGui = (time, gui) ->
  gui.add time, "desiredFps", 5, 120, 5
  gui.add time, "refresh"
  gui.add time, "reset"
  gui.add time, "slowMotion", 0, 2, 0.25
  gui

pluginGui = (plugin, gui) ->
  {constructor} = plugin
  gui.add plugin, "active"
  gui.add plugin, "mode", constructor.modes
  gui.add plugin, "reset"
  gui.add plugin, "visible"
  gui.add plugin, "showElapsed"
  gui.add plugin, "showDurations"
  gui.add plugin, "showSpiraling"
  gui

@GAME = new Phaser.Game(

  antialias: on
  height: window.innerHeight
  renderer: RENDER_MODE
  resolution: 1
  scaleMode: Phaser.ScaleManager.NO_SCALE
  width: window.innerWidth

  state:

    init: ->
      {game} = this
      game.clearBeforeRender = off
      game.forceSingleUpdate = off
      game.debug.font = "16px monospace"
      game.debug.lineHeight = 20
      game.scale.fullScreenScaleMode = game.scale.scaleMode
      game.scale.parentIsWindow = yes
      game.tweens.frameBased = on
      game.input.destroy()
      unless game.timing
        game.timing = game.plugins.add Phaser.Plugin.AdvancedTiming
        # game.timing = game.plugins.add Phaser.Plugin.AdvancedTiming, mode: "domText"
        # game.timing.meters.scale.set 2
      return

    preload: ->
      @load.baseURL = "https://examples.phaser.io/assets/"
      @load.crossOrigin = "anonymous"
      @load.image "bunny", "sprites/wabbit.png"
      @load.image "sky", "skies/cavern2.png"
      return

    create: ->
      world = @world
      sky = @add.image 0, 0, "sky"
      sky.height = world.height
      sky.width = world.width
      emitter = @emitter = @add.emitter(world.bounds.left, world.centerY, BUNNY_COUNT)
      emitter.makeBunnies = @emitterMakeBunnies.bind emitter
      emitter.makeBunnies()
      emitter.flow BUNNY_LIFESPAN, BUNNY_INTERVAL, BUNNIES_PER_EMIT
      @add.tween(emitter).to { emitX: world.width }, 2000, Phaser.Easing.Sinusoidal.InOut, yes, 0, -1, yes
      @gui = new dat.GUI width: 320
      emitterGui emitter, @gui.addFolder "bunnies"
      gameGui @game, @gui.addFolder "game"
      gameScaleGui @game.scale, @gui.addFolder "game.scale"
      gameTimeGui @game.time, @gui.addFolder "game.time"
      pluginGui @game.timing, pluginGuiFolder = @gui.addFolder "plugin"
      pluginGuiFolder.open()
      debugSettingsGui debugSettings, @gui.addFolder "debug"
      return

    render: ->
      {debug} = @game
      debug.gameInfo 300, 20      if debugSettings["debug.gameInfo()"]
      debug.gameTimeInfo 300, 120 if debugSettings["debug.gameTimeInfo()"]
      return

    shutdown: ->
      @gui.destroy()
      return

    emitterMakeBunnies: ->
      @makeParticles "bunny", null, @maxParticles
      return
)
