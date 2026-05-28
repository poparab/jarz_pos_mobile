# iOS Web Push: What I Need From You

This file lists the exact information I still need from you to make iPhone web push fully operational for the Flutter web PWA.

Most of what I need is configuration, rollout decisions, and one real-device validation pass.

## Current Status

These items are already provided.

- Rollout scope: `staging and production`
- Firebase project ID: `jarz-pos`
- Firebase `messagingSenderId`: `91050591321`
- Web push VAPID public key: provided
- Production Web app ID: `1:91050591321:web:6b3480d6f7cb00cabd1d48`
- Staging Web app ID: `1:91050591321:web:ae61cff5dab53e08bd1d48`
- `apiKey`: provided
- `authDomain`: provided
- `storageBucket`: provided
- Desired ERPNext web session timeout: `90 days idle timeout`
- Notification tap behavior: `Open app and sync to the related invoice/order`
- Test device: `iPhone 15`
- Home Screen install: `Yes`
- Notification card visibility: `all users`
- UI language: `English`

## Still Missing

These are the remaining items I still need before the feature can be fully enabled.

### 1. The actual web Firebase config values

These are now provided except for `FIREBASE_WEB_MEASUREMENT_ID`.

I still need only this from the web config block if it exists for your Web app:

- `FIREBASE_WEB_MEASUREMENT_ID`

If your Firebase Web app does not use Analytics, this can stay blank.

### 2. The correct Firebase Web app ID

This is now provided.

Received values:

- Production: `1:91050591321:web:6b3480d6f7cb00cabd1d48`
- Staging: `1:91050591321:web:ae61cff5dab53e08bd1d48`

### 3. iOS version on the test phone

I still need:

- the iOS version running on the iPhone 15

### 4. One rollout decision about the Firebase Web app structure

You need to decide one of these:

1. Use **one Firebase Web app** for both staging and production
2. Use **separate Firebase Web apps** for staging and production

The simplest path is option 1.

If you use one Web app in the same Firebase project, the web config values can be the same in:

- `c:\ERPNext\jarz_pos_mobile\jarz_pos\.env.staging`
- `c:\ERPNext\jarz_pos_mobile\jarz_pos\.env.prod`

## Recommended Fastest Path

Use a single Firebase Web app inside the existing Firebase project `jarz-pos`.

That is the fastest way to unblock:

- staging
- production
- iPhone Home Screen web push

If you do that, you will likely reuse the same values for:

- `FIREBASE_WEB_API_KEY`
- `FIREBASE_WEB_AUTH_DOMAIN`
- `FIREBASE_WEB_PROJECT_ID`
- `FIREBASE_WEB_STORAGE_BUCKET`
- `FIREBASE_WEB_MESSAGING_SENDER_ID`
- `FIREBASE_WEB_APP_ID`
- `FIREBASE_WEB_MEASUREMENT_ID`
- `FIREBASE_WEB_VAPID_KEY`

in both env files.

## What I Need

### 1. Which environment to enable first

Tell me one of these:

- `staging only`
- `staging and production`

If you want a safe rollout, use `staging only` first.

### 2. Firebase web app public config

I need these values for each environment you want enabled:

- `WEB_PUSH_ENABLED=true`
- `FIREBASE_WEB_API_KEY`
- `FIREBASE_WEB_AUTH_DOMAIN`
- `FIREBASE_WEB_PROJECT_ID`
- `FIREBASE_WEB_STORAGE_BUCKET`
- `FIREBASE_WEB_MESSAGING_SENDER_ID`
- `FIREBASE_WEB_APP_ID`
- `FIREBASE_WEB_MEASUREMENT_ID` (optional if not used by your Firebase web app)
- `FIREBASE_WEB_VAPID_KEY`

These values are public web Firebase config values. They are not the Firebase Admin service-account secret.

### 3. Confirmation of the Firebase project used by the backend sender

I only need the Firebase `project_id` used by the backend sender so I can confirm the web push config matches it.

I do **not** need the private key or the full service-account JSON pasted into chat.

### 4. Desired ERPNext web session duration

Tell me the intended idle timeout for management users on web.

Examples:

- `30 days`
- `60 days`
- `90 days`

If you want long-lived login, this must be decided on the ERPNext/Frappe side.

### 5. Expected behavior when the user taps a notification

Tell me which behavior you want:

- `Open POS home`
- `Open Kanban`
- `Open app and sync to the related invoice/order`

If you want the best user experience, choose `Open app and sync to the related invoice/order`.

### 6. One real iPhone test device

I need one real device for final validation:

- iPhone model
- iOS version
- confirmation that the user will install the PWA from Safari to the Home Screen

This is required because iOS web push works through the Home Screen-installed PWA flow, not normal Safari tabs.

### 7. Optional UX decisions

These are optional, but useful before final rollout:

- Should the `Enable Notifications` card show for all web users or management roles only?
- Do you want the current English text kept, improved, or localized?

## What You Should Not Send Me

Do **not** send any of these in chat:

- Firebase Admin private key
- Service-account JSON private key contents
- Apple ID password
- ERP/SSH passwords
- Any private token or secret key

If a value is secret, set it locally in the appropriate file or on the server and tell me it has been set.

## Step-by-Step: How To Get Each Item

## Step 1: Decide the rollout scope

Decide whether you want:

1. `staging only`
2. `staging and production`

Send me the choice.

## Step 2: Get the Firebase web app config

In Firebase Console:

1. Open the Firebase project that is already used for Jarz push notifications.
2. Click the gear icon.
3. Open `Project settings`.
4. Under `General`, scroll to `Your apps`.
5. Look at the app cards shown under `Your apps`.
6. If you see only Android or iOS apps, that means you still do **not** have the Web app I need.
7. If a card shows a Web icon, open that Web app.
8. Copy the config from that Web app only.

Important:

- If the `appId` contains `:android:`, it is the wrong app for web push.
- If the `appId` contains `:ios:`, it is the wrong app for web push.
- I need the one whose `appId` contains `:web:`.

Then copy these values:

1. `apiKey`
2. `authDomain`
3. `projectId`
4. `storageBucket`
5. `messagingSenderId`
6. `appId`
7. `measurementId` if present

### If no Firebase Web app exists yet

Do this:

1. In `Your apps`, click `Add app`.
2. Choose the Web icon `</>`.
3. App nickname: use something like `Jarz POS Web`.
4. You do not need Firebase Hosting for this step.
5. Finish app registration.
6. Copy the generated config snippet.

After that, the missing values should become available:

- `FIREBASE_WEB_API_KEY`
- `FIREBASE_WEB_AUTH_DOMAIN`
- `FIREBASE_WEB_PROJECT_ID`
- `FIREBASE_WEB_STORAGE_BUCKET`
- `FIREBASE_WEB_MESSAGING_SENDER_ID`
- `FIREBASE_WEB_APP_ID`
- `FIREBASE_WEB_MEASUREMENT_ID` if present

### If you want one Web app for both staging and production

Use the same Firebase Web app config in both files:

- `c:\ERPNext\jarz_pos_mobile\jarz_pos\.env.staging`
- `c:\ERPNext\jarz_pos_mobile\jarz_pos\.env.prod`

### If you want separate Web apps for staging and production

Create two separate Web apps inside the same Firebase project and copy each config separately.

That is optional. It is only needed if you want to separate Analytics/App identity more strictly.
6. Copy these values:
   - `apiKey`
   - `authDomain`
   - `projectId`
   - `storageBucket`
   - `messagingSenderId`
   - `appId`
   - `measurementId` if present

If no Firebase Web app exists yet:

1. In `Your apps`, click `Add app`.
2. Choose the Web icon.
3. Register the app.
4. Copy the generated config values above.

Then send me the values, or place them directly into:

- `c:\ERPNext\jarz_pos_mobile\jarz_pos\.env.staging`
- `c:\ERPNext\jarz_pos_mobile\jarz_pos\.env.prod`

and tell me they were filled.

## Step 3: Get the web push VAPID public key

In Firebase Console:

1. Open the same Firebase project.
2. Go to `Project settings`.
3. Open the `Cloud Messaging` tab.
4. Find the `Web configuration` / `Web Push certificates` section.
5. Copy the public Web Push key.

This becomes:

- `FIREBASE_WEB_VAPID_KEY`

If no Web Push certificate exists yet:

1. Generate a new Web Push key pair in that same section.
2. Copy the public key.

Send me the public key, or place it directly into the env file(s).

## Step 4: Confirm the backend Firebase project ID

You can get this in either of these ways.

### Option A: From Firebase Console

1. Open `Project settings`.
2. Copy the project ID shown there.

### Option B: From the local service-account JSON file

1. Open the Firebase Admin JSON file already used by the backend.
2. Find the `project_id` field.
3. Copy only the `project_id` value.

Send me only the project ID.

Do not paste the whole JSON file into chat.

## Step 5: Decide the web session duration

Decide the target idle timeout you want for management users.

Examples:

- `30 days idle timeout`
- `60 days idle timeout`
- `90 days idle timeout`

Send me the desired value.

If you are unsure, use `30 days` for the first rollout.

Current status:

- already provided: `90 days idle timeout`

## Step 6: Decide notification tap behavior

Choose one:

1. `Open POS home`
2. `Open Kanban`
3. `Open app and sync to the related invoice/order`

If you are unsure, choose option 3.

Current status:

- already provided: `Open app and sync to the related invoice/order`

## Step 7: Give me one real iPhone validation target

Send me:

- iPhone model
- iOS version
- whether the user will test from a Home Screen-installed PWA

Current status:

- already provided: `iPhone 15`
- already provided: `Yes, Home Screen install`
- still missing: `iOS version`

How to get the iOS version:

1. On the iPhone, open `Settings`
2. Open `General`
3. Open `About`
4. Find `iOS Version`
5. Send me that value

Example:

- `iPhone 14`
- `iOS 17.5`
- `Yes, Home Screen install`

## Step 8: Optional UI decisions

If you want, also send:

- whether the notifications enable card should be visible to all web users or management only
- whether the current text should stay English or be localized

Current status:

- already provided: `show to all users`
- already provided: `stay English`

## Fastest Way To Give Me Everything

You can reply with this template:

```md
Environment: staging only

Firebase web config:
- WEB_PUSH_ENABLED=true
- FIREBASE_WEB_API_KEY=...
- FIREBASE_WEB_AUTH_DOMAIN=...
- FIREBASE_WEB_PROJECT_ID=...
- FIREBASE_WEB_STORAGE_BUCKET=...
- FIREBASE_WEB_MESSAGING_SENDER_ID=...
- FIREBASE_WEB_APP_ID=...
- FIREBASE_WEB_MEASUREMENT_ID=...
- FIREBASE_WEB_VAPID_KEY=...

Backend Firebase project_id: ...

Desired web session timeout: 30 days

Notification tap behavior: Open app and sync to the related invoice/order

Test device:
- iPhone model: ...
- iOS version: ...
- Home Screen install: yes

Optional UX:
- Notification card visibility: management only
- Text/localization: keep English for now
```

## If You Prefer Not To Paste Values In Chat

You can also do this instead:

1. Put the Firebase web config values in:
   - `c:\ERPNext\jarz_pos_mobile\jarz_pos\.env.staging`
   - `c:\ERPNext\jarz_pos_mobile\jarz_pos\.env.prod`
2. Tell me:
   - which environment file(s) you updated
   - the chosen session timeout
   - the chosen tap behavior
   - the iPhone test device details

That is enough for me to continue without you posting the values here.