import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _exitCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _logoRotate;
  late Animation<double> _nameFade;
  late Animation<Offset> _nameSlide;
  late Animation<double> _subFade;
  late Animation<double> _dotsFade;
  late Animation<double> _featFade;
  late Animation<double> _ctaFade;
  late Animation<double> _pulse;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _logoCtrl, curve: const Interval(0.0, 0.4)));
    _logoRotate = Tween<double>(begin: -3.14, end: 0.0).animate(
        CurvedAnimation(
            parent: _logoCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _pulse = Tween<double>(begin: 1.0, end: 1.13).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _logoCtrl,
            curve: const Interval(0.5, 0.9, curve: Curves.easeOut)));
    _nameSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _logoCtrl,
                curve: const Interval(0.5, 0.9, curve: Curves.easeOut)));
    _subFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut)));
    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut)));
    _featFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut)));
    _ctaFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut)));
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _logoCtrl.forward();
    // Animation poori hone ke baad "Get Started" button visible ho jaata hai.
    // Auto-navigate karna ho toh neeche wali lines uncomment karo:
    // await Future.delayed(const Duration(milliseconds: 1500));
    // await _exitCtrl.forward();
    // if (mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _goHome() async {
    await _exitCtrl.forward();
    if (mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _exitCtrl,
      builder: (context, child) => Opacity(
        opacity: _exitFade.value,
        child: child,
      ),
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // ── Upper half: logo + name + dots ──
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_logoCtrl, _pulseCtrl]),
                    builder: (context, _) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with pulse ring
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: _pulse.value,
                              child: Opacity(
                                opacity: (0.5 -
                                        (_pulse.value - 1.0) * 3.3)
                                    .clamp(0.0, 0.5),
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.primary, width: 2),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                            FadeTransition(
                              opacity: _logoFade,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Transform.rotate(
                                  angle: _logoRotate.value,
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(22)),
                                    child: const Center(
                                        child: Icon(
                                            Icons.language_rounded,
                                            color: Colors.white,
                                            size: 34)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // App name
                        FadeTransition(
                          opacity: _nameFade,
                          child: SlideTransition(
                            position: _nameSlide,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: 'Lingua',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight,
                                          letterSpacing: -1)),
                                  TextSpan(
                                      text: 'AI',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                          letterSpacing: -1)),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        FadeTransition(
                          opacity: _subFade,
                          child: Text(
                            'Translate · Learn · Converse',
                            style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                        ),

                        const SizedBox(height: 14),

                        FadeTransition(
                          opacity: _dotsFade,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Dot(color: AppColors.primary),
                              const SizedBox(width: 6),
                              _Dot(
                                  color: isDark
                                      ? const Color(0xFF1D6B5A)
                                      : AppColors.accent),
                              const SizedBox(width: 6),
                              _Dot(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Lower half: features + button ──
              AnimatedBuilder(
                animation: _logoCtrl,
                builder: (context, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _featFade,
                      child: Column(
                        children: [
                          _FeatItem(
                              icon: Icons.translate_rounded,
                              title: 'Translate',
                              subtitle: '100+ languages instantly',
                              isDark: isDark),
                          _FeatItem(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'AI Conversation',
                              subtitle: 'Practice with AI tutor',
                              isDark: isDark),
                          _FeatItem(
                              icon: Icons.bolt_rounded,
                              title: 'AI Enhance',
                              subtitle: 'Smarter via Groq AI',
                              isDark: isDark),
                        ],
                      ),
                    ),
                    FadeTransition(
                      opacity: _ctaFade,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _goHome, // ← yahan fix hai
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Get Started →',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _FeatItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  const _FeatItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF122E27)
                  : const Color(0xFFE1F5EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondaryLight)),
            ],
          ),
        ],
      ),
    );
  }
}