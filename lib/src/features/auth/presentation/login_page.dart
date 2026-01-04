import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/common/widgets/password_field.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/features/auth/presentation/signup_page.dart';
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
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final passwordFocusNode = useFocusNode();
    final authState = ref.watch(authStateProvider);
    final isPasswordVisible = useState(false);
    final analyticsService = ref.read(analyticsServiceProvider);

    // Function to validate form and track validation failures
    Future<bool> validateFormWithAnalytics() async {
      var isValid = true;

      // Check username
      if (usernameController.text.isEmpty) {
        await analyticsService.trackEmptyUsernameValidation();
        isValid = false;
      }

      // Check password
      if (passwordController.text.isEmpty) {
        await analyticsService.trackEmptyPasswordValidation();
        isValid = false;
      }

      return formKey.currentState!.validate() && isValid;
    }

    // The debug auto-login functionality has been moved to DebugModeUtils class

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
                                // Fill in username from environment variables
                                final credentials = DebugModeUtils.getDebugCredentials();
                                if (credentials.username.isNotEmpty) {
                                  usernameController.text = credentials.username;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Username filled from environment: ${credentials.username}',
                                      ),
                                      backgroundColor: Colors.blue,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                } else {
                                  context.showDebugSnackbar(
                                    'MEMVERSE_USERNAME environment variable not set',
                                  );
                                }
                              },
                              child: const Tooltip(
                                message: 'Long press to auto-fill username from env variables',
                                child: Icon(Icons.person),
                              ),
                            )
                          : const Icon(Icons.person),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your username' : null,
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
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your password' : null,
                    textInputAction: TextInputAction.go,
                    onFieldSubmitted: (_) async {
                      if (await validateFormWithAnalytics()) {
                        ref
                            .read(authStateProvider.notifier)
                            .login(usernameController.text, passwordController.text);
                      }
                    },
                    externalVisibilityState: isPasswordVisible,
                    onVisibilityToggle: analyticsService.trackPasswordVisibilityToggle,
                    // Add debug-only long press handler for the lock icon
                    onLeadingIconLongPress: kDebugMode
                        ? () {
                            // Fill in password from environment variables
                            final credentials = DebugModeUtils.getDebugCredentials();
                            if (credentials.password.isNotEmpty) {
                              passwordController.text = credentials.password;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password filled from environment: [REDACTED]'),
                                  backgroundColor: Colors.blue,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            } else {
                              context.showDebugSnackbar(
                                'MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT environment variable not set',
                              );
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
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Auto-login error: $e'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    child: Tooltip(
                      message: kDebugMode
                          ? 'Tap to sign in, long press to auto-fill from env variables'
                          : 'Tap to sign in',
                      child: OutlinedButton(
                        key: loginButtonKey,
                        onPressed: authState.isLoading
                            ? null
                            : () async {
                                if (await validateFormWithAnalytics()) {
                                  await ref
                                      .read(authStateProvider.notifier)
                                      .login(usernameController.text, passwordController.text);
                                }
                              },
                        child: authState.isLoading
                            ? const CircularProgressIndicator()
                            : kDebugMode
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Sign In', style: TextStyle(fontSize: 16)),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Tooltip(
                                      message:
                                          'Long press to auto-login with environment credentials',
                                      child: Icon(Icons.touch_app, size: 14, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              )
                            : const Text('Sign In', style: TextStyle(fontSize: 16)),
                      ),
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
