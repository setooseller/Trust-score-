# Trust Score India (Beta)

Trust Score India (Beta) is a Flutter + Firebase starter application for Indian FMCG trust intelligence. The project focuses on the top three FMCG companies requested for the initial launch: **Hindustan Unilever**, **ITC**, and **Nestle India**. It includes a modular Flutter app, Firebase backend scaffolding, OpenAI-powered review analysis hooks, Firestore rules, and a 60-product starter seed dataset.

## What is included

- **Flutter Android app** with:
  - Home screen with bilingual search, filters, trust summary cards, and trending products.
  - Product detail screen with Trust Score meter, Suthara Score, pros/cons, fake-review risk, features, quality indicators, and platform rating breakdown.
  - Bookmarks, admin edit/create dialog, and feedback submission flows.
  - Firebase Auth service hooks for Google sign-in and Phone OTP.
  - Light and dark themes.
- **Firebase backend** with:
  - Firestore security rules and indexes.
  - Cloud Functions for OpenAI review analysis and Trust Score recalculation.
  - Firestore seed script.
- **Starter data**:
  - 60 bundled products across the three requested FMCG brands.
- **Production-minded architecture**:
  - Riverpod state management.
  - Routing with GoRouter.
  - Centralized models, providers, theme, and utility code.

## Suggested production architecture

### Mobile app
- Flutter stable channel.
- Riverpod for state management.
- Firestore for product catalog, bookmarks, admin edits, and feedback.
- Firebase Auth for Google sign-in and Phone OTP.
- Firebase Functions for expensive AI and scoring operations.

### Backend data flow
1. Collect product + review metadata from approved public APIs/datasets.
2. Store raw ingestion events in Firestore or BigQuery.
3. Trigger Cloud Functions to summarize reviews with OpenAI.
4. Persist structured outputs: summaries, pros/cons, authenticity signal, sentiment signal, Trust Score, and Suthara Score.
5. Serve curated product documents to the Flutter app.

### Scale guidance for 1 lakh+ products
- Keep the mobile app reading a **denormalized product summary collection** instead of raw reviews.
- Use **scheduled ingestion jobs** and **Cloud Tasks / Pub/Sub** for batch processing.
- Move historical raw review text into **BigQuery** or Cloud Storage when review volume becomes high.
- Use **composite indexes** and **cursor-based pagination** instead of loading the full catalog at once.
- Cache AI outputs and only recompute when source review deltas cross a threshold.

## Trust Score formula

The backend implementation uses the user-specified formula:

```text
Trust Score =
(0.4 × average rating normalized to 100) +
(0.2 × review sentiment score) +
(0.2 × review authenticity score) +
(0.2 × brand reputation score)
```

Final score is clamped to **0–100**.

### Suthara Score formula

```text
Suthara Score =
(0.4 × ingredients safety score) +
(0.35 × hygiene perception score) +
(0.25 × user feedback score)
```

Final score is clamped to **0–100**.

## Firebase setup guide

### 1. Create Firebase project
1. Go to Firebase Console.
2. Create a new project.
3. Enable:
   - Authentication
   - Firestore Database
   - Cloud Functions
   - Hosting (optional for web preview)

### 2. Configure Auth
Enable the following sign-in methods:
- **Google**
- **Phone**

### 3. Add Android app
1. Register Android application ID (for example `com.trustscore.india.beta`).
2. Download `google-services.json`.
3. Place it in `android/app/google-services.json`.

### 4. Initialize Firebase CLI locally
```bash
npm install -g firebase-tools
firebase login
cp .firebaserc.example .firebaserc
# edit the project id
firebase use --add
```

### 5. Set OpenAI key for Cloud Functions
```bash
firebase functions:secrets:set OPENAI_API_KEY
```

### 6. Install dependencies
#### Flutter app
```bash
flutter pub get
```

#### Cloud Functions
```bash
cd functions
npm install
cd ..
```

### 7. Deploy rules and functions
```bash
firebase deploy --only firestore:rules,firestore:indexes
firebase deploy --only functions
```

### 8. Seed Firestore starter data
Create a service account JSON and export the path:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/service-account.json
node scripts/seed_firestore.js
```

## Running the Flutter app

### Local debug run
```bash
flutter run
```

### Recommended Android emulator/device setup
- Android Studio installed.
- Latest Android SDK platform.
- USB debugging enabled for physical devices.

### Production APK build
```bash
flutter build apk --release
```

Generated artifact:
- `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle build for Play Store
```bash
flutter build appbundle --release
```

Generated artifact:
- `build/app/outputs/bundle/release/app-release.aab`

## Review ingestion recommendations

Because Google Reviews, Amazon, and Flipkart do not provide unrestricted official public review APIs for all use cases, the best production pattern is:

- Use **approved API providers / datasets** such as SerpAPI, Rainforest API, DataForSEO, YouTube Data API, or licensed commerce data partners.
- Store normalized reviews in a `review_sources` collection.
- Avoid scraping platforms in ways that violate their terms.
- Use scheduled ETL jobs before AI analysis.

## Example Cloud Function workflow

Call `analyzeProductReviews` with:

```json
{
  "productId": "product_001",
  "productName": "Surf Excel Easy Wash",
  "reviews": [
    "Cleans clothes well and smells fresh.",
    "Packaging was damaged but product quality was okay."
  ]
}
```

The function will:
- Ask OpenAI for structured analysis.
- Save Hindi + English summaries.
- Save pros/cons.
- Save sentiment/authenticity/fake-review risk.
- Recalculate scores via the Firestore trigger.

## Files to customize next

- Add generated `firebase_options.dart` using FlutterFire CLI and initialize Firebase in the platform runners.
- Replace first-load bundled fallback reads with paginated Firestore list queries.
- Connect the local bookmark state to authenticated Firestore bookmark sync for signed-in users.
- Add role-based admin claim management for secure product editing.
- Add image ingestion from approved product data APIs for richer 360° galleries.

## Notes

- The current repository is designed as a **clean production starter** rather than a fully deployed API-connected product, because real external review providers and Firebase project secrets are environment-specific.
- The included 60-product dataset is intentionally constrained to the requested three FMCG brands for a focused beta launch.
