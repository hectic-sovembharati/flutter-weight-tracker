import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box<int> weightBox = Hive.box<int>('weightBox');
  final Box usersBox = Hive.box('users');
  final Box currentUserBox = Hive.box('currentUser');

  void showIntegerInput(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Your Weight"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(hintText: "Enter your weight here"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  int weight = int.parse(controller.text);
                  weightBox.put('weight', weight); // Save to Hive
                  Navigator.of(context).pop(); // Close dialog
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  int? _getUserGoal() {
    String? username = currentUserBox.get('username');
    if (username != null) {
      var userData = usersBox.get(username);
      if (userData is Map && userData.containsKey('goal')) {
        return userData['goal'] as int;
      }
    }
    return null;
  }

  String _getProgressMessage(int currentWeight, int? goalWeight) {
    // If no goal is set
    if (goalWeight == null) {
      return "Set a goal to track your progress!";
    }

    // Calculate difference
    int difference = currentWeight - goalWeight;

    // Determine message based on difference
    if (difference > 0) {
      return "You are $difference kg above your goal";
    } else if (difference < 0) {
      return "You are ${difference.abs()} kg below your goal";
    } else {
      return "🎉 Congratulations! You reached your goal!";
    }
  }

  double _getUserHeight() {
    String? username = currentUserBox.get('username');
    if (username != null) {
      var userData = usersBox.get(username);
      if (userData is Map && userData.containsKey('height')) {
        return userData['height'] as double;
      }
    }
    return 1.70; // Default height in meters
  }

  double _calculateBMI(int weight, double height) {
    return weight / (height * height);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return 'Normal Weight';
    } else if (bmi >= 25 && bmi < 29.9) {
      return 'Overweight';
    } else {
      return 'Obesity';
    }
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case 'Underweight':
        return Colors.orange;
      case 'Normal Weight':
        return Colors.green;
      case 'Overweight':
        return Colors.yellow;
      case 'Obesity':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Quote Service
  Future<Map<String, String>> getQuoteFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random?tags=fitness,health'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'quote': data['content'],
          'author': data['author'] ?? 'Unknown',
        };
      }
    } catch (e) {
      print('Error fetching quote: $e');
    }
    
    // Fallback quotes if API fails
    return getRandomFallbackQuote();
  }

  Map<String, String> getRandomFallbackQuote() {
    final List<Map<String, String>> fallbackQuotes = [
      {
        'quote': 'The only bad workout is the one that didn\'t happen.',
        'author': 'Fitness Motivation'
      },
      {
        'quote': 'Your body can stand almost anything. It\'s your mind you have to convince.',
        'author': 'Marvin Phillips'
      },
      {
        'quote': 'The difference between try and triumph is just a little umph!',
        'author': 'Marvin Phillips'
      },
      {
        'quote': 'Make yourself proud.',
        'author': 'Fitness Motivation'
      },
      {
        'quote': 'Every day is a chance to become better.',
        'author': 'Fitness Motivation'
      },
      {
        'quote': 'Small progress is still progress.',
        'author': 'Fitness Motivation'
      },
      {
        'quote': 'You are stronger than you think.',
        'author': 'Fitness Motivation'
      },
      {
        'quote': 'Consistency beats perfection.',
        'author': 'Fitness Motivation'
      },
    ];
    
    // Return a random quote from the fallback list
    fallbackQuotes.shuffle();
    return fallbackQuotes.first;
  }

  Widget _buildQuoteContent(String quote, String author) {
    return Column(
      children: [
        // Quote Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.format_quote,
            color: Colors.white,
            size: 28,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Quote Text
        Text(
          '"$quote"',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Author
        Text(
          '- $author',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showIntegerInput(context);
        },
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 70),
            // Weight Container
            ValueListenableBuilder(
              valueListenable: weightBox.listenable(),
              builder: (context, Box<int> box, _) {
                int weight = box.get('weight', defaultValue: 75) ?? 75;
                int? goal = _getUserGoal();
                String message = _getProgressMessage(weight, goal);

                return Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'YOUR CURRENT WEIGHT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$weight kg',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Progress Bar
            ValueListenableBuilder(
              valueListenable: weightBox.listenable(),
              builder: (context, Box<int> box, _) {
                int weight = box.get('weight', defaultValue: 75) ?? 75;
                int? goal = _getUserGoal();
                
                // Calculate progress percentage
                double progress = 0.0;
                bool isOverGoal = false;
                
                if (goal != null && goal > 0) {
                  // Get the user's starting weight from registration
                  String? username = currentUserBox.get('username');
                  if (username != null) {
                    var userData = usersBox.get(username);
                    if (userData is Map && userData.containsKey('weight')) {
                      int startWeight = userData['weight'] as int;
                      
                      // Check if current weight is over goal
                      if (startWeight > goal) {
                        // Goal is to lose weight
                        isOverGoal = weight > goal;
                        int totalToLose = startWeight - goal;
                        int currentLost = startWeight - weight;
                        progress = currentLost / totalToLose;
                      } else if (startWeight < goal) {
                        // Goal is to gain weight
                        isOverGoal = weight < goal;
                        int totalToGain = goal - startWeight;
                        int currentGained = weight - startWeight;
                        progress = currentGained / totalToGain;
                      }
                      
                      progress = progress.clamp(0.0, 1.0); // Keep between 0 and 1
                    }
                  }
                }
                
                return Column(
                  children: [
                    // Progress Bar
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isOverGoal 
                              ? const LinearGradient(
                                  colors: [Colors.red, Colors.redAccent],
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Progress Text
                    Text(
                      goal != null ? '${(progress * 100).toInt()}% Complete' : 'Set a goal to see progress',
                      style: TextStyle(
                        fontSize: 14,
                        color: goal != null 
                          ? (isOverGoal ? Colors.red[600] : const Color(0xFF667EEA))
                          : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Progress Message
            ValueListenableBuilder(
              valueListenable: weightBox.listenable(),
              builder: (context, Box<int> box, _) {
                int weight = box.get('weight', defaultValue: 75) ?? 75;
                int? goal = _getUserGoal();
                String message = _getProgressMessage(weight, goal);
                
                return Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
            // BMI Information Container
            ValueListenableBuilder(
              valueListenable: weightBox.listenable(),
              builder: (context, Box<int> box, _) {
                int weight = box.get('weight', defaultValue: 75) ?? 75;
                double height = _getUserHeight();
                double bmi = _calculateBMI(weight, height);
                String category = _getBMICategory(bmi);
                
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Left side - Title
                        const Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Your BMI Information',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Right side - Height, Weight, BMI
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Height: ${height.toStringAsFixed(2)} m',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Weight: $weight kg',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'BMI: ${bmi.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _getBMIColor(category),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Motivational Quote Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FutureBuilder<Map<String, String>>(
                future: getQuoteFromAPI(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Column(
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading motivation...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  }
                  
                  if (snapshot.hasError || !snapshot.hasData) {
                    // Show fallback quote if API fails
                    final fallbackQuote = getRandomFallbackQuote();
                    return _buildQuoteContent(fallbackQuote['quote']!, fallbackQuote['author']!);
                  }
                  
                  final quoteData = snapshot.data!;
                  return _buildQuoteContent(quoteData['quote']!, quoteData['author']!);
                },
              ),
            ),
          ],
          
        ),
        
      ),
      
    );
  }
}
