import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      title: 'Tic Tac Toe',
      home: const TicTacToe(),
    );
  }
}

class TicTacToe extends StatefulWidget {
  const TicTacToe({Key? key}) : super(key: key);

  @override
  State<TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  int _boardSize = 3; // Default board size
  late List<List<String>> _board;
  late String _player;
  late String _result;
  late int _timerValue;
  late bool _isTimeout;
  late Timer _timer;
  late ValueNotifier<int> _timerNotifier;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _board = List.generate(_boardSize, (_) => List.filled(_boardSize, ''));
    _player = 'X';
    _result = '';
    _timerValue = 15; // Countdown timer value
    _isTimeout = false;
    _timerNotifier = ValueNotifier<int>(_timerValue);
    _startTimer();
  }

  void _play(int row, int col) {
    if (_result.isNotEmpty || _board[row][col].isNotEmpty) {
      return;
    }

    setState(() {
      _board[row][col] = _player;
      _checkWin(row, col);
      if (_result.isEmpty) {
        _player = _player == 'X' ? 'O' : 'X';
        _resetTimer();
      }
    });

    _startTimer();
  }

  void _checkWin(int row, int col) {
    String currentPlayer = _board[row][col];

    bool rowWin = true, colWin = true, diag1Win = true, diag2Win = true;
    for (int i = 0; i < _boardSize; i++) {
      if (_board[row][i] != currentPlayer) rowWin = false;
      if (_board[i][col] != currentPlayer) colWin = false;
      if (_board[i][i] != currentPlayer) diag1Win = false;
      if (_board[i][_boardSize - i - 1] != currentPlayer) diag2Win = false;
    }

    if (rowWin || colWin || diag1Win || diag2Win) {
      _result = '$currentPlayer wins!';
      _stopTimer();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text('Player $currentPlayer has won!'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _reset();
                },
                child: Text('Play Again'),
              ),
            ],
          );
        },
      );
      return;
    }

    bool isDraw = true;
    for (int i = 0; i < _boardSize; i++) {
      for (int j = 0; j < _boardSize; j++) {
        if (_board[i][j].isEmpty) {
          isDraw = false;
          break;
        }
      }
    }

    if (isDraw) {
      _result = "IT'S A DRAW!";
      _stopTimer();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("It's a Draw!"),
            content: Text('The game ended in a draw.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _reset();
                },
                child: Text('Play Again'),
              ),
            ],
          );
        },
      );
    }
  }

  void _reset() {
    _initGame();
  }

  void _changeBoardSize(int size) {
    setState(() {
      _boardSize = size;
      _initGame();
    });
  }

  void _startTimer() {
    _timerValue = 20;
    _timerNotifier.value = _timerValue;
    _isTimeout = false;
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (_timerValue > 0) {
        setState(() {
          _timerValue--;
          _timerNotifier.value = _timerValue;
        });
      } else {
        _isTimeout = true;
        _player = _player == 'X' ? 'O' : 'X';
        _resetTimer();
        _startTimer(); // Start timer for the next player
      }
    });
  }

  void _resetTimer() {
    _timer.cancel();
  }

  void _stopTimer() {
    _timer.cancel();
  }

  Widget _buildBoard() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(20.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _boardSize,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _boardSize * _boardSize,
        itemBuilder: (context, index) {
          int row = index ~/ _boardSize;
          int col = index % _boardSize;
          return GestureDetector(
            onTap: () => _play(row, col),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
                color: _board[row][col] == 'X'
                    ? Colors.red
                    : _board[row][col] == 'O'
                    ? Colors.blue
                    : Colors.white,
              ),
              child: Center(
                child: Text(
                  _board[row][col],
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Select Board Size:',
                style: TextStyle(
                  fontSize: 27.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _changeBoardSize(3),
                child: const Text('3x3'),
              ),
              ElevatedButton(
                onPressed: () => _changeBoardSize(5),
                child: const Text('5x5'),
              ),
              ElevatedButton(
                onPressed: () => _changeBoardSize(7),
                child: const Text('7x7'),
              ),
            ],
          ),
          _buildBoard(),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Player $_player turn',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<int>(
                  valueListenable: _timerNotifier,
                  builder: (_, value, __) {
                    String timerText =
                    _isTimeout ? 'Time\'s Up!' : 'Time left: $value seconds';
                    return Text(
                      timerText,
                      style: TextStyle(
                        fontSize: 24,
                        color: _isTimeout ? Colors.red : Colors.amber,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _result,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _result.isEmpty ? Colors.transparent : Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
