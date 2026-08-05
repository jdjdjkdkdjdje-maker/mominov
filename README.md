# Uzum Tezkor — Mijoz mobil ilovasi (Flutter)

Wolt/Glovo/Uzum Tezkor darajasidagi ovqat yetkazib berish platformasining
**mijoz tomoni**. `uzum-tezkor-backend` (NestJS) API'siga to'g'ridan-to'g'ri
ulanadi va bosqich-3'da qo'shilgan barcha integratsiyalardan (OTP, Google/Apple
login, Click/Payme/Uzum Bank, Firebase push, Socket.IO realtime) foydalanadi.

## 🎨 Dizayn

Admin va restoran paneli bilan bir xil brend tili davom ettirildi:

- **Ranglar:** mango-sariq (`#FF8A3D`) urg'u, to'q ko'k-kulrang `ink` (`#14161F`),
  yashilroq oq `paper` fon (`#F3F5F1`)
- **Shrift:** sarlavhalar — Space Grotesk, matn — Inter, narxlar — IBM Plex Mono
  (shrift fayllari `assets/`ga qo'shilmagan — bundle qilinmaguncha tizim shriftiga
  tushadi, ilova ishlashiga xalaqit bermaydi)
- **Dark / Light mode:** `ThemeMode.system` bo'yicha avtomatik, sozlamalarda
  qo'lda tanlash ham mavjud (17-band)
- **Til:** o'zbek/rus/ingliz — kod-generatsiyasiz yengil i18n tizimi
  (`lib/l10n/app_strings.dart`, 16-band)

## 📦 Qamrov (promptning 1–17-bandlariga mos)

| Band | Holat |
|---|---|
| 3. Ro'yxatdan o'tish | ✅ Telefon+OTP, Google, Apple, avatar/profil tahrirlash |
| 4–5. Asosiy sahifa | ✅ Banner, kategoriyalar, mashhur restoranlar, eng ko'p buyurtma qilingan, qidiruv |
| 6. Taom sahifasi | ✅ Rasmlar, narx/eski narx/chegirma, variant, qo'shimcha, sharh, reyting |
| 7. Savatcha | ✅ Qo'shish/o'chirish/miqdor, promo kod, bonus ball |
| 8. Buyurtma | ✅ Manzil, xaritadan tanlash, yetkazib berish/olib ketish, belgilangan vaqt, izoh |
| 9. To'lov | ✅ Click/Payme/Uzum Bank/karta/naqd (backend `payments/initiate` orqali) |
| 10. Xarita | ✅ Google Maps, GPS, kuryer jonli joylashuvi (Socket.IO), ETA maydonlari |
| 14. Bildirishnoma | ✅ FCM device-token ro'yxatga olish, in-app ro'yxat |
| 16. Til | ✅ uz/ru/en |
| 17. Texnologiya | ✅ Flutter + Riverpod + go_router + Dio + Socket.IO |
| 18. Xavfsizlik | ✅ Secure storage'da JWT, avtomatik refresh-token, hech qanday narx clientda hisoblanmaydi (checkout serverga xom ma'lumot yuboradi) |

**Hali qo'shilmagan:** 11-band (kuryer ilovasi — alohida loyiha bo'ladi),
15-band (AI tavsiyalar — backendda alohida endpoint kerak).

## 🗂 Arxitektura

```
lib/
├── core/            # theme, network (Dio+interceptors), router, storage, config
├── data/
│   ├── models/      # Backend entity'lariga 1:1 mos JSON modellar
│   └── repositories/# Har bir controller uchun alohida repository
├── state/           # Riverpod provider/notifier'lar (auth, cart, orders...)
├── features/        # Har bir ekran/oqim uchun alohida papka
├── shared/widgets/   # Umumiy komponentlar (PriceText, RatingBadge, ...)
└── l10n/             # Yengil i18n (uz/ru/en)
```

- **State management:** Riverpod (`StateNotifier` + `FutureProvider`)
- **Navigatsiya:** `go_router`, auth holatiga qarab avtomatik redirect
  (`splash → onboarding → auth → profil to'ldirish → asosiy oqim`)
- **Tarmoq:** `ApiClient` (Dio) — access token avtomatik qo'shiladi, 401 kelsa
  `refresh` orqali tokenni yangilab so'rovni bir marta qayta yuboradi
- **Realtime:** `RealtimeService` — backend `RealtimeGateway`dagi bir xil xona/hodisa
  nomlaridan foydalanadi (`order:{id}` xonasi, `orderStatusUpdate`,
  `courierLocationUpdate`)

## 🚀 Ishga tushirish

```bash
flutter pub get

flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 \
  --dart-define=SOCKET_URL=http://10.0.2.2:3000 \
  --dart-define=GOOGLE_MAPS_API_KEY=<xaritalar_kaliti> \
  --dart-define=GOOGLE_CLIENT_ID=<google_oauth_client_id>
```

> `API_BASE_URL` — Android emulyatorida lokal backendga ulanish uchun
> `10.0.2.2` ishlatiladi (localhost emas). Haqiqiy qurilmada backend serverning
> tarmoqdagi IP/domenini bering.

### Native loyihalarni to'ldirish

Ushbu arxiv faqat Dart kodi (`lib/`), `pubspec.yaml` va ikkita muhim konfiguratsiya
faylini (`AndroidManifest.xml`, `Info.plist`) o'z ichiga oladi — Gradle/Xcode
boilerplate fayllari kiritilmagan. Birinchi marta ishga tushirishdan oldin:

```bash
flutter create --org uz.uzumtezkor --project-name uzum_tezkor_customer .
```

buyrug'ini shu papkada bajaring (mavjud `lib/`, `pubspec.yaml` fayllarini **saqlab
qoladi**, faqat yo'q bo'lgan `android/`, `ios/` boilerplate fayllarini yaratadi),
so'ng ushbu arxivdagi `android/app/src/main/AndroidManifest.xml` va
`ios/Runner/Info.plist`dagi ruxsatlar/kalitlarni generatsiya qilingan fayllarga
ko'chiring (ular allaqachon to'g'ri joyga qo'yilgan bo'lsa, ustiga yozadi).

### Backend bilan bog'lash

Bu ilova `uzum-tezkor-backend-bosqich3`dagi barcha endpointlardan foydalanadi
(auth, restaurants, products, orders, payments, reviews, promocodes, bonus,
notifications, banners, addresses). Backendni avval ishga tushiring:

```bash
cd uzum-tezkor-backend
docker compose up -d   # yoki lokal PostgreSQL bilan
npm run start:dev
```

## 🔐 Xavfsizlik eslatmalari

- Access/refresh tokenlar `flutter_secure_storage` orqali saqlanadi (Android:
  EncryptedSharedPreferences, iOS: Keychain)
- Barcha narx/chegirma hisob-kitoblari **serverda** amalga oshadi — mobil ilova
  faqat ko'rsatish uchun taxminiy summa hisoblaydi, `createOrder` chaqiruvida esa
  xom `productId`/`variantId`/`addonId` va `quantity`larni yuboradi
- Google/Apple ID tokenlar to'g'ridan-to'g'ri backendning `/auth/social-login`
  endpointiga yuboriladi — backend ularni Google/Apple serverlarida qayta tekshiradi

## ➡️ Keyingi qadam

1. Kuryer mobil ilovasi (Flutter) — 11-band
2. AI tavsiya tizimi uchun backend endpoint + shu ilovada ko'rsatish — 15-band
3. Shrift fayllarini (`SpaceGrotesk`, `Inter`, `IBMPlexMono`) `assets/fonts/`ga
   qo'shib `pubspec.yaml`da e'lon qilish
4. `firebase_options.dart`ni `flutterfire configure` orqali generatsiya qilib
   push bildirishnomalarni to'liq yoqish
