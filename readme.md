Phaser Advanced Timing Plugin
=============================

Shows FPS, frame intervals, and performance info.

    game.plugins.add( Phaser.Plugin.AdvancedTiming );

    // Configure (optional)

    game.plugins.add(Phaser.Plugin.AdvancedTiming, {mode: 'graph'});

    // Save a reference (optional)

    var plugin = game.plugins.add(Phaser.Plugin.AdvancedTiming);

Graph
-----

    plugin.mode = 'graph';

Plots values for the last 60 updates:

  - fps              (blue)
  - elapsed          (green)
  - elapsedMS        (yellow)
  - spiraling        (red)
  - updatesThisFrame (dark blue; only when forceSingleUpdate is off)

Meter
-----

    plugin.mode = 'meter';

Shows FPS (blue) and frame intervals (yellow).

Text
----

    plugin.mode = 'text'; // (default mode)

Shows game FPS.

gameInfo()
----------

    game.debug.gameInfo(x, y)

prints

  - game.forceSingleUpdate
  - game.lastCount
  - game.lockRender
  - game.renderType
  - game.spiraling
  - game.updatesThisFrame

gameTimeInfo()
--------------

    game.debug.gameTimeInfo(x, y)

prints

  - game.time.desiredFps
  - game.time.elapsed
  - game.time.elapsedMS
  - game.time.fps
  - game.time.physicsElapsedMS
  - game.time.slowMotion
  - game.time.suggestedFps
