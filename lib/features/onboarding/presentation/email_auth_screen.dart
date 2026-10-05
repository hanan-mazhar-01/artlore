import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/editorial_text.dart';
import '../../../core/widgets/round_buttons.dart';
import '../../paywall/presentation/premium_controller.dart';
import '../../settings/presentation/settings_controller.dart';

/// Email + password sign-in / registration, backed by Firebase Auth.
class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isRegistering = false;
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_busy && _email.text.trim().contains('@') && _password.text.length >= 6;

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final wasGuest = ref.read(authServiceProvider).currentUser?.isAnonymous ?? false;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      if (_isRegistering) {
        await auth.registerWithEmail(email, password);
        if (wasGuest) {
          await ref.read(purchaseRepositoryProvider).grantAccountBonusIfEligible();
        }
      } else {
        await auth.signInWithEmail(email, password);
      }
      await ref.read(premiumProvider.notifier).refresh();
      if (!mounted) return;
      if (ref.read(settingsProvider).onboardingComplete) {
        // Reached mid-app (e.g. the guest scan-limit wall) — resume there.
        context.pop(true);
      } else {
        ref.read(settingsProvider.notifier).completeOnboarding();
        context.go(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _messageFor(e.code));
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _messageFor(String code) => switch (code) {
    'user-not-found' || 'invalid-credential' || 'wrong-password' =>
      'Incorrect email or password.',
    'email-already-in-use' => 'An account already exists for that email.',
    'invalid-email' => 'That email address looks invalid.',
    'weak-password' => 'Choose a password with at least 6 characters.',
    'network-request-failed' => 'No connection — check your network.',
    'too-many-requests' => 'Too many attempts. Try again shortly.',
    _ => 'Something went wrong. Please try again.',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ArtScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlineIconButton(onTap: () => context.backOr(AppRoutes.welcome)),
              const SizedBox(height: 28),
              EditorialHeading(
                lead: _isRegistering ? 'Create your' : 'Welcome',
                emphasis: _isRegistering ? 'account.' : 'back.',
                style: AppTypography.title,
              ),
              const SizedBox(height: 8),
              Text(
                _isRegistering
                    ? 'A free account keeps your collection with you.'
                    : 'Sign in with the email you registered with.',
                style: AppTypography.bodySmall.copyWith(color: p.muted),
              ),
              const SizedBox(height: 28),
              _Field(
                controller: _email,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              _Field(
                controller: _password,
                hint: 'Password',
                obscureText: _obscure,
                autofillHints: [
                  _isRegistering ? AutofillHints.newPassword : AutofillHints.password,
                ],
                onChanged: (_) => setState(() {}),
                trailing: TextAction(
                  label: _obscure ? 'Show' : 'Hide',
                  fontSize: 12,
                  onTap: () => setState(() => _obscure = !_obscure),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: AppTypography.caption.copyWith(color: p.danger),
                ),
              ],
              const SizedBox(height: 22),
              PillButton(
                label: _isRegistering ? 'Create account' : 'Sign in',
                onTap: _canSubmit ? _submit : null,
                style: PillStyle.inverse,
              ),
              const SizedBox(height: 14),
              Center(
                child: TextAction(
                  label: _isRegistering
                      ? 'Already have an account? Sign in'
                      : 'New here? Create an account',
                  onTap: _busy
                      ? null
                      : () => setState(() {
                          _isRegistering = !_isRegistering;
                          _error = null;
                        }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.trailing,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line(.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              autofillHints: autofillHints,
              onChanged: onChanged,
              style: AppTypography.sans(15).copyWith(color: p.ink),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: hint,
                hintStyle: AppTypography.sans(15).copyWith(color: p.muted),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
