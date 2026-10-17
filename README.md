# تطبيق إسنا درايف - EsnaDrive 🛺⚡
> **النسخة الصعيدية المطابقة تماماً لتطبيق inDrive مصر** — مخصص لـ **مدينة إسنا بمحافظة الأقصر** (توك توك • موتوسيكل • تروسيكل • مرسول إسنا).

---

## 🌟 مميزات المشروع والهوية التقنية
- **Framework**: Flutter (Dart) مع معمارية Clean Architecture وإدارة الحالة عبر `Provider`.
- **التصميم والهوية**: لغة عربية كاملة `RTL` بخط `Cairo`، ألوان inDrive المعتمدة (الأخضر الليموني `#A7E92F`، والأخضر `#2DBE60`، والخلفية الداكنة `#121212`).
- **3 أوضاع مدمجة في ملف APK واحد (Role Switching)**:
  1. **وضع الراكب / مرسول الطرود (Passenger & Delivery Sender)**
  2. **وضع الكابتن / المندوب (Driver & Courier Mode)**
  3. **لوحة تحكم إدارة إسنا المحلية (Esna Admin Panel)**

---

## 🌐 الواجهات البرمجية الحية الـ 6 المدمجة (Zero-Key Public APIs)
1. **Project OSRM Routing API**: رسم مسار التوك توك الفعلي على خريطة إسنا وحساب المسافة بدقة بالكيلومتر والزمن بالدقائق.
   `https://router.project-osrm.org/route/v1/driving/{lon1},{lat1};{lon2},{lat2}?overview=full&geometries=geojson`
2. **Nominatim OpenStreetMap API**: البحث عن أي شارع أو مكان في إسنا وتحويل إحداثيات الدبوس لاسم مكان (Reverse Geocoding).
3. **Overpass API**: جلب حي ومباشر لصيدليات إسنا، والمطاعم، والمستشفيات، والمخابز في نطاق 5 كم من مركز المدينة.
4. **Open-Meteo Weather API**: جلب درجة حرارة طقس إسنا الحية وإطلاق حافز الحر الشديد (+5 ج.م للكابتن إذا تخطت 38°م).
5. **QRServer API**: توليد بطاقة **EsnaDrive ID** الرقمية للكباتن، وكود تأكيد تسليم طرد مرسول، وكود دفع فوري المرجعي.
6. **DiceBear Avatar API**: توليد صور رمزية عشوائية ومميزة لجميع الكباتن والركاب.

---

## 🏛️ أهم 10 معالم مدمجة في مدينة إسنا (Quick Landmarks)
1. **معبد إسنا (معبد خنوم)** - وسط البلد `(25.2934, 32.5562)`
2. **كورنيش النيل بإسنا** - شارع البحر `(25.2950, 32.5575)`
3. **مستشفى طيبة التخصصي** `(25.2845, 32.5480)`
4. **قناطر إسنا الجديدة (الكوبري السياحي)** `(25.3160, 32.5540)`
5. **موقف الأقاليم ومحطة قطار إسنا** `(25.2910, 32.5450)`
6. **شارع أحمد عرابي والسوق التجاري** `(25.2905, 32.5535)`
7. **قرية الدير (شرق إسنا)** `(25.3250, 32.5780)`
8. **قرية الحلة** `(25.2450, 32.5650)`
9. **قرية النمسا** `(25.2150, 32.5420)`
10. **قرية كيمان المطاعنة** `(25.3850, 32.5120)`

---

## 🛺 فئات الخدمة والتسعير الذكي في إسنا
- **توك توك (مشوار داخل إسنا)**: فتحة عداد 15 ج.م + 5 ج.م/كم (سعة 1-3 ركاب).
- **موتوسيكل (مشوار سريع)**: 10 ج.م + 3.5 ج.م/كم (فرد واحد).
- **مرسول إسنا (توصيل طرود وأدوية)**: 20 ج.م + 4 ج.م/كم (+5 ج.م خيار التوصيل من الباب للباب).
- **مشاوير القرى (الدير، الحلة، النمسا، الكيمان)**: 25 ج.م + 4.5 ج.م/كم.

---

## ⚙️ هيكل المشروع البرمجي
```
d:/esna_drive/
├── .github/
│   └── workflows/
│       └── build-apk.yml          # مسار البناء التلقائي لملف APK عبر GitHub Actions
├── android/
│   ├── app/
│   │   ├── build.gradle           # minSdkVersion 21, compileSdk 34, RTL enabled
│   │   └── src/main/
│   │       └── AndroidManifest.xml # INTERNET, ACCESS_FINE_LOCATION, RTL
├── lib/
│   ├── main.dart                  # نقطة الانطلاق وإعداد MultiProvider
│   ├── core/
│   │   ├── constants/             # 10 معالم، التصنيفات، ميثاق inDrive
│   │   ├── services/              # خدمة الـ 6 Public APIs مع Fallbacks
│   │   ├── theme/                 # خط Cairo وهوية inDrive الخضراء والداكنة
│   │   └── utils/                 # حاسبة الأجرة والتقريب لأقرب 5 ج.م والعمولة 7%
│   ├── models/                    # RideOrder, DriverBid, DriverProfile, WalletTransaction, EsnaPlace
│   ├── providers/                 # AuthProvider, RideProvider, DriverProvider, WalletProvider, AdminProvider, WeatherProvider
│   ├── screens/
│   │   ├── auth/                  # شاشة تسجيل الدخول وكود التحقق المصري
│   │   ├── passenger/             # الخريطة الحية، المزايدة، التتبع، مرسول إسنا
│   │   ├── driver/                # رادار الطلبات، التوثيق، شحن فوري والمحفظة
│   │   ├── admin/                 # لوحة إدارة إسنا وتعديل الأسعار والعمولة
│   │   └── main_wrapper_screen.dart # شاشة التبديل الفوري بين الأوضاع
│   └── widgets/                   # EsnaMap, WeatherBanner, DriverQr, SosDialog, FareRules, RoleDrawer
├── web/
│   └── index.html                 # محاكي ويب حي متكامل لتجربة التطبيق الفورية بالمتصفح
├── pubspec.yaml                   # جميع حزم Flutter المطلوبة
└── README.md
```

---

## 🚀 كيفية بناء ملف الـ APK وتحميله
### الطريقة 1: عبر GitHub Actions (موصى بها لعدم الحاجة لـ Android SDK محلياً)
1. تم إعداد ملف `.github/workflows/build-apk.yml` تلقائياً داخل المشروع.
2. ارفع المشروع إلى مستودعك على GitHub:
   ```bash
   git add .
   git commit -m "feat: complete EsnaDrive inDrive clone app"
   git push origin main
   ```
3. سيبدأ سير عمل GitHub Actions تلقائياً في بناء ملف الـ APK النظيف ورفعه كـ Artifact باسم `EsnaDrive-inDrive-Clone.apk`.

### الطريقة 2: البناء محلياً (عند توفر Flutter SDK على جهازك)
```bash
flutter pub get
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk EsnaDrive-inDrive-Clone.apk
```

---

## 📱 تجربة المحاكي الحي على المتصفح
تم تضمين محاكي ويب فوري يحاكي هاتف أندرويد بالكامل ويعمل بالربط المباشر مع الخوادم الحية لـ OSRM وOpen-Meteo وNominatim وQRServer وDiceBear.
لتشغيله:
افتح ملف `web/index.html` في أي متصفح لديك أو عبر الخادم المحلي:
`http://127.0.0.1:8080`
