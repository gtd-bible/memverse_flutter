import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/common/widgets/build_info.dart';
import 'package:mini_memverse/src/common/widgets/password_field.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/features/auth/presentation/signup_page.dart';
import 'package:mini_memverse/src/features/auth/utils/validation_utils.dart';
import 'package:mini_memverse/src/utils/debug_mode_utils.dart';

// Key constants for tests
const loginUsernameFieldKey = ValueKey('login_username_field');
const loginPasswordFieldKey = ValueKey('login_password_field');
const loginButtonKey = ValueKey('login_button');
const passwordVisibilityToggleKey = ValueKey('password_visibility_toggle');

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key = const ValueKey('login_page')});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final passwordFocusNode = useFocusNode();
    final authState = ref.watch(authStateProvider);
    final isPasswordVisible = useValueNotifier(false);
    final analyticsService = ref.read(analyticsServiceProvider);

    // Auto-fill credentials in debug mode from environment variables
    useEffect(() {
      if (kDebugMode) {
        // Only do this in debug mode for security
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final credentials = DebugModeUtils.getDebugCredentials();
          if (credentials.username.isNotEmpty && credentials.password.isNotEmpty) {
            // Auto-fill the form with debug credentials
            usernameController.text = credentials.username;
            passwordController.text = credentials.password;
            debugPrint('✅ DEBUG: Auto-filled login form with environment credentials');
          }
        });
      }
      return null;
    }, const []);

    Future<bool> validateFormWithAnalytics() async {
      var isValid = true;

      // Check username with trimming
      final username = usernameController.text.trim();
      if (username.isEmpty) {
        await analyticsService.trackEmptyUsernameValidation();
        isValid = false;
      } else if (!username.isValidUsername) {
        // Additional validation check using extension
        await analyticsService.trackInvalidUsernameValidation();
        isValid = false;
      }

      // Check password with trimming
      final password = passwordController.text.trim();
      if (password.isEmpty) {
        await analyticsService.trackEmptyPasswordValidation();
        isValid = false;
      } else if (!password.isValidPassword) {
        // Additional validation check using extension
        await analyticsService.trackInvalidPasswordValidation();
        isValid = false;
      }

      return formKey.currentState!.validate() && isValid;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Memverse Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Image.network(
                  'https://www.memverse.com/assets/quill-writing-on-scroll-f758c31d9bfc559f582fcbb707d04b01a3fa11285f1157044cc81bdf50137086.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      children: [
                        const Icon(Icons.menu_book, size: 80, color: Colors.green),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Colors.green, Colors.lightGreenAccent],
                            ),
                          ),
                          child: const Text(
                            'Memverse',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Consumer(builder: (context, ref, _) => BuildInfoText()),
                const SizedBox(height: 32),
                const Text(
                  'Welcome to Memverse',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Semantics(
                  identifier: 'textUsername',
                  label: 'Username field',
                  textField: true,
                  child: TextFormField(
                    key: loginUsernameFieldKey,
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: const OutlineInputBorder(),
                      prefixIcon: kDebugMode
                          ? GestureDetector(
                              onLongPress: () {
                                // Hidden easter egg: Fill in username from environment variables
                                final credentials = DebugModeUtils.getDebugCredentials();
                                if (credentials.username.isNotEmpty) {
                                  usernameController.text = credentials.username;
                                  // No visual feedback for truly hidden feature
                                }
                              },
                              child: const Icon(Icons.person),
                            )
                          : const Icon(Icons.person),
                    ),
                    validator: ValidationUtils.validateUsername,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(passwordFocusNode);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  identifier: 'textPassword',
                  label: 'Password field',
                  textField: true,
                  child: PasswordField(
                    fieldKey: loginPasswordFieldKey,
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    labelText: 'Password',
                    validator: ValidationUtils.validatePassword,
                    textInputAction: TextInputAction.go,
                    onFieldSubmitted: (_) async {
                      if (await validateFormWithAnalytics()) {
                        ref
                            .read(authStateProvider.notifier)
                            .login(usernameController.text.trim(), passwordController.text.trim());
                      }
                    },
                    externalVisibilityState: isPasswordVisible,
                    onVisibilityToggle: (bool isVisible) =>
                        analyticsService.trackPasswordVisibilityToggle(isVisible),
                    // Hidden easter egg long press handler for the lock icon
                    onLeadingIconLongPress: kDebugMode
                        ? () {
                            // Silently fill in password from environment variables
                            final credentials = DebugModeUtils.getDebugCredentials();
                            if (credentials.password.isNotEmpty) {
                              passwordController.text = credentials.password;
                              // No visual feedback for truly hidden feature
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 32),
                Semantics(
                  identifier: 'login_button',
                  button: true,
                  child: GestureDetector(
                    onLongPress: kDebugMode && !authState.isLoading
                        ? () async {
                            debugPrint(
                              '🔄 Long press detected - attempting auto-login with environment variables',
                            );
                            try {
                              final success = await DebugModeUtils.autoLoginWithDebugCredentials(
                                context: context,
                                ref: ref,
                                usernameController: usernameController,
                                passwordController: passwordController,
                              );
                              debugPrint(
                                'ℹ️ Auto-login attempt completed: ${success ? 'SUCCESS' : 'FAILED'}',
                              );
                            } catch (e) {
                              debugPrint('❌ Exception during auto-login: $e');
                              // No user-facing error messages for truly hidden feature
                            }
                          }
                        : null,
                    child: OutlinedButton(
                      key: loginButtonKey,
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              if (await validateFormWithAnalytics()) {
                                await ref
                                    .read(authStateProvider.notifier)
                                    .login(
                                      usernameController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                              }
                            },
                      child: authState.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Sign In', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (authState.error != null)
                  Text(
                    authState.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                // Sign Up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (context) => const SignupPage()));
                      },
                      child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
