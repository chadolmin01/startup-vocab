import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/progress_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/star_field.dart';

class NicknameScreen extends ConsumerStatefulWidget {
  const NicknameScreen({super.key});

  @override
  ConsumerState<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends ConsumerState<NicknameScreen> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nickname = _controller.text.trim();
    if (nickname.isEmpty) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final deviceId = const Uuid().v4();

    await prefs.setString(SPKeys.nickname, nickname);
    await prefs.setString(SPKeys.deviceId, deviceId);
    // firstLaunchDate is already set in main.dart — don't overwrite

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarField(
        starCount: 70,
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  color: AppColors.accent.withValues(alpha: 0.08),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  size: 32,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: Spacing.xl),
              const Text('스타트업 한 입', style: AppTextStyles.h1),
              const SizedBox(height: Spacing.sm),
              Text(
                'STARTUP BITE // ODYSSEY VENTURES',
                style: AppTextStyles.labelBright,
              ),
              const SizedBox(height: Spacing.xxl),
              FrameContainer(
                label: 'INITIALIZE',
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('닉네임을 입력해주세요', style: AppTextStyles.h3),
                    ),
                    const SizedBox(height: Spacing.lg),
                    TextField(
                      controller: _controller,
                      style: AppTextStyles.body,
                      decoration: const InputDecoration(
                        hintText: '닉네임 (2~10자)',
                      ),
                      maxLength: 10,
                      onChanged: (value) {
                        setState(() {
                          _isValid = value.trim().length >= 2;
                        });
                      },
                    ),
                    const SizedBox(height: Spacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isValid ? _submit : null,
                        child: const Text('시작하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
