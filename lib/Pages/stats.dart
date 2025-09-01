import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Statsist extends StatefulWidget {
  const Statsist({super.key});

  @override
  State<Statsist> createState() => _StatsistState();
}

class _StatsistState extends State<Statsist> {
  final Box<int> weightBox = Hive.box<int>('weightBox');
  final Box usersBox = Hive.box('users');
  final Box currentUserBox = Hive.box('currentUser');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Beautiful Gradient Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Your Statistics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Track your weight loss journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats Cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      // Current Weight Card
                      _buildStatCard(
                        'Current Weight',
                        '${weightBox.get('weight', defaultValue: 75) ?? 75} kg',
                        Icons.monitor_weight,
                        const Color(0xFF667EEA),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Goal Progress Card
                      _buildGoalProgressCard(),
                      
                      const SizedBox(height: 16),
                      
                      // BMI Status Card
                      _buildBMICard(),
                      
                      const SizedBox(height: 16),
                      
                      // Weekly Summary Card
                      _buildWeeklySummaryCard(),
                      
                      const SizedBox(height: 16),
                      
                      // Achievement Card
                      _buildAchievementCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard() {
    return ValueListenableBuilder(
      valueListenable: weightBox.listenable(),
      builder: (context, Box<int> box, _) {
        int currentWeight = box.get('weight', defaultValue: 75) ?? 75;
        int? goal = _getUserGoal();
        
        if (goal == null) {
          return _buildStatCard(
            'Goal Progress',
            'Set a goal first',
            Icons.flag,
            const Color(0xFF764BA2),
          );
        }
        
        // Calculate progress
        String? username = currentUserBox.get('username');
        double progress = 0.0;
        String status = '';
        
        if (username != null) {
          var userData = usersBox.get(username);
          if (userData is Map && userData.containsKey('weight')) {
            int startWeight = userData['weight'] as int;
            
            if (startWeight > goal) {
              // Weight loss goal
              int totalToLose = startWeight - goal;
              int currentLost = startWeight - currentWeight;
              progress = currentLost / totalToLose;
              status = '${(progress * 100).toInt()}% to goal';
            } else {
              // Weight gain goal
              int totalToGain = goal - startWeight;
              int currentGained = currentWeight - startWeight;
              progress = currentGained / totalToGain;
              status = '${(progress * 100).toInt()}% to goal';
            }
            
            progress = progress.clamp(0.0, 1.0);
          }
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Icon(Icons.flag, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Goal Progress',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Bar
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBMICard() {
    return ValueListenableBuilder(
      valueListenable: weightBox.listenable(),
      builder: (context, Box<int> box, _) {
        int weight = box.get('weight', defaultValue: 75) ?? 75;
        double height = _getUserHeight();
        double bmi = _calculateBMI(weight, height);
        String category = _getBMICategory(bmi);
        Color bmiColor = _getBMIColor(category);
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: bmiColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [bmiColor, bmiColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BMI Status',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bmi.toStringAsFixed(1)} - $category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: bmiColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklySummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF764BA2).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF764BA2), Color(0xFF667EEA)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(Icons.calendar_today, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'Weekly Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'Days Tracked',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '7',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF764BA2),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Avg Weight',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '75 kg',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF764BA2),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Trend',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Icon(
                    Icons.trending_down,
                    color: Colors.green,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildAchievement('🎯', 'Goal Set', 'You set a weight goal'),
              const SizedBox(width: 16),
              _buildAchievement('📊', 'Tracking', '7 days of tracking'),
              const SizedBox(width: 16),
              _buildAchievement('💪', 'Consistent', 'Weekly check-ins'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement(String emoji, String title, String description) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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

  double _getUserHeight() {
    String? username = currentUserBox.get('username');
    if (username != null) {
      var userData = usersBox.get(username);
      if (userData is Map && userData.containsKey('height')) {
        return userData['height'] as double;
      }
    }
    return 1.70;
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
}