import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<int> snakePosition = [45, 65, 85, 105];
  int foodLocation = Random().nextInt(700);
  bool isPlaying = false;
  Direction direction = Direction.down;
  List<int> availableSpots = List.generate(760, (index) => index);

  startGame() {
    isPlaying = true;
    snakePosition = [45, 65, 85, 105];
    direction = Direction.down;
    availableSpots = List.generate(760, (index) => index);
    availableSpots.removeWhere((spot) => snakePosition.contains(spot));
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (isPlaying) {
        updateSnake();
        if (gameOver()) {
          gameOverAlert();
          timer.cancel();
        }
      }
    });
  }

  updateSnake() {
    setState(() {
      switch (direction) {
        case Direction.down:
          if (snakePosition.last > 740) {
            snakePosition.add(snakePosition.last - 760 + 20);
          } else {
            snakePosition.add(snakePosition.last + 20);
          }
          break;
        case Direction.up:
          if (snakePosition.last < 20) {
            snakePosition.add(snakePosition.last + 760 - 20);
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break;
        case Direction.right:
          if ((snakePosition.last + 1) % 20 == 0) {
            snakePosition.add(snakePosition.last + 1 - 20);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
        case Direction.left:
          if (snakePosition.last % 20 == 0) {
            snakePosition.add(snakePosition.last - 1 + 20);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
      }

      if (snakePosition.last == foodLocation) {
        availableSpots.remove(foodLocation);
        foodLocation = availableSpots[Random().nextInt(availableSpots.length)];
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  bool gameOver() {
    final copyList = List.from(snakePosition);
    if (snakePosition.length > copyList.toSet().length) {
      return true;
    } else {
      return false;
    }
  }

  gameOverAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your score is ${snakePosition.length - 4}'),
          actions: [
            TextButton(
              onPressed: () {
                startGame();
                Navigator.of(context).pop();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (direction != Direction.up && details.delta.dy > 0) {
              direction = Direction.down;
            }
            if (direction != Direction.down && details.delta.dy < 0) {
              direction = Direction.up;
            }
          },
          onHorizontalDragUpdate: (details) {
            if (direction != Direction.left && details.delta.dx > 0) {
              direction = Direction.right;
            }
            if (direction != Direction.right && details.delta.dx < 0) {
              direction = Direction.left;
            }
          },
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 760,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 20,
            ),
            itemBuilder: (context, index) {
              if (snakePosition.contains(index)) {
                return Container(
                  color: Colors.green,
                );
              }
              if (index == foodLocation) {
                return Container(
                  color: Colors.red,
                );
              }
              return Container(
                color: Colors.black,
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          startGame();
        },
        child: isPlaying
            ? Text('Score: ${snakePosition.length - 4}')
            : const Text('Start'),
      ),
    );
  }
}

enum Direction { up, down, left, right }
