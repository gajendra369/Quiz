import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(
        duration: 4, //duration of splash screen
        navigateAfterDuration: NameEntryPage(), //screen to display after splash screen
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final int duration;
  final Widget navigateAfterDuration;

  const SplashScreen({
    Key? key,
    required this.duration,
    required this.navigateAfterDuration,
  }) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: widget.duration), () { //set timer for splash screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => widget.navigateAfterDuration,
        ),
      );
    });
    _controller = AnimationController( //animate the text
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Slide from left to right
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0, // Fully transparent
      end: 1.0, // Fully opaque
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(left: 280.0),
        child: Row(
          children: [
            Image.asset(
              'assets/welcome.png',
              width: 150,
              height: 200,
            ),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  ' Quiz Time - Prove Your Smarts!',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class QuizQuestion { //class that gives format of quiz questions
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

class QuizPage extends StatefulWidget { //page for quiz questions
  final String name;

  const QuizPage({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  double progress = 1.0; // Initial progress (100%)
  Timer? questionTimer;
  int remainingTime = 1000;//time for each question in milliseconds
  int remSecond = 10;

  @override
  void initState() {
    super.initState();
    startQuestionTimer(); // Start the timer when the page loads
  }

  void startQuestionTimer() {
    questionTimer?.cancel();
    questionTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        if (remainingTime <= 0) {
          timer.cancel();
          // Auto-select an option when time is up (you can customize this behavior)
          selectOption(quizQuestions[currentQuestionIndex].options[0]);
        } else {
          remainingTime -= 1;
          if (remainingTime % 100 == 0) remSecond--;
          // Calculate progress as a fraction of remaining time
          progress = remainingTime / 1000.0;
        }
      });
    });
  }

  void selectOption(String option) {
    selectedAnswers[currentQuestionIndex] = option;
    remainingTime = 1000;
    remSecond = 10;
    nextQuestion(context); // Move to the next question automatically
  }

  final List<QuizQuestion> quizQuestions = [ //different questions with their options and answers
    QuizQuestion(
      question: 'What is the capital of France?',
      options: ['Paris', 'Berlin', 'Madrid', 'Rome'],
      correctAnswer: 'Paris',
    ),
    QuizQuestion(
      question: 'Which planet is known as the Red Planet?',
      options: ['Earth', 'Mars', 'Venus', 'Jupiter'],
      correctAnswer: 'Mars',
    ),
    QuizQuestion(
      question: 'What is the largest mammal in the world?',
      options: ['Elephant', 'Giraffe', 'Blue Whale', 'Hippopotamus'],
      correctAnswer: 'Blue Whale',
    ),
    QuizQuestion(
      question: 'How many continents are there in the world?',
      options: ['Five', 'Six', 'Seven', 'Eight'],
      correctAnswer: 'Seven',
    ),
    QuizQuestion(
      question: 'Which gas do plants absorb from the atmosphere?',
      options: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
      correctAnswer: 'Carbon Dioxide',
    ),
    QuizQuestion(
      question: 'What is the smallest prime number?',
      options: ['Zero', 'One', 'Two', 'Three'],
      correctAnswer: 'Two',
    ),
  ];

  int currentQuestionIndex = 0;
  Map<int, String> selectedAnswers = {};

  void nextQuestion(BuildContext context) { //function to shift to the next question
    if (currentQuestionIndex < quizQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        remainingTime = 1000; // Reset the timer for the next question
        remSecond = 10;
        startQuestionTimer();
      });
    } else {
      // Quiz is complete, navigate to QuizResult
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResult(
            selectedAnswers: selectedAnswers,
            quizQuestions: quizQuestions,
            name: widget.name,
          ),
        ),
      );
      questionTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = quizQuestions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            Row(
              children: [
                SizedBox(width: 120, child: Text(" Time Left :$remSecond Sec")),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: LinearProgressIndicator( //progress indicator for indicating time limits
                    value: progress,
                    minHeight: 10, // Adjust the height as needed
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            Card(
              elevation: 4,
              margin:
                  const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}: ${currentQuestion.question}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: currentQuestion.options.map((option) {
                        return RadioListTile<String>( //have radio buttons for the options
                          title: Text(option),
                          value: option,
                          groupValue: selectedAnswers[currentQuestionIndex],
                          onChanged: (value) {
                            setState(() {
                              selectedAnswers[currentQuestionIndex] = value!;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
        ElevatedButton(
          onPressed: selectedAnswers[currentQuestionIndex] != null? () => nextQuestion(context):null,//disable button if no options are selected

          child: Text(
            currentQuestionIndex < quizQuestions.length - 1
                ? 'Next Question'
                : 'Submit Quiz',
          ),
        ),
          ],
        ),
      ),
    );
  }
}

class Answer extends StatelessWidget {
  final String answerText;
  final Function selectHandler;

  const Answer(this.answerText, this.selectHandler, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () => selectHandler(),
        child: Text(answerText),
      ),
    );
  }
}

class QuizResult extends StatefulWidget {
  final Map<int, String> selectedAnswers;
  final List<QuizQuestion> quizQuestions;
  final String name;

  const QuizResult(
      {super.key, required this.selectedAnswers,
      required this.quizQuestions,
      required this.name});

  @override
  State<QuizResult> createState() => _QuizResultState();
}

class _QuizResultState extends State<QuizResult> {
  late String appreciate;

  @override
  Widget build(BuildContext context) {
    int correctAnswers = 0;

    for (int i = 0; i < widget.quizQuestions.length; i++) {
      if (widget.selectedAnswers.containsKey(i) &&
          widget.selectedAnswers[i] == widget.quizQuestions[i].correctAnswer) {
        correctAnswers++;
      }
    }
    if (correctAnswers > 3) { //to select particular appreciation word depending on the score
      appreciate = "Well done";
    } else if (correctAnswers > 1) {
      appreciate = "Well tried";
    }
    else {
      appreciate = "Must improve";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Text(
              '$appreciate ${widget.name} ',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20,),
            const Text(
              'Your Score:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20,),
            Text(
              '$correctAnswers out of ${widget.quizQuestions.length}',
              style: const TextStyle(
                fontSize: 36,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute( //navigate back to welcome page
                    builder: (_) => const NameEntryPage(),
                  ),
                  (route) => false, // Pop all existing routes
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class NameEntryPage extends StatefulWidget {
  const NameEntryPage({super.key});

  @override
  NameEntryPageState createState() => NameEntryPageState();
}

class NameEntryPageState extends State<NameEntryPage> {
  TextEditingController nameController = TextEditingController();
  String enteredName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WELCOME PARTICIPANT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/hello.jpg',
              width: 200.0,
              height: 170.0,
            ),
            const SizedBox(height: 20.0),
            TextField(
              onChanged:(text){
                setState(() {
                  enteredName=nameController.text;
                });
              },
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Enter Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: nameController.text!=''? ()=> {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => QuizPage(name: enteredName),
                  ),
                )
              }:null,
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
