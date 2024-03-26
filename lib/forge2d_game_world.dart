import 'dart:ui';
import 'package:breakout/components/dead_zone.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:breakout/components/arena.dart';
import 'package:breakout/components/ball.dart';
import 'package:breakout/components/brick_wall.dart';
import 'package:breakout/components/paddle.dart';

enum GameState {
  initializing,
  ready,
  running,
  paused,
  won,
  lost,
}

class Forge2dGameWorld extends Forge2DGame with HasDraggables, HasTappables {
  Forge2dGameWorld() : super(gravity: Vector2.zero(), zoom: 20);

  late final Ball _ball;
  late final Arena _arena;
  late final Paddle _paddle;
  late final DeadZone _deadZone;
  late final BrickWall _brickWall;


  GameState gameState = GameState.initializing;

  @override
  Future<void> onLoad() async {
    await _initialize();
  }

  Future<void> _initialize() async {
    _arena = Arena();
    await add(_arena);

    final brickWallPosition = Vector2(0.0, size.y * 0.075);

    _brickWall = BrickWall(
      position: brickWallPosition,
      rows: 8,
      columns: 6,
      // rows: 1,
      // columns: 1,
    );
    await add(_brickWall);

    final deadZoneSize = Size(size.x, size.y * 0.1);
    final deadZonePosition = Vector2(
      size.x / 2.0,
      size.y - (size.y * 0.1) / 2.0,
    );

    _deadZone = DeadZone(
      size: deadZoneSize,
      position: deadZonePosition,
    );
    await add(_deadZone);

    const paddleSize = Size(4.0, 0.8);
    final paddlePosition = Vector2(
      size.x / 2.0,
      size.y - deadZoneSize.height - paddleSize.height / 2.0,
    );

    _paddle = Paddle(
      size: paddleSize,
      ground: _arena,
      position: paddlePosition,
    );
    await add(_paddle);

    final ballPosition = Vector2(size.x / 2.0, size.y / 2.0 + 10.0);

    _ball = Ball(
      radius: 0.5,
      position: ballPosition,
    );
    await add(_ball);

    gameState = GameState.ready;
    overlays.add('PreGame');
  }

  Future<void> resetGame() async {
    gameState = GameState.initializing;

    _ball.reset();
    _paddle.reset();
    await _brickWall.reset();

    gameState = GameState.ready;

    overlays.remove(overlays.activeOverlays.first);
    overlays.add('PreGame');

    resumeEngine();
  }


  @override
  void update(double dt) {
    super.update(dt);

    if (gameState == GameState.lost || gameState == GameState.won) {
      pauseEngine();
      overlays.add('PostGame');
    }

  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    if (gameState == GameState.ready) {
      overlays.remove('PreGame');
      _ball.body.applyLinearImpulse(Vector2(-10.0, -10.0));
      gameState = GameState.running;
    }
    super.onTapDown(pointerId, info);
  }

}