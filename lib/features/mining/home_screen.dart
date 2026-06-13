import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatDuration(Duration d) {
    return '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miningState = ref.watch(miningProvider);
    final balance = ref.watch(balanceProvider);
    final profile = ref.watch(profileProvider);
    final isMining = miningState.isMining;

    return Scaffold(
      appBar: AppBar(title: const Text('EcoMine')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${balance.total.toStringAsFixed(6)} GAMMA',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Streak: ${profile?.streak ?? 0} Days',
              style: TextStyle(fontSize: 18, color: Colors.green.shade700, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: isMining ? null : () => ref.read(miningProvider.notifier).startMining(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMining ? Colors.green.shade700 : const Color(0xFF4CAF50),
                  boxShadow: isMining ? [
                    BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)
                  ] : [
                    BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.5), blurRadius: 30, spreadRadius: 10)
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMining ? Icons.settings_input_antenna : Icons.touch_app,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isMining ? _formatDuration(miningState.cooldown) : 'MINE NOW',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (isMining) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'MINING...',
                          style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            if (profile?.hasPlantedTreeToday == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.park, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Eco Boost Active! (2x Rewards)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
