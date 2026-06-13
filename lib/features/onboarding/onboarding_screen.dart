import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _current = i),
                children: const [
                  _Slide(icon: Icons.touch_app, title: 'Tap to Earn', desc: 'Mine EcoTokens daily with zero energy drain.'),
                  _Slide(icon: Icons.park, title: 'Eco Boost', desc: 'Complete green tasks for 2x mining boosts.'),
                  _Slide(icon: Icons.account_balance_wallet, title: 'Secure Wallet', desc: 'Simulate sending and receiving tokens.'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (i) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _current == i ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _current == i ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_current == 2) {
                        ref.read(profileProvider.notifier).createWallet();
                        context.go('/');
                      } else {
                        _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(_current == 2 ? 'Create Wallet' : 'Next'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _Slide({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: const Color(0xFF4CAF50)),
          const SizedBox(height: 48),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
        ],
      ),
    );
  }
}
