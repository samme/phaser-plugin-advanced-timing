Shows FPS, frame intervals, draw count, and other performance info. [Demo](https://samme.github.io/phaser-plugin-advanced-timing/)

Usage
-----

```javascript
game.plugins.add(Phaser.Plugin.AdvancedTiming);
// or
game.plugins.add(Phaser.Plugin.AdvancedTiming, {mode: 'graph'});
```

The display modes are `domMeter`, `domText`, `graph`, `meter`, and `text`. The default mode is `text`.

You can save a reference to switch modes later:

```javascript
var plugin = game.plugins.add(Phaser.Plugin.AdvancedTiming);
// …
plugin.mode = 'text';
```

The plugin also provides two debug methods:

```javascript
game.debug.gameInfo(x, y);
game.debug.gameTimeInfo(x, y);
```

Beware that [debug display can be slow in WebGL](https://phaser.io/docs/2.6.2/Phaser.Utils.Debug.html).

DOM Text, Text
--------------

![Text Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/text.png)

Both show FPS, render type, and WebGL draw count.

`text` is drawn on the game canvas. `domText` is a separate HTML element.

The `domText` element can be styled as

```css
.ppat-text {
  position: absolute;
  left: 0;
  top: 0;
  margin: 0;
}
```

```javascript
plugin.mode = 'domText';
plugin.mode = 'text';
```

DOM Meter
---------

![DOM Meter Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/domMeter.png)

Shows FPS. It can be styled as

```css
.ppat-fps {
  position: absolute;
  left: 0;
  top: 0;
}
```

```javascript
plugin.mode = 'domMeter';
```

Graph
-----

![Graph Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/graph.png)

Plots values for the last 60 updates:

  - fps              (blue)
  - update duration  (orange)
  - render duration  (violet)
  - spiraling        (red)
  - updatesThisFrame (dark blue; only when [forceSingleUpdate][1] is off)

```javascript
plugin.mode = 'graph';
```

Meter
-----

![Meter Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/meter.png)

Shows FPS (blue) and update duration (orange), and render duration (violet).

```javascript
plugin.mode = 'meter';
```

Debug Methods
-------------

![debug.gameInfo() and debug.gameTimeInfo() output](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/debug.png)

debug.gameInfo
--------------

`game.debug.gameInfo(x, y)` prints

- [game.forceSingleUpdate][1]
- game._lastCount: “how many ‘catch-up’ iterations were used on the logic update last frame”
- [game.lockRender](http://phaser.io/docs/2.6.2/Phaser.Game.html#lockRender)
- [game.renderType](http://phaser.io/docs/2.6.2/Phaser.Game.html#renderType)
- game._spiraling: “if the ‘catch-up’ iterations are spiraling out of control, this counter is incremented”
- [game.updatesThisFrame](http://phaser.io/docs/2.6.2/Phaser.Game.html#updatesThisFrame): “number of logic updates expected to occur this render frame; will be 1 unless there are catch-ups required (and allowed)”

debug.gameTimeInfo
------------------

`game.debug.gameTimeInfo(x, y)` prints

- [game.time.desiredFps](http://phaser.io/docs/2.6.2/Phaser.Time.html#desiredFps)
- [game.time.elapsed](http://phaser.io/docs/2.6.2/Phaser.Time.html#elapsed) (and range)
- [game.time.elapsedMS](http://phaser.io/docs/2.6.2/Phaser.Time.html#elapsedMS)
- [game.time.fps](http://phaser.io/docs/2.6.2/Phaser.Time.html#fps) (and range)
- [game.time.physicsElapsedMS](http://phaser.io/docs/2.6.2/Phaser.Time.html#physicsElapsedMS)
- [game.time.slowMotion](http://phaser.io/docs/2.6.2/Phaser.Time.html#slowMotion)
- [game.time.suggestedFps](http://phaser.io/docs/2.6.2/Phaser.Time.html#suggestedFps)

[1]: http://phaser.io/docs/2.6.2/Phaser.Game.html#forceSingleUpdate
