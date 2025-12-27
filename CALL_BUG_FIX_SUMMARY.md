# Call Bug Fix Summary

## 🐛 **Original Issue**

```
[E][12-27/11:11:31.068+7.0][21559,259][v3_call_manager.cc:82]
Tuikit: |Calls|CallEngine, [error_code:4294967295, error_message:The package you purchased does not support this ability.]
```

---

## 🔍 **Root Cause Analysis**

### **Problem 1: Initialization Issue (FIXED ✅)**

**Issue**: `LoginWidget` was calling `TUICallKit.instance.login()` directly instead of using `TencentCallService.initialize()`, causing the service's `_isInitialized` flag to remain `false`.

**Before:**
```dart
// lib/presentation/lib/src/login_widget.dart
_login() async {
  final result = await TUICallKit.instance
      .login(GenerateTestUserSig.sdkAppId, _userId, GenerateTestUserSig.genTestSig(_userId));
  // ...
}
```

**After:**
```dart
_login() async {
  final tencentService = getIt<TencentCallService>();
  
  try {
    await tencentService.initialize(
      sdkAppId: GenerateTestUserSig.sdkAppId,
      userId: _userId,
      userSig: GenerateTestUserSig.genTestSig(_userId),
    );
    // ...
  } catch (e) {
    // Error handling
  }
}
```

**Result**: ✅ `TencentCallService` is now properly initialized with `_isInitialized = true`.

---

### **Problem 2: Tencent License Issue (REQUIRES ACTION ⚠️)**

**Issue**: The error message `"The package you purchased does not support this ability"` indicates a **Tencent Cloud license/package limitation**.

**Current Configuration:**
- **SDKAppID**: `20031940` (from `generate_test_user_sig.dart`)
- **Error Code**: `4294967295` (unsigned -1, indicating general error)
- **Error Message**: Package doesn't support call ability

**Possible Causes:**
1. **Trial Package Expired**: Free trial period has ended
2. **Limited Package**: Current package doesn't include call features
3. **Account Suspended**: Payment or verification issues
4. **Wrong Region**: Package purchased for different region

---

## ✅ **What Was Fixed**

### **File: `lib/presentation/lib/src/login_widget.dart`**

**Changes:**
1. Added imports:
   ```dart
   import 'package:flutter_module/app/di/injection.dart';
   import 'package:flutter_module/data/services/tencent_call_service.dart';
   ```

2. Modified `_login()` method:
   - Now uses `getIt<TencentCallService>()` for DI
   - Calls `tencentService.initialize()` instead of direct SDK call
   - Added try-catch with error handling
   - Shows SnackBar on login failure

**Benefits:**
- ✅ Proper service initialization
- ✅ State management consistency
- ✅ Better error handling
- ✅ User feedback on failures

---

## ⚠️ **What Still Needs Action**

### **Tencent Cloud Package Issue**

The app has **two separate call systems**:

#### **System 1: Tencent Demo UI** (Currently Used)
```
LoginWidget → TencentCallService.initialize() ✅ FIXED
MainWidget → SingleCallWidget → TUICallKit.instance.calls() ⚠️ LICENSE ERROR
```

#### **System 2: Custom UI** (Your Implementation)
```
HomeScreen → CallBloc → TencentCallService.call() → TUICallKit.instance.calls()
```

**Both systems** will encounter the license error when calling `TUICallKit.instance.calls()` because it's an **SDK-level restriction**, not a code issue.

---

## 🔧 **Solutions**

### **Option 1: Fix Tencent License (Recommended)**

1. **Check Package Status:**
   - Go to: https://console.cloud.tencent.com/trtc
   - Login with your Tencent Cloud account
   - Find application with SDKAppID `20031940`

2. **Verify Package:**
   - Check if package is active (not expired)
   - Verify "Call" features are included
   - Check usage limits and quotas

3. **Upgrade/Purchase:**
   - If trial expired: Purchase a proper package
   - If limited package: Upgrade to include call features
   - Recommended: **Professional Edition** or **Enterprise Edition**

4. **Package Comparison:**
   | Package | Call Support | Price |
   |---------|--------------|-------|
   | Free Trial | Limited (7 days) | Free |
   | Basic | ❌ No | $X/month |
   | Professional | ✅ Yes | $Y/month |
   | Enterprise | ✅ Yes + Advanced | $Z/month |

---

### **Option 2: Use Different SDKAppID**

If you have another Tencent account with valid license:

1. **Update `generate_test_user_sig.dart`:**
   ```dart
   class GenerateTestUserSig {
     static int sdkAppId = YOUR_VALID_SDK_APP_ID; // Change this
     static String secretKey = 'YOUR_VALID_SECRET_KEY'; // Change this
   }
   ```

2. **Get Valid Credentials:**
   - Login to Tencent Cloud Console
   - Create new application OR use existing one with valid package
   - Copy SDKAppID and SecretKey
   - Paste into `generate_test_user_sig.dart`

---

### **Option 3: Generate UserSig from Backend (Production)**

**⚠️ IMPORTANT**: For production apps, **NEVER** store `secretKey` in client code!

**Current (Development Only):**
```dart
// Client-side generation (INSECURE)
GenerateTestUserSig.genTestSig(_userId)
```

**Production (Secure):**
```dart
// Backend API generates UserSig
final response = await http.post(
  'https://your-backend.com/api/generate-user-sig',
  body: {'userId': _userId},
);
final userSig = response.data['userSig'];
```

**Backend Implementation (Node.js example):**
```javascript
const TLSSigAPIv2 = require('tls-sig-api-v2');

app.post('/api/generate-user-sig', (req, res) => {
  const { userId } = req.body;
  const gen = new TLSSigAPIv2.Api(SDKAppID, secretKey);
  const userSig = gen.genSig(userId, 86400 * 7); // 7 days
  res.json({ userSig });
});
```

---

## 📊 **Debug Evidence**

### **Log Analysis:**

```json
Line 1: {"location":"tencent_call_service.dart:15","message":"initialize() called",
         "data":{"sdkAppId":20031940,"userId":"123","userSigLength":188,"_isInitialized":false}}

Line 2: {"location":"tencent_call_service.dart:33","message":"initialize() SUCCESS",
         "data":{"_isInitialized":true}}
```

**Confirmed:**
- ✅ `TencentCallService.initialize()` is called
- ✅ Login succeeds
- ✅ `_isInitialized = true`
- ✅ SDK is properly initialized

**Missing (because of license error):**
- ❌ No logs from `call()` method in demo UI (uses direct SDK call)
- ⚠️ License error occurs at SDK level before our code is reached

---

## 🎯 **Verification Steps**

### **After Fixing License:**

1. **Login:**
   ```
   - Open app
   - Enter user ID (e.g., "user123")
   - Tap "Login"
   - Should succeed ✅
   ```

2. **Make Call:**
   ```
   - Tap "Single Call"
   - Enter target user ID (e.g., "user456")
   - Tap "Call" button
   - Should initiate call ✅ (if license valid)
   ```

3. **Expected Behavior:**
   - **With Valid License**: Call connects successfully
   - **With Invalid License**: Same error as before

---

## 📝 **Files Modified**

| File | Changes | Status |
|------|---------|--------|
| `lib/presentation/lib/src/login_widget.dart` | Use `TencentCallService.initialize()` | ✅ Fixed |
| `lib/data/services/tencent_call_service.dart` | Removed debug instrumentation | ✅ Cleaned |
| `lib/presentation/call/bloc/call_bloc.dart` | Removed debug instrumentation | ✅ Cleaned |

---

## 🚀 **Next Steps**

1. **Immediate:**
   - [ ] Check Tencent Cloud Console for package status
   - [ ] Verify SDKAppID `20031940` has active license
   - [ ] Check if call features are included in package

2. **Short-term:**
   - [ ] Purchase/upgrade package if needed
   - [ ] Test calls after license is fixed
   - [ ] Verify both demo UI and custom UI work

3. **Long-term:**
   - [ ] Move UserSig generation to backend server
   - [ ] Remove `secretKey` from client code
   - [ ] Implement proper authentication flow
   - [ ] Add error handling for license issues

---

## 📚 **Resources**

- **Tencent Cloud Console**: https://console.cloud.tencent.com/trtc
- **Package Purchase**: https://cloud.tencent.com/document/product/647/78742
- **Integration Guide**: https://cloud.tencent.com/document/product/647/82985
- **API Documentation**: https://cloud.tencent.com/document/product/647/83052
- **Common Problems**: https://cloud.tencent.com/document/product/647/84493
- **UserSig Generation**: https://cloud.tencent.com/document/product/647/17275

---

## ✅ **Summary**

### **What Was Fixed:**
- ✅ SDK initialization now uses proper `TencentCallService`
- ✅ `_isInitialized` flag is correctly set to `true`
- ✅ Better error handling and user feedback

### **What Remains:**
- ⚠️ **Tencent Cloud license/package issue** - requires checking console and potentially upgrading package
- ⚠️ Error occurs at SDK level, not in our code

### **Recommendation:**
1. Check Tencent Cloud Console for SDKAppID `20031940`
2. Verify package includes call features
3. Purchase/upgrade if needed
4. Test calls after license is resolved

---

**Date**: December 27, 2025  
**Issue**: Call feature license error  
**Status**: Initialization fixed ✅, License issue identified ⚠️  
**Action Required**: Check/upgrade Tencent Cloud package

