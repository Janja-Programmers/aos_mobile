import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';

class StoryTemplateConfirmScreen extends StatelessWidget {
  const StoryTemplateConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(28, 16, 28, 26),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colors.primary.withValues(alpha: 0.16),
                        child: Icon(
                          Icons.person_rounded,
                          color: colors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'You',
                              style: context.h5.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Create story', style: context.pMuted),
                          ],
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.surfaceBright.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: colors.textMuted,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFD21E), Color(0xFFFFC01B)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'JUNE 30',
                                style: context.overline.copyWith(
                                  color: const Color(0xFF9B6C1E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'I’m acing Spanish\nlessons with',
                                style: context.h4.copyWith(
                                  color: const Color(0xFF8D5F5F),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 26),
                              Text(
                                '100%',
                                style: context.h1.copyWith(
                                  color: Colors.white,
                                  fontSize: 82,
                                  fontWeight: FontWeight.w900,
                                  height: 0.95,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'accuracy!',
                                style: context.h4.copyWith(
                                  color: const Color(0xFF8D5F5F),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Spacer(),
                              const Wrap(
                                spacing: 10,
                                runSpacing: 12,
                                children: [
                                  _WordChip('carro'),
                                  _WordChip('bicicleta'),
                                  _WordChip('tú'),
                                  _WordChip('gato'),
                                  _WordChip('casa'),
                                  _WordChip('de'),
                                  _WordChip('español'),
                                  _WordChip('familia'),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 38,
              bottom: 38,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ShowSnack(
                    context,
                    'Story publishing will be available when backend support is ready.',
                  ).info();
                },
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.42),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: context.p.copyWith(
          color: const Color(0xFF8D5F5F),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
