import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(BuildContext ctx) onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      eyebrow: '① / ③ · CAPTURE',
      title: 'Une simple\nradiographie.',
      titleAccent: 'radiographie.',
      body:
          "Prenez ou importez une radiographie thoracique. Vos données restent locales et chiffrées.",
      active: [1, 4, 7, 11],
    ),
    _Slide(
      eyebrow: '② / ③ · DIAGNOSTIC',
      title: 'Deux modèles IA\nen parallèle.',
      titleAccent: 'en parallèle.',
      body:
          "EfficientNetB1 classe 14 pathologies — directement sur l'appareil, sans cloud.",
      active: [0, 1, 2, 4, 6, 7, 8, 11],
    ),
    _Slide(
      eyebrow: '③ / ③ · RAPPORT',
      title: 'Résultats clairs\nen quelques secondes.',
      titleAccent: 'en quelques secondes.',
      body:
          "Scores de confiance, masques colorés, rapport exportable. Prêt à valider en consultation.",
      active: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
    ),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) widget.onDone(context);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V4.bg,
      body: Stack(
        children: [
          // Background glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 0.8,
                  colors: [Color(0x2234E5C5), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top row: logo + skip
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      const ApertureMark(size: 22, active: [1, 4, 7, 11]),
                      const SizedBox(width: 8),
                      const Text(
                        'PulmoScan AI',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: V4.ink,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _finish,
                        child: const Text(
                          'Passer',
                          style: TextStyle(
                            fontSize: 12,
                            color: V4.inkMuted,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _slides.length,
                    itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
                  ),
                ),

                // Dots + button
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          final active = i == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active ? V4.teal : V4.surface3,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: V4.teal,
                            foregroundColor: V4.bg,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _page < _slides.length - 1
                                    ? 'Continuer'
                                    : 'Commencer',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: V4.bg,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '→',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: V4.bg,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final String eyebrow;
  final String title;
  final String titleAccent;
  final String body;
  final List<int> active;

  const _Slide({
    required this.eyebrow,
    required this.title,
    required this.titleAccent,
    required this.body,
    required this.active,
  });
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    final baseTitle = slide.title.replaceAll('\n${slide.titleAccent}', '');
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Mark
          Container(
            width: 180,
            height: 180,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0x2034E5C5), Colors.transparent],
              ),
            ),
            child: AnimatedApertureMark(
              size: 160,
              targetActive: slide.active,
              duration: const Duration(milliseconds: 1200),
            ),
          ),
          const SizedBox(height: 20),
          // Eyebrow
          Text(
            slide.eyebrow,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.8,
              color: V4.teal,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // Title
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: V4.ink,
                height: 1.1,
              ),
              children: [
                TextSpan(text: '$baseTitle\n'),
                TextSpan(
                  text: slide.titleAccent,
                  style: const TextStyle(
                    color: V4.teal,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Body
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: V4.inkSoft,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
