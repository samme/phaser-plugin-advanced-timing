"use strict"

{Phaser} = this

{isFinite} = Number

Phaser.Plugin.AdvancedTiming = class AdvancedTimingPlugin extends Phaser.Plugin

  @MODE_GRAPH = "graph"
  @MODE_METER = "meter"
  @MODE_TEXT = "text"
  @MODE_DEFAULT = @MODE_TEXT

  @colors =
    AQUA:   "#7FDBFF"
    BLUE:   "#0074D9"
    GRAY:   "#666666"
    GREEN:  "#2ECC40"
    LIME:   "#01FF70"
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
    LIME:   0x01FF70
    YELLOW: 0xFFDC00

  @modes = [
    @MODE_DEFAULT
    @MODE_GRAPH
    @MODE_METER
    @MODE_TEXT
  ]

  @renderTypes = [null, "CANVAS", "WEBGL", "HEADLESS"]

  alpha: 0.75

  enableResumeHandler: yes

  _mode: null

  Object.defineProperty @prototype, "mode",
    get: ->
      @_mode
    set: (val) ->
      return @_mode if val is @_mode
      switch val
        when @constructor.MODE_GRAPH, @constructor.MODE_METER, @constructor.MODE_TEXT
          @_mode = val
          @add()
          @activeDisplay = @display[ @_mode ]
        else
          throw new Error "No such mode: '#{val}'"
      @refresh()
      @_mode

  name: "Advanced Timing Plugin"

  init: (options) ->
    {game} = this
    game.time.advancedTiming = on
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
      else throw new Error "Nothing to add (bad mode: #{@_mode})"
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

  addMeters: (x = @position.x, y = @position.y) ->
    {hexColors} = @constructor

    bt = @game.make.bitmapData(1, 1).fill(255, 255, 255)
    px = bt.generateTexture "advancedTimingPlugin:pixel"
    bt.destroy()

    @meters = @game.add.group @group, "advancedTimingPluginMeters"
    @meters.alpha = @alpha
    @meters.classType = Phaser.Image
    @meters.x = x
    @meters.y = y

    @desiredFpsMeter = @meters.create 0, 0, px
    @desiredFpsMeter.height = 10
    @desiredFpsMeter.tint = hexColors.GRAY

    @fpsMeter = @meters.create 0, 0, px
    @fpsMeter.height = 10
    @fpsMeter.tint = hexColors.BLUE

    @desiredMsMeter = @meters.create 0, 10, px
    @desiredMsMeter.height = 10
    @desiredMsMeter.tint = hexColors.GRAY

    @elapsedMeter = @meters.create 0, 10, px
    @elapsedMeter.height = 10
    @elapsedMeter.tint = hexColors.GREEN

    @msMeter = @meters.create 0, 10, px
    @msMeter.height = 10
    @msMeter.tint = hexColors.YELLOW

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
    if elapsed <= height
      graph.rect graphX, (height - elapsed),          1, 1, colors.GREEN
    if elapsed isnt elapsedMS and elapsed <= height
      graph.rect graphX, (height - elapsedMS),        1, 1, colors.YELLOW
    unless forceSingleUpdate
      graph.rect graphX, (height - updatesThisFrame), 1, 1, colors.NAVY
    if _spiraling > 0
      graph.rect graphX, (height - _spiraling),       1, 1, colors.RED

    @graphX += 1
    @graphX %= graph.width
    return

  updateMeters: ->
    {desiredFps, elapsed, elapsedMS, fps} = @game.time
    @desiredFpsMeter.scale.x = desiredFps
    @fpsMeter.scale.x = fps
    @desiredMsMeter.scale.x = @desiredMs()
    @msMeter.scale.x = elapsedMS
    @elapsedMeter.scale.x = elapsed
    return

  updateText: ->
    # {desiredFps, elapsed, elapsedMS, fps} = @game.time
    {fps} = @game.time
    # @text.text = "#{fps} fps #{elapsed} ms (#{elapsedMS} ms)"
    @text.text = "#{fps} fps"
    @text.style.fill = @fpsColor fps
    return
