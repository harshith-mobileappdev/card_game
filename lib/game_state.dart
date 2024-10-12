import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class GameState extends ChangeNotifier {
  List<bool> cardFlipped = List.generate(8, (index) => false);

  List<String> faceUpImages = [
    'assets/number10.jpg',
    'assets/numberj.jpg',
    'assets/numberQ.jpg',
    'assets/numberk.jpg',
    'assets/number10.jpg',
    'assets/numberj.jpg',
    'assets/numberQ.jpg',
    'assets/numberk.jpg',
  ];

  List<int> flippedCards = [];
  List<int> matchedCards = [];

  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isGameActive = false;

  int _score = 0;
  int _bestScore = 0;
  int _bestTimeSeconds = 0;

  GameState() {
    faceUpImages.shuffle();
  }

  String get formattedTime {
    int minutes = _secondsElapsed ~/ 60;
    int seconds = _secondsElapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedBestTime {
    if (_bestTimeSeconds == 0)
      return '--:--'; // Display default if no best time
    int minutes = _bestTimeSeconds ~/ 60;
    int seconds = _bestTimeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get score => _score;
  int get bestScore => _bestScore;

  bool get isGameWon => matchedCards.length == cardFlipped.length;

  void _startTimer() {
    _isGameActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _isGameActive = false;
  }

  void flipCard(int index) {
    if (cardFlipped[index] || matchedCards.contains(index)) return;

    if (!_isGameActive) {
      _startTimer();
    }

    cardFlipped[index] = true;
    flippedCards.add(index);

    if (flippedCards.length == 2) {
      if (faceUpImages[flippedCards[0]] == faceUpImages[flippedCards[1]]) {
        matchedCards.addAll(flippedCards);
        _score += 10;
        flippedCards.clear();
        shuffleUnmatchedCards();

        if (matchedCards.length == cardFlipped.length) {
          _stopTimer();
          _updateBestScores(); // Update best score and time when game finishes
        }
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          cardFlipped[flippedCards[0]] = false;
          cardFlipped[flippedCards[1]] = false;
          flippedCards.clear();
          notifyListeners();
        });
      }
    }

    notifyListeners();
  }

  void shuffleUnmatchedCards() {
    List<int> unmatchedIndices = [];
    for (int i = 0; i < faceUpImages.length; i++) {
      if (!matchedCards.contains(i) && !cardFlipped[i]) {
        unmatchedIndices.add(i);
      }
    }
    unmatchedIndices.shuffle();

    List<String> shuffledImages = List.from(faceUpImages);
    int index = 0;
    for (int i = 0; i < faceUpImages.length; i++) {
      if (!matchedCards.contains(i)) {
        shuffledImages[i] = faceUpImages[unmatchedIndices[index]];
        index++;
      }
    }

    faceUpImages = shuffledImages;
    notifyListeners();
  }

  void _updateBestScores() {
    if (_score > _bestScore) {
      _bestScore = _score;
    }
    if (_bestTimeSeconds == 0 || _secondsElapsed < _bestTimeSeconds) {
      _bestTimeSeconds = _secondsElapsed;
    }
    notifyListeners();
  }

  void resetGame() {
    cardFlipped = List.generate(8, (index) => false);
    matchedCards.clear();
    faceUpImages.shuffle();
    _stopTimer();
    _secondsElapsed = 0;
    _score = 0;
    notifyListeners();
  }
}
