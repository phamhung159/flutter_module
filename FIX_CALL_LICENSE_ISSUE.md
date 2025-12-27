# 🚨 URGENT: Fix Call License Issue

## ❌ Current Problem

**Error:**
```
[error_code:4294967295, error_message:The package you purchased does not support this ability.]
```

**Cause:** SDKAppID `20031940` has an **expired or limited Tencent Cloud package** that doesn't support call features.

---

## ✅ SOLUTION: Update Credentials

### **Step 1: Get Valid Tencent Cloud Credentials**

You have **3 options**:

#### **Option A: Create New Demo App (Recommended - Free)**

1. Go to: https://console.cloud.tencent.com/trtc/quickstart
2. Click **"Create Application"** (创建应用)
3. Enter application name (e.g., "MyCallApp")
4. Click **"Create"**
5. You'll see:
   ```
   SDKAppID: 1400XXXXXX
   SecretKey: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```
6. Copy both values

#### **Option B: Purchase Package for Existing App**

1. Go to: https://console.cloud.tencent.com/trtc
2. Find application with SDKAppID `20031940`
3. Click **"Package Purchase"** (套餐购买)
4. Select package with **Call features**:
   - Professional Edition (专业版) - ~$50-100/month
   - Enterprise Edition (企业版) - Custom pricing
5. Complete purchase
6. Use existing credentials (no code change needed)

#### **Option C: Use Different Account**

If you have another Tencent account with valid package:
1. Login to that account's console
2. Get SDKAppID and SecretKey
3. Use those credentials

---

### **Step 2: Update Code**

**File:** `lib/presentation/lib/debug/generate_test_user_sig.dart`

**Replace lines 30 and 50:**

```dart
class GenerateTestUserSig {
  // OLD (EXPIRED):
  static int sdkAppId = 20031940;
  static String secretKey = '113a6f535e978b705fe8bf3f02926f923a9daef400ee1b1bf5c6abcb12efef90';
  
  // NEW (YOUR VALID CREDENTIALS):
  static int sdkAppId = YOUR_SDKAPPID_HERE;  // ⬅️ REPLACE THIS
  static String secretKey = 'YOUR_SECRET_KEY_HERE';  // ⬅️ REPLACE THIS
}
```

**Example with valid credentials:**
```dart
class GenerateTestUserSig {
  static int sdkAppId = 1400123456;  // Your new SDKAppID
  static String secretKey = 'abc123def456...';  // Your new SecretKey
}
```

---

### **Step 3: Test**

1. **Hot restart** the app (or rebuild)
2. Login with any user ID (e.g., "user123")
3. Try to make a call
4. **Should work now!** ✅

---

## 🔍 How to Verify Credentials Are Valid

### **Before Testing:**

Check in Tencent Console:
1. Go to: https://console.cloud.tencent.com/trtc
2. Find your application
3. Check **"Package Status"**:
   - ✅ **Active** = Good
   - ❌ **Expired** = Need to purchase
   - ❌ **No Package** = Need to purchase

### **Package Features:**

| Package | Call Support | Status |
|---------|--------------|--------|
| Free Trial | ✅ Limited (7 days) | May be expired |
| Basic | ❌ No calls | Won't work |
| Professional | ✅ Yes | Will work |
| Enterprise | ✅ Yes + Advanced | Will work |

---

## 📝 Quick Copy-Paste Template

**After getting your credentials from Tencent Console:**

```dart
// File: lib/presentation/lib/debug/generate_test_user_sig.dart
// Lines 30 and 50

static int sdkAppId = 1400XXXXXX;  // ⬅️ Paste your SDKAppID here
static String secretKey = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';  // ⬅️ Paste your SecretKey here
```

---

## ⚠️ IMPORTANT NOTES

### **Security Warning:**

**Current setup is for TESTING ONLY!**

❌ **DO NOT** use this in production apps!  
❌ **DO NOT** commit SecretKey to public repositories!

**For production:**
- Move UserSig generation to **backend server**
- Client requests UserSig from your API
- Server generates UserSig securely
- Reference: https://cloud.tencent.com/document/product/647/17275#Server

### **Why This Happens:**

Tencent Cloud uses **server-side license checks**. When you call:
```dart
TUICallKit.instance.calls([userId], callMediaType);
```

Tencent's server checks:
1. Is SDKAppID valid? ✅
2. Is user logged in? ✅
3. **Does package support calls?** ❌ **FAILS HERE**

No code changes can bypass this - you **MUST** have valid package.

---

## 🆘 Still Having Issues?

### **Common Problems:**

**1. "Invalid SDKAppID"**
- Double-check you copied correctly
- Ensure no spaces or extra characters
- SDKAppID should be a number like `1400123456`

**2. "Invalid UserSig"**
- Check SecretKey is correct
- Ensure it matches the SDKAppID
- SecretKey should be 64 characters (hex string)

**3. Still getting license error**
- Verify package is active in console
- Check package includes "Call" features
- Wait 5-10 minutes after purchasing package

### **Get Help:**

- Tencent Support: https://cloud.tencent.com/document/product/647/84493
- TRTC Console: https://console.cloud.tencent.com/trtc
- Quick Start Guide: https://cloud.tencent.com/document/product/647/82985

---

## ✅ Summary

**What you need to do:**

1. ✅ Get valid SDKAppID and SecretKey from Tencent Console
2. ✅ Update `generate_test_user_sig.dart` (lines 30 and 50)
3. ✅ Hot restart app
4. ✅ Test call - should work!

**Current values (EXPIRED):**
```
SDKAppID: 20031940 ❌
SecretKey: 113a6f535e978b705fe8bf3f02926f923a9daef400ee1b1bf5c6abcb12efef90 ❌
```

**You need:**
```
SDKAppID: YOUR_VALID_ID ⬅️ Get from console
SecretKey: YOUR_VALID_KEY ⬅️ Get from console
```

---

**This is NOT a bug in your code - it's a Tencent Cloud account configuration issue!**

**Once you update the credentials, calls will work immediately.** 🚀

