# iOS Fix Scripts - Xcode 16 Swift Compatibility

## 📋 Overview

Scripts để tự động apply fix cho lỗi Xcode 16 Swift compatibility khi build iOS.

## 🚀 Quick Start

### Option 1: Chỉ apply fix (khi Podfile bị reset)

```bash
./apply_ios_fix.sh
```

### Option 2: Clean + Apply fix (recommended)

```bash
./clean_and_fix.sh
```

Sau đó:

```bash
cd .ios && pod install
flutter build ios --simulator --debug
```

---

## 📝 Chi tiết Scripts

### 1. `apply_ios_fix.sh`

**Mục đích:** Apply Xcode 16 Swift compatibility fix vào `.ios/Podfile`

**Khi nào dùng:**
- Sau khi chạy `flutter clean`
- Khi Podfile bị regenerate
- Khi gặp lỗi Swift compatibility

**Cách dùng:**

```bash
./apply_ios_fix.sh
```

**Output:**
```
🔧 Applying Xcode 16 Swift compatibility fix to .ios/Podfile...
📦 Backup created: .ios/Podfile.backup
✅ Fix applied successfully!
✅ Xcode 16 Swift compatibility fix applied!
```

**Features:**
- ✅ Tự động backup Podfile gốc
- ✅ Kiểm tra xem fix đã được apply chưa
- ✅ Rollback nếu có lỗi

---

### 2. `clean_and_fix.sh`

**Mục đích:** Wrapper cho `flutter clean` + tự động apply fix

**Khi nào dùng:**
- Thay thế cho `flutter clean`
- Khi cần clean project và rebuild

**Cách dùng:**

```bash
./clean_and_fix.sh
```

**Các bước script thực hiện:**
1. 🧹 `flutter clean`
2. 📦 `flutter pub get`
3. 🔧 Apply iOS fix

**Output:**
```
🧹 Running flutter clean...
📦 Running flutter pub get...
🔧 Applying iOS fix...
✅ Clean and fix completed successfully!
```

---

## 🔧 Fix Details

Script apply các thay đổi sau vào `.ios/Podfile`:

### 1. Static Framework Linkage

```ruby
use_frameworks! :linkage => :static
```

### 2. Force Swift 5 Mode

```ruby
config.build_settings['SWIFT_VERSION'] = '5.0'
```

### 3. Force Load Swift Compatibility Libraries

- `libswiftCompatibility50.a`
- `libswiftCompatibility51.a`
- `libswiftCompatibility56.a`
- `libswiftCompatibilityConcurrency.a`
- `libswiftCompatibilityDynamicReplacements.a`

### 4. Modify xcconfig Files

Thêm force_load flags vào `OTHER_LDFLAGS` trong xcconfig files.

---

## 🛠️ Troubleshooting

### Script không chạy được

```bash
# Make sure scripts are executable
chmod +x apply_ios_fix.sh
chmod +x clean_and_fix.sh
```

### Python không tìm thấy

Script cần Python 3. Kiểm tra:

```bash
python3 --version
```

Nếu không có, install Python 3:

```bash
brew install python3
```

### Fix không apply được

1. Kiểm tra file backup:

```bash
ls -la .ios/Podfile.backup
```

2. Restore backup nếu cần:

```bash
cp .ios/Podfile.backup .ios/Podfile
```

3. Chạy lại script:

```bash
./apply_ios_fix.sh
```

---

## 📚 Workflow Recommendations

### Development Workflow

**Thay vì:**
```bash
flutter clean
flutter pub get
cd .ios && pod install
flutter build ios
```

**Dùng:**
```bash
./clean_and_fix.sh
cd .ios && pod install
flutter build ios
```

### Quick Fix Only

**Khi chỉ cần apply fix:**
```bash
./apply_ios_fix.sh
cd .ios && pod install
```

---

## ⚠️ Important Notes

1. **Backup tự động:** Script tự động backup Podfile gốc thành `.ios/Podfile.backup`

2. **Idempotent:** Script kiểm tra xem fix đã được apply chưa, tránh apply nhiều lần

3. **Safe rollback:** Nếu có lỗi, script tự động restore backup

4. **Git-friendly:** Nên commit scripts vào git để team khác có thể dùng

---

## 🔗 Related Files

- `XCODE_16_SWIFT_ISSUE.md` - Chi tiết về issue và fix
- `.ios/Podfile` - File được modify bởi script
- `.ios/Podfile.backup` - Backup file (tự động tạo)

---

## 📞 Support

Nếu gặp vấn đề:

1. Check `XCODE_16_SWIFT_ISSUE.md` để hiểu về issue
2. Verify Xcode version: `xcodebuild -version`
3. Check Swift version: `swift --version`
4. Xem backup file: `cat .ios/Podfile.backup`

---

## ✅ Success Indicators

Sau khi chạy script thành công:

```bash
flutter build ios --simulator --debug
# ✓ Built build/ios/iphonesimulator/Runner.app
```

Không còn lỗi:
```
❌ Undefined symbol: __swift_FORCE_LOAD_$_swiftCompatibility56
❌ Undefined symbol: __swift_FORCE_LOAD_$_swiftCompatibilityConcurrency
```

