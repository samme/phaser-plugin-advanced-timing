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

gameInfo(), gameTimeInfo()
--------------------------

![debug.gameInfo() and debug.gameTimeInfo() output](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/debug.png)

`game.debug.gameInfo(x, y)` prints

  - game.forceSingleUpdate
  - game.lastCount
  - game.lockRender
  - game.renderType
  - game.spiraling
  - game.updatesThisFrame

`game.debug.gameTimeInfo(x, y)` prints

  - game.time.desiredFps
  - game.time.elapsed
  - game.time.elapsedMS
  - game.time.fps
  - game.time.physicsElapsedMS
  - game.time.slowMotion
  - game.time.suggestedFps

[1]: http://phaser.io/docs/2.6.2/Phaser.Game.html#forceSingleUpdate
