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

The plugin also provides two [debug methods](#debug-methods):

```javascript
game.debug.gameInfo(x, y);
game.debug.gameTimeInfo(x, y);
```

Beware that [debug display can be slow in WebGL](https://phaser.io/docs/2.6.2/Phaser.Utils.Debug.html).

DOM Text, Text
--------------

```javascript
plugin.mode = 'domText';
plugin.mode = 'text';
```

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
  font: 16px/1 monospace;
}
```

DOM Meter
---------

```javascript
plugin.mode = 'domMeter';
```

![DOM Meter Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/domMeter.png)

Shows FPS. It can be styled as

```css
.ppat-fps {
  position: absolute;
  left: 0;
  top: 0;
}
```

Graph
-----

![Graph Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/graph.png)

```javascript
plugin.mode = 'graph';
```

Plots values for the last 60 updates:

  - fps              (blue)
  - update duration  (orange)
  - render duration  (violet)
  - spiraling        (red)
  - updatesThisFrame (dark blue; only when [forceSingleUpdate][1] is off)

Meter
-----

```javascript
plugin.mode = 'meter';
```

![Meter Mode](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/meter.png)

Shows FPS (blue), update duration (orange), and render duration (violet).

Debug Methods
-------------

```javascript
game.debug.gameInfo(x, y);
game.debug.gameTimeInfo(x, y);
```

![Example output of debug.gameInfo() and debug.gameTimeInfo()](https://samme.github.io/phaser-plugin-advanced-timing/screenshots/debug.png)

### debug.gameInfo()

Prints values for

- [game.forceSingleUpdate][1]
- `game._lastCount`: “how many ‘catch-up’ iterations were used on the logic update last frame”
- [game.lockRender](http://phaser.io/docs/2.6.2/Phaser.Game.html#lockRender)
- [game.renderType](http://phaser.io/docs/2.6.2/Phaser.Game.html#renderType)
- `game._spiraling`: “if the ‘catch-up’ iterations are spiraling out of control, this counter is incremented”
- [game.updatesThisFrame](http://phaser.io/docs/2.6.2/Phaser.Game.html#updatesThisFrame): “number of logic updates expected to occur this render frame; will be 1 unless there are catch-ups required (and allowed)”

### debug.gameTimeInfo()

Prints values for

- [game.time.desiredFps](http://phaser.io/docs/2.6.2/Phaser.Time.html#desiredFps)
- [game.time.elapsed](http://phaser.io/docs/2.6.2/Phaser.Time.html#elapsed) (and range)
- [game.time.elapsedMS](http://phaser.io/docs/2.6.2/Phaser.Time.html#elapsedMS)
- [game.time.fps](http://phaser.io/docs/2.6.2/Phaser.Time.html#fps) (and range)
- [game.time.physicsElapsedMS](http://phaser.io/docs/2.6.2/Phaser.Time.html#physicsElapsedMS)
- [game.time.slowMotion](http://phaser.io/docs/2.6.2/Phaser.Time.html#slowMotion)
- [game.time.suggestedFps](http://phaser.io/docs/2.6.2/Phaser.Time.html#suggestedFps)

[1]: http://phaser.io/docs/2.6.2/Phaser.Game.html#forceSingleUpdate
