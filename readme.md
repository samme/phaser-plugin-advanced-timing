[Demo](https://samme.github.io/phaser-plugin-advanced-timing/)

```javascript
game.plugins.add(Phaser.Plugin.AdvancedTiming);
// The default display ('text') shows FPS and render type

// You can set the display mode at startup:
// Example: graph display
game.plugins.add(Phaser.Plugin.AdvancedTiming, {mode: 'graph'});
// Example: meter display
game.plugins.add(Phaser.Plugin.AdvancedTiming, {mode: 'meter'});

// You can save a reference to set/switch modes later
var plugin = game.plugins.add(Phaser.Plugin.AdvancedTiming);
// …
plugin.mode = 'text';
```

Graph
-----

![Graph Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/graph.png)

Plots values for the last 60 updates:

  - fps              (blue)
  - elapsed          (green)
  - elapsedMS        (yellow)
  - spiraling        (red)
  - updatesThisFrame (dark blue; only when [forceSingleUpdate][1] is off)

```javascript
plugin.mode = 'graph';
```

Meter
-----

![Meter Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/meter.png)

Shows FPS (blue) and frame intervals (yellow: elapsedMS; green: elapsed).

```javascript
plugin.mode = 'meter';
```

Text
----

![Text Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/text.png)

Shows game FPS and render type.

```javascript
plugin.mode = 'text'; // (default mode)
```

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
