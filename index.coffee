"use strict"

{Phaser} = this

{isFinite} = Number

now = window.performance?.now.bind(window.performance) or Date.now.bind(Date)

Phaser.Plugin.AdvancedTiming = class AdvancedTimingPlugin extends Phaser.Plugin

  @MODE_GRAPH = "graph"
  @MODE_METER = "meter"
  @MODE_TEXT = "text"
  @MODE_DOM_METER = "domMeter"
  @MODE_DOM_TEXT = "domText"
  @MODE_DEFAULT = @MODE_TEXT

  @colors =
    AQUA:   "#7FDBFF"
    BLUE:   "#0074D9"
    GRAY:   "#666666"
    GREEN:  "#2ECC40"
    NAVY:   "#001F3F"
    ORANGE: "#FF851B"
    PURPLE: "#B10DC9"
    RED:    "#FF4136"
    WHITE:  "#FFFFFF"
    YELLOW: "#FFDC00"

  @hexColors =
    AQUA:   0x7FDBFF
    BLUE:   0x0074D9
    GRAY:   0x666666
    GREEN:  0x2ECC40
    NAVY:   0x001F3F
    ORANGE: 0xFF851B
    PURPLE: 0xB10DC9
    RED:    0xFF4136
    WHITE:  0xFFFFFF
    YELLOW: 0xFFDC00

  @modes = [
    @MODE_DEFAULT
    @MODE_GRAPH
    @MODE_METER
    @MODE_TEXT
    @MODE_DOM_METER
    @MODE_DOM_TEXT
  ]

  @renderTypes = [null, "Canvas", "WebGL", "Headless"]

  alpha: 0.75
  enableResumeHandler: yes
  lastTextContent: null
  name: "Advanced Timing Plugin"
  renderDuration: 0
  showDurations: yes
  showElapsed: no
  showSpiraling: yes
  styleDomTextLikeDebugFont: no
  updateDuration: 0
  _mode: null

  Object.defineProperty @prototype, "mode",
    get: ->
      @_mode
    set: (val) ->
      return @_mode if val is @_mode
      switch val
        when @constructor.MODE_GRAPH, @constructor.MODE_METER, @constructor.MODE_TEXT, @constructor.MODE_DOM_TEXT, @constructor.MODE_DOM_METER
          @_mode = val
          @add()
          @activeDisplay = @display[ @_mode ]
        else
          throw new Error "No such mode: '#{val}'"
      @refresh()
      @_mode

  init: (options) ->
    {game} = this
    game.time.advancedTiming = on
    @_gameUpdateLogic  = @game.updateLogic .bind @game
    @_gameUpdateRender = @game.updateRender.bind @game
    @game.updateLogic  = @updateLogic .bind this
    @game.updateRender = @updateRender.bind this
    @group = game.make.group null, "advancedTimingPlugin", yes
    @position = new Phaser.Point
    @renderType = @constructor.renderTypes[game.renderType]
    @reset()
    game.onResume.add @onResume, this
    game.debug.gameInfo = @debugGameInfo.bind this
    game.debug.gameTimeInfo = @debugGameTimeInfo.bind this
    @display = {}
    if options
      {mode} = options
      delete options.mode
      Phaser.Utils.extend this, options
    @mode = mode or @constructor.MODE_DEFAULT
    return

  update: ->
    @group.visible = @visible
    if @visible
      @updateGraph()  if @graphGroup and @graphGroup.visible
      @updateMeters() if @meters     and @meters.visible
      @updateText()   if @text       and @text.visible
      @updateDomMeter() if @domMeter
      @updateDomText() if @domText
    return

  updateLogic: (timeStep) ->
    time = now()
    @_gameUpdateLogic timeStep
    @updateDuration = now() - time
    return

  updateRender: (elapsedTime) ->
    time = now()
    @_gameUpdateRender elapsedTime
    @renderDuration = now() - time
    return

  destroy: ->
    super
    @graph.destroy()
    @group.destroy()
    return

  add: ->
    switch @_mode
      when @constructor.MODE_GRAPH then @addGraph()  unless @graphGroup
      when @constructor.MODE_METER then @addMeters() unless @meters
      when @constructor.MODE_TEXT  then @addText()   unless @text
      when @constructor.MODE_DOM_METER then @addDomMeter() unless @domMeter
      when @constructor.MODE_DOM_TEXT then @addDomText() unless @domText
      else throw new Error "Nothing to add (bad mode: #{@_mode})"
    return

  addDomMeter: ->
    @domMeter = document.createElement 'meter'
    @domMeter.setAttribute 'class', 'ppat-fps ppat-meter'
    @domMeter.setAttribute 'min', 0
    @domMeter.setAttribute 'max', @game.time.desiredFps
    @domMeter.setAttribute 'optimum', @game.time.desiredFps
    @game.canvas.parentNode.appendChild @domMeter;

    @display[ @constructor.MODE_DOM_METER ] = @domMeter

    return

  addDomText: ->
    @domText = document.createElement 'pre'
    @domText.setAttribute 'class', 'ppat-text'
    @domText.style.font = @game.debug.font if @styleDomTextLikeDebugFont
    @game.canvas.parentNode.appendChild @domText;

    @display[ @constructor.MODE_DOM_TEXT ] = @domText

    return

  addGraph: (x = @position.x, y = @position.y) ->
    {desiredFps} = @game.time
    desiredMs = @desiredMs()
    style = fill: "white", font: "10px monospace"

    @graphGroup = @game.add.group @group, "advancedTimingPluginGraphGroup"
    @graphGroup.x = x
    @graphGroup.y = y

    @graph = @game.make.bitmapData 60, 60, "advancedTimingPluginGraph"
    @graph.fill 0, 0, 0

    @graphX = 0
    @graphImage = @game.add.image 0, 0, @graph, null, @graphGroup
    @graphImage.alpha = @alpha
    @graphImage.scale.set 2
    @graphImage.smoothed = no

    {width, height} = @graphImage
    scaleY = @graphImage.scale.y

    @game.add.text width, height - scaleY * desiredFps, "#{desiredFps} fps", style, @graphGroup
    @game.add.text width, height - scaleY * desiredMs,  "#{desiredMs} ms",   style, @graphGroup

    @display[ @constructor.MODE_GRAPH ] = @graphGroup

    return

  addMeter: (name, x, y, key, tint, group) ->
    name = "#{name}Meter"
    meter = group.create x, y, key
    meter.height = 10
    meter.tint = tint
    this[name] = meter

  addMeters: (x = @position.x, y = @position.y) ->
    {hexColors} = @constructor

    bt = @game.make.bitmapData(1, 1).fill(255, 255, 255)

    @meters = @game.add.group @group, "advancedTimingPluginMeters"
    @meters.alpha = @alpha
    @meters.classType = Phaser.Image
    @meters.x = x
    @meters.y = y

    @fpsMeters = @game.add.group @meters, "advancedTimingPluginFpsMeters"
    @elapsedMeters = @game.add.group @meters, "advancedTimingPluginElapsedMeters"
    @durationMeters = @game.add.group @meters, "advancedTimingPluginDurationMeters"

    @addMeter "desiredFps",     0, 0,  bt, hexColors.GRAY,   @fpsMeters
    @addMeter "fps",            0, 0,  bt, hexColors.BLUE,   @fpsMeters
    @addMeter "desiredMs",      0, 20, bt, hexColors.GRAY,   @elapsedMeters
    @addMeter "elapsed",        0, 20, bt, hexColors.GREEN,  @elapsedMeters
    @addMeter "ms",             0, 20, bt, hexColors.YELLOW, @elapsedMeters
    @addMeter "desiredDur",     0, 10, bt, hexColors.GRAY,   @durationMeters
    @addMeter "updateDuration", 0, 10, bt, hexColors.ORANGE, @durationMeters
    @addMeter "renderDuration", 0, 10, bt, hexColors.PURPLE, @durationMeters

    @display[ @constructor.MODE_METER ] = @meters

    return

  addText: (x = @position.x, y = @position.y) ->
    @text = @game.add.text x, y, null,
      fill: @constructor.colors.WHITE
      font: @game.debug.font
    , @group
    @text.name = "advancedTimingPluginText"
    # @text.setTextBounds 10, 10

    @display[ @constructor.MODE_TEXT ] = @text

    return

  debugGameInfo: (x, y, color) ->
    {game} = this
    {debug} = game

    debug.start x, y, color
    debug.line "renderType:         #{@renderType}"
    debug.line "lockRender:         #{game.lockRender}"
    debug.line "forceSingleUpdate:  #{game.forceSingleUpdate}"
    debug.line "updatesThisFrame:   #{game.updatesThisFrame}"
    debug.line "lastCount:          #{game._lastCount}"
    debug.line "spiraling:          #{game._spiraling}"
    debug.stop()

    return

  debugGameTimeInfo: (x, y, color) ->
    {game} = this
    {debug, time} = game

    debug.start x, y, color
    debug.line "fps:                #{time.fps} #{@fpsRangeStr()}"
    debug.line "desiredFps:         #{time.desiredFps}"
    debug.line "suggestedFps:       #{time.suggestedFps}"
    debug.line "elapsed:            #{time.elapsed} ms #{@elapsedRangeStr()}"
    debug.line "elapsedMS:          #{time.elapsedMS} ms"
    debug.line "physicsElapsedMS:   #{time.physicsElapsedMS.toFixed(2)} ms"
    debug.line "slowMotion:         #{time.slowMotion}"
    debug.stop()

    return

  desiredMs: ->
    Math.ceil 1000 / @game.time.desiredFps

  elapsedRange: ->
    @game.time.msMax - @game.time.msMin

  elapsedRangeStr: ->
    {msMax, msMin} = @game.time
    if isFinite(msMax) and isFinite(msMin) then "(#{msMin}–#{msMax})" else ""

  fpsColor: (fps = @game.time.fps) ->
    {desiredFps} = @game.time
    {colors} = @constructor
    switch
      when fps < (desiredFps / 2) then return colors.ORANGE
      when fps <  desiredFps      then return colors.YELLOW
      else                             return colors.WHITE

  fpsRange: ->
    @game.time.fpsMax - @game.time.fpsMin

  fpsRangeStr: ->
    {fpsMax, fpsMin} = @game.time
    if isFinite(fpsMax) and isFinite(fpsMin) then "(#{fpsMin}–#{fpsMax})" else ""

  onResume: ->
    @reset()
    return

  refresh: ->
    for name, obj of @display
      if obj.setAttribute
        if name is @_mode
          obj.removeAttribute "hidden"
        else
          obj.setAttribute "hidden", ""
      else
        obj.visible = name is @_mode
    return

  reset: (fpsMin = Infinity, fpsMax = 0, msMin = Infinity, msMax = 0) ->
    {time} = @game
    time.fpsMin = fpsMin
    time.fpsMax = fpsMax
    time.msMin  = msMin
    time.msMax  = msMax
    return

  resetElapsed: ->
    {time} = @game
    time.elapsed = time.now - time.prevTime
    return

  textContent: ->
    {drawCount} = @game.renderer.renderSession
    "#{@game.time.fps} fps #{@renderType}" + (if drawCount then " (#{drawCount})" else "")

  updateDomMeter: ->
    @domMeter.value = @game.time.fps
    return

  updateDomText: ->
    content = @textContent()

    unless content is @lastTextContent
      @domText.textContent = @lastTextContent = content
      @domText.style.color = @fpsColor()

    return

  updateGraph: ->
    {forceSingleUpdate, _spiraling, updatesThisFrame} = @game
    {elapsed, elapsedMS, fps} = @game.time
    {graph, graphX} = this
    {colors} = @constructor
    {height} = graph

    graph.dirty = yes
    graph.rect graphX, 0, 1, height, "black"

    if fps <= height
      graph.rect graphX, (height - fps),              1, 1, colors.BLUE

    if @showElapsed
      if elapsed <= height
        graph.rect graphX, (height - elapsed),          1, 1, colors.GREEN
      if elapsed isnt elapsedMS and elapsed <= height
        graph.rect graphX, (height - elapsedMS),        1, 1, colors.YELLOW
      unless forceSingleUpdate
        graph.rect graphX, (height - updatesThisFrame), 1, 1, colors.NAVY

    if @showDurations
      graph.rect graphX, (height - ~~@updateDuration),  1, 1, colors.ORANGE
      graph.rect graphX, (height - ~~@renderDuration),  1, 1, colors.PURPLE

    if @showSpiraling and _spiraling > 0
      graph.rect graphX, (height - _spiraling),       1, 1, colors.RED

    @graphX += 1
    @graphX %= graph.width
    return

  updateMeters: ->
    {desiredFps, elapsed, elapsedMS, fps} = @game.time

    desiredMs = @desiredMs()

    @desiredFpsMeter.scale.x = desiredFps
    @fpsMeter.scale.x = fps

    @elapsedMeters.visible = @showElapsed
    if @showElapsed
      @desiredMsMeter.scale.x = desiredMs
      @msMeter.scale.x = elapsedMS
      @elapsedMeter.scale.x = elapsed

    @durationMeters.visible = @showDurations
    if @showDurations
      @desiredDurMeter.scale.x = desiredMs
      @updateDurationMeter.scale.x = @updateDuration
      @renderDurationMeter.scale.x = @renderDuration
      @renderDurationMeter.x = @updateDurationMeter.width

    return

  updateText: ->
    @text.text = @textContent()
    @text.style.fill = @fpsColor()
    return
