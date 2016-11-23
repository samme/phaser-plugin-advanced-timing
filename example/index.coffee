"use strict"

{dat, Phaser} = this

BUNNY_COUNT = 1e4
BUNNY_LIFESPAN = 4000
BUNNY_INTERVAL = 100
BUNNIES_PER_EMIT = 10

debugSettings =
  "debug.gameInfo()": no
  "debug.gameTimeInfo()": no

debugSettingsGui = (_debugSettings, gui) ->
  for key in Object.keys(_debugSettings)
    gui.add _debugSettings, key
  gui

emitterGui = (emitter, gui) ->
  gui.add emitter, "_flowQuantity", 0, 100, 5
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
  gui

@GAME = new Phaser.Game(

  antialias: on
  height: 600
  renderer: Phaser.AUTO
  resolution: 1
  scaleMode: Phaser.ScaleManager.SHOW_ALL
  width: 600

  state:

    init: ->
      {game} = this
      unless game.timing
        game.timing = game.plugins.add Phaser.Plugin.AdvancedTiming
        # game.timing = game.plugins.add Phaser.Plugin.AdvancedTiming, mode: "graph"
      game.clearBeforeRender = off
      game.forceSingleUpdate = off
      game.debug.font = "12px monospace"
      game.debug.lineHeight = 15
      game.scale.fullScreenScaleMode = game.scale.scaleMode
      game.scale.parentIsWindow = yes
      game.tweens.frameBased = on
      game.input.destroy()
      return

    preload: ->
      @load.baseURL = "https://examples.phaser.io/assets/"
      @load.crossOrigin = "anonymous"
      @load.image "bunny", "sprites/wabbit.png"
      @load.image "sky", "skies/cavern2.png"
      return

    create: ->
      world = @world
      @add.image 0, 0, "sky"
      emitter = @emitter = @add.emitter(world.bounds.left, world.centerY, BUNNY_COUNT)
      emitter.makeParticles "bunny"
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
)
