import 'package:flutter/material.dart';

import '../controllers/pet_controller.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          goal.completed ? Icons.check_circle : Icons.flag,
          color: goal.completed ? Colors.green : Colors.orange,
        ),
        title: Text(goal.title),
        subtitle: Text('${goal.progress}/${goal.target} concluído'),
        trailing: goal.completed
            ? Text('🪙 ${goal.reward}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
            : null,
      ),
    );
  }
}
