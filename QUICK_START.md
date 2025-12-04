# Quick Reference - Firebase Auth for Focus & Flow

## 🚀 Start Here

```bash
cd "c:\Users\hyoyo\Downloads\Focus & Flow"
flutter run
```

## 📋 Test Credentials Flow

**New User Sign-Up:**
1. Tap "Don't have an account? Sign Up"
2. Enter email: `test@example.com`
3. Enter password: `Password123`
4. Confirm password
5. Tap "Sign Up"
6. Check email for verification link
7. Click link in email
8. Return to app → Tap "I Verified My Email"
9. ✅ Logged in!

**Existing User Login:**
1. Enter email: `test@example.com`
2. Enter password: `Password123`
3. Tap "Log In"
4. ✅ If email verified, you're logged in!

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| App won't start | Run `flutter clean` then `flutter pub get` |
| Firebase errors | Check `google-services.json` exists in `android/app/` |
| Email not received | Check spam folder or resend from Firebase Console |
| Login says "verify email" | Complete email verification from the link sent to your inbox |

## 📁 Key Files

- **Auth Logic**: `lib/auth_service.dart`
- **Login Page**: `lib/login_page.dart`
- **Sign-Up Page**: `lib/signup_page.dart`
- **App Entry**: `lib/main.dart`
- **Android Config**: `android/app/google-services.json`
- **iOS Config**: `ios/Runner/GoogleService-Info.plist`

## 🌐 Firebase Project

**Project ID**: `fir-flutter-codelab-5e0ce`

[Open Firebase Console](https://console.firebase.google.com/project/fir-flutter-codelab-5e0ce/authentication/providers)

## ✅ Verification Checklist

- [x] Firebase packages installed
- [x] Android configuration added
- [x] iOS configuration added
- [x] Login page updated
- [x] Sign-up page updated
- [x] Auth service configured
- [x] No build errors
- [x] No analysis warnings
- [x] Email verification active

## 💡 Tips

- Always check spam folder for verification emails
- Email verification is **required** - it's a security feature
- Session persists automatically after first login
- Password reset can be done via Firebase Console if needed

---

**Status**: ✅ Ready to Test and Deploy
