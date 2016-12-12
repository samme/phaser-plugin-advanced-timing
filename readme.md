Phaser Advanced Timing Plugin
=============================

Shows FPS, frame intervals, and performance info.

```javascript
game.plugins.add(Phaser.Plugin.AdvancedTiming);

// Configure (optional)

game.plugins.add(Phaser.Plugin.AdvancedTiming, {mode: 'graph'});

// Save a reference (optional)

var plugin = game.plugins.add(Phaser.Plugin.AdvancedTiming);
```

Graph
-----

![Graph Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/graph.png)

    plugin.mode = 'graph';

Plots values for the last 60 updates:

  - fps              (blue)
  - elapsed          (green)
  - elapsedMS        (yellow)
  - spiraling        (red)
  - updatesThisFrame (dark blue; only when [forceSingleUpdate][1] is off)

Meter
-----

![Meter Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/meter.png)

    plugin.mode = 'meter';

Shows FPS (blue) and frame intervals (yellow: elapsedMS; green: elapsed).

Text
----

![Text Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/text.png)

    plugin.mode = 'text'; // (default mode)

Shows game FPS.

Debug Methods
-------------

[Debug display can be slow in WebGL](https://phaser.io/docs/2.6.2/Phaser.Utils.Debug.html).

![debug.gameInfo() and debug.gameTimeInfo() output](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/debug.png)

Game Loop
---------

`game.debug.gameInfo(x, y)` prints

  - [game.forceSingleUpdate][1]
  - game._lastCount: “how many ‘catch-up’ iterations were used on the logic update last frame”
  - [game.lockRender](http://phaser.io/docs/2.6.2/Phaser.Game.html#lockRender)
  - [game.renderType](http://phaser.io/docs/2.6.2/Phaser.Game.html#renderType)
  - game._spiraling: “if the ‘catch-up’ iterations are spiraling out of control, this counter is incremented”
  - [game.updatesThisFrame](http://phaser.io/docs/2.6.2/Phaser.Game.html#updatesThisFrame): “number of logic updates expected to occur this render frame; will be 1 unless there are catch-ups required (and allowed)”

Game Clock
----------

`game.debug.gameTimeInfo(x, y)` prints

  - [game.time.desiredFps](http://phaser.io/docs/2.6.2/Phaser.Time.html#desiredFps)
  - [game.time.elapsed](http://phaser.io/docs/2.6.2/Phaser.Time.html#elapsed) (and range)
  - [game.time.elapsedMS](http://phaser.io/docs/2.6.2/Phaser.Time.html#elapsedMS)
  - [game.time.fps](http://phaser.io/docs/2.6.2/Phaser.Time.html#fps) (and range)
  - [game.time.physicsElapsedMS](http://phaser.io/docs/2.6.2/Phaser.Time.html#physicsElapsedMS)
  - [game.time.slowMotion](http://phaser.io/docs/2.6.2/Phaser.Time.html#slowMotion)
  - [game.time.suggestedFps](http://phaser.io/docs/2.6.2/Phaser.Time.html#suggestedFps)

[1]: http://phaser.io/docs/2.6.2/Phaser.Game.html#forceSingleUpdate
