import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/router/app_router.dart' as router;
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';

class TheMostedSplashScreen extends ConsumerStatefulWidget {
  const TheMostedSplashScreen({
    super.key,
    this.holdDuration = const Duration(seconds: 6),
    this.whiteoutDuration = const Duration(milliseconds: 1500),
  });

  final Duration holdDuration;

  final Duration whiteoutDuration;

  @override
  ConsumerState<TheMostedSplashScreen> createState() =>
      _TheMostedSplashScreenState();
}

class _TheMostedSplashScreenState extends ConsumerState<TheMostedSplashScreen>
    with TickerProviderStateMixin {
  static const int _cols = 6;
  static const int _rows = 12;
  static const int _totalTiles = _cols * _rows;

  static const Color _brandBg = AppColors.primary;
  static const Color _brandTileDark = AppColors.primaryDark;
  static const Color _brandTileLight = AppColors.primaryLight;
  static const Color _brandShadow = Color(0xFF0B1B47);
  static const Color _liftTint = Color(0xFF6B8AE6);

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _elevationAnims;
  final Random _rng = Random();

  late final AnimationController _progressController;

  late final AnimationController _whiteoutController;
  late final Animation<double> _whiteoutT;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  bool _whiteoutStarted = false;

  @override
  void initState() {
    super.initState();
    _setupTileAnimations();
    _setupWhiteoutAnimation();
    _setupProgressAnimation();
    _scheduleWhiteout();
  }

  void _setupProgressAnimation() {
    _progressController = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    )..forward();
  }

  void _setupTileAnimations() {
    _controllers = List.generate(_totalTiles, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + _rng.nextInt(1200)),
      );
    });

    _elevationAnims = _controllers.map((ctrl) {
      return CurvedAnimation(parent: ctrl, curve: Curves.easeInOut);
    }).toList();

    for (int i = 0; i < _totalTiles; i++) {
      final delay = _rng.nextInt(5000);
      Future.delayed(Duration(milliseconds: delay), () {
        if (!mounted) return;
        _loopTile(i);
      });
    }
  }

  void _loopTile(int i) async {
    if (!mounted || _whiteoutStarted) return;
    await _controllers[i].forward();
    if (!mounted || _whiteoutStarted) return;
    await Future.delayed(Duration(milliseconds: 150 + _rng.nextInt(900)));
    if (!mounted || _whiteoutStarted) return;
    await _controllers[i].reverse();
    if (!mounted || _whiteoutStarted) return;
    await Future.delayed(Duration(milliseconds: 400 + _rng.nextInt(3600)));

    if (!mounted || _whiteoutStarted) return;
    _controllers[i].duration = Duration(milliseconds: 500 + _rng.nextInt(1400));
    _loopTile(i);
  }

  void _setupWhiteoutAnimation() {
    _whiteoutController = AnimationController(
      vsync: this,
      duration: widget.whiteoutDuration,
    );
    _whiteoutT = CurvedAnimation(
      parent: _whiteoutController,
      curve: Curves.easeInOut,
    );
    _contentFade = CurvedAnimation(
      parent: _whiteoutController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _whiteoutController,
            curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
          ),
        );
  }

  void _scheduleWhiteout() {
    Future.delayed(widget.holdDuration, () {
      if (!mounted) return;
      setState(() => _whiteoutStarted = true);
      for (final c in _controllers) {
        if (c.value > 0) {
          c.animateTo(0, duration: const Duration(milliseconds: 400));
        }
      }
      if (_progressController.value < 1.0) {
        _progressController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
      _whiteoutController.forward();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _whiteoutController.dispose();
    _progressController.dispose();
    super.dispose();
  }


  Future<void> _pick(String type) async {
    await router.setSkillType(ref, type);
    if (!mounted) return;
    if (type == 'labour') {
      context.push(Routes.roleSelect);
    } else {
      context.push(Routes.login);
    }
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _whiteoutT,
      builder: (context, _) {
        final t = _whiteoutT.value;
        final bg = Color.lerp(_brandBg, Colors.white, t)!;
        final tileDark = Color.lerp(_brandTileDark, Colors.white, t)!;
        final tileLight = Color.lerp(_brandTileLight, Colors.white, t)!;
        final shadow = Color.lerp(_brandShadow, Colors.white, t)!;
        final liftTint = Color.lerp(_liftTint, Colors.white, t)!;
        final logoOpacity = (1 - t * 1.4).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              Positioned.fill(
                child: _MosaicGrid(
                  cols: _cols,
                  rows: _rows,
                  elevationAnims: _elevationAnims,
                  tileDark: tileDark,
                  tileLight: tileLight,
                  shadowColor: shadow,
                  bgColor: bg,
                  liftTint: liftTint,
                  rng: _rng,
                ),
              ),

              if (logoOpacity > 0.01)
                Positioned(
                  left: 28,
                  bottom: 48,
                  child: Opacity(
                    opacity: logoOpacity,
                    child: const _LogoWidget(),
                  ),
                ),

              if (logoOpacity > 0.01)
                Positioned(
                  left: 28,
                  right: 28,
                  bottom: 170,
                  child: Opacity(
                    opacity: logoOpacity,
                    child: _LoaderBar(progress: _progressController),
                  ),
                ),

              Positioned.fill(
                child: IgnorePointer(
                  ignoring: _contentFade.value < 0.95,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: _SkillTypeOverlay(onPick: _pick),
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
}


class _MosaicGrid extends StatelessWidget {
  final int cols;
  final int rows;
  final List<Animation<double>> elevationAnims;
  final Color tileDark;
  final Color tileLight;
  final Color shadowColor;
  final Color bgColor;
  final Color liftTint;
  final Random rng;

  const _MosaicGrid({
    required this.cols,
    required this.rows,
    required this.elevationAnims,
    required this.tileDark,
    required this.tileLight,
    required this.shadowColor,
    required this.bgColor,
    required this.liftTint,
    required this.rng,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileW = constraints.maxWidth / cols;
        final tileH = constraints.maxHeight / rows;

        const double fullRows = 1.5;
        const double fadeBand = 2.0;

        final tiles = <Widget>[];
        for (int i = 0; i < cols * rows; i++) {
          final col = i % cols;
          final row = i ~/ cols;

          final diagRow = rows * 0.2 + 0.8 * rows * (col + 0.5) / cols;
          final distanceRows = diagRow - (row + 0.5);

          if (distanceRows < -0.5) continue;

          final jitter = (rng.nextDouble() - 0.5) * 0.4;
          final raw = (distanceRows + 0.5 + jitter) / fadeBand;
          final fade = raw.clamp(0.0, 1.0);
          if (fade <= 0.0) continue;

          final fadeFactor = distanceRows >= fullRows ? 1.0 : fade;
          final isEdge = fadeFactor < 1.0;

          final isLight = (col + row) % 2 == 0;
          final baseColor = isLight ? tileLight : tileDark;

          tiles.add(
            Positioned(
              left: col * tileW,
              top: row * tileH,
              width: tileW,
              height: tileH,
              child: _AnimatedTile(
                anim: elevationAnims[i],
                baseColor: baseColor,
                shadowColor: shadowColor,
                bgColor: bgColor,
                liftTint: liftTint,
                fadeFactor: fadeFactor,
                isEdge: isEdge,
              ),
            ),
          );
        }

        return Stack(children: tiles);
      },
    );
  }
}


class _AnimatedTile extends StatelessWidget {
  final Animation<double> anim;
  final Color baseColor;
  final Color shadowColor;
  final Color bgColor;
  final Color liftTint;
  final double fadeFactor;
  final bool isEdge;

  const _AnimatedTile({
    required this.anim,
    required this.baseColor,
    required this.shadowColor,
    required this.bgColor,
    required this.liftTint,
    required this.fadeFactor,
    required this.isEdge,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final t = anim.value;

        final litColor = Color.lerp(baseColor, liftTint, t * 0.6)!;
        final color = Color.lerp(bgColor, litColor, fadeFactor)!;

        final baselineT = isEdge ? 0.55 : 0.0;
        final shadowT = t > baselineT ? t : baselineT;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            boxShadow: shadowT > 0.05
                ? [
                    BoxShadow(
                      color: shadowColor.withOpacity(shadowT * 0.55),
                      blurRadius: shadowT * 35.0,
                      spreadRadius: shadowT * 2.0,
                      offset: Offset(shadowT * -28.0, shadowT * -28.0),
                    ),
                    BoxShadow(
                      color: shadowColor.withOpacity(shadowT * 0.7),
                      blurRadius: shadowT * 18.0,
                      offset: Offset(shadowT * -16.0, shadowT * -16.0),
                    ),
                    BoxShadow(
                      color: shadowColor.withOpacity(shadowT * 0.8),
                      blurRadius: shadowT * 8.0,
                      offset: Offset(shadowT * -5.0, shadowT * -5.0),
                    ),
                  ]
                : const [],
          ),
        );
      },
    );
  }
}


class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'SKILL',
                  style: TextStyle(
                    fontFamily: 'Arial Black',
                    fontWeight: FontWeight.w900,
                    fontSize: 44,
                    letterSpacing: -1,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 10,
                  height: 10,
                  color: AppColors.accent,
                  margin: const EdgeInsets.only(bottom: 4),
                ),
              ],
            ),
            const Text(
              'LINK',
              style: TextStyle(
                fontFamily: 'Arial Black',
                fontWeight: FontWeight.w900,
                fontSize: 44,
                letterSpacing: -1,
                color: Colors.white,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class _LoaderBar extends StatelessWidget {
  const _LoaderBar({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LOADING',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                final pct = (progress.value * 100).clamp(0, 100).toInt();
                return Text(
                  '$pct%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: progress,
                  builder: (context, _) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.value.clamp(0.0, 1.0),
                        child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.9),
                              AppColors.accent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _SkillTypeOverlay extends StatelessWidget {
  const _SkillTypeOverlay({required this.onPick});

  final Future<void> Function(String type) onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'How would you like to use the app?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can switch between the two sides anytime from the menu.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            _SkillCard(
              icon: Icons.construction_rounded,
              accent: Colors.orange.shade700,
              title: 'Labour Skills',
              subtitle:
                  'Find or offer hands-on services — plumbing, electrical, '
                  'carpentry, cleaning, and more.',
              onTap: () => onPick('labour'),
            ),
            const SizedBox(height: 20),
            _SkillCard(
              icon: Icons.laptop_chromebook_rounded,
              accent: Colors.blue.shade700,
              title: 'Digital Skills',
              subtitle:
                  'Exchange digital skills — design, development, writing, '
                  'tutoring, marketing, and more.',
              onTap: () => onPick('digital'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
