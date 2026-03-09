import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/progress_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';

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
    await prefs.setString(
      SPKeys.firstLaunchDate,
      DateTime.now().toIso8601String(),
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.rocket_launch,
                size: 64,
                color: AppColors.accent,
              ),
              const SizedBox(height: 24),
              const Text(
                '스타트업 한 입',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '매일 하나씩, 스타트업 용어 마스터',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              GlassContainer(
                child: Column(
                  children: [
                    const Text(
                      '닉네임을 입력해주세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: '닉네임 (2~10자)',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      maxLength: 10,
                      onChanged: (value) {
                        setState(() {
                          _isValid = value.trim().length >= 2;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
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
    );
  }
}
