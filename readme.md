# Sokoban Barebones
![Showcase](showcase.gif)

A really simplistic boilerplate for your Sokoban puzzle based on the Heaps.io engine.

## Features
- Basic Sokoban gameplay
- Undo / Redo functionality
- Save / Load progress
- Multiple playable characters at once (desperatea style!)
- Example CastleDB project for level data
- Built-in .pak generator for the assets (using [Heeps library](https://github.com/Yanrishatum/heeps))

## Dependencies
- [Heaps.io](https://github.com/HeapsIO/heaps)
- [CastleDB](https://lib.haxe.org/p/castle)

## Controls
- WASD / Arrows - Movement
- Z / Y - Undo / Redo
Add your own controls by modifying the `InputManager` class!

## Debug hotkeys
- R - Restart
- B / N - Previous / Next level
These are defined in the `update` function inside the `Game` class.

## What to do next?
- Provide a clear winning condition
- Add custom `entities`!
- Design some clever levels
- Make some fancy custom graphics (by modifying `avatars`)