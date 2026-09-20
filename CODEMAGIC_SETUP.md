# Codemagic setup — MyDays (one-time)

`codemagic.yaml` in the repo root defines the build. A few credentials can't
live in the repo — set these up once in the Codemagic UI, then every push to
`main` builds and publishes automatically.

This mirrors the prayer app's Codemagic setup, adapted for MyDays. Key
differences from that app are called out inline.

| | MyDays |
|---|---|
| iOS bundle ID | `com.mydays.app` |
| Android package | `com.mydays.mydays` |
| Android keystore ref (Codemagic) | `mydaysyaml` (**new — must be created, see step 2**) |
| Play track | `internal` (promote to production in Play Console) |

## 0. Switch the app to codemagic.yaml

In Codemagic → your MyDays app → **Settings**, switch the build configuration
from the **Workflow Editor** to **codemagic.yaml**. Codemagic detects the file
on the next build. (Add MyDays as a new app in Codemagic first if it isn't there,
pointing at this repo.)

## 1. Pin the Flutter version (already done in yaml)

`codemagic.yaml` pins `flutter: 3.44.8`. Confirm that matches your machine:

```bash
flutter --version
```

If yours differs, edit `flutter_version` at the top of `codemagic.yaml` so CI and
local always agree (this prevents dependency-drift build failures).

## 2. Android — create and upload a release keystore  ⚠️ MyDays has none yet

Unlike the prayer app, MyDays has **no release keystore**. Create one **once**
and keep it safe forever — the keystore that signs your first Play upload is
permanent for this app (see the Play App Signing note at the end).

Create it locally (Java `keytool`):

```bash
keytool -genkey -v -keystore mydays-release.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias mydays
```

You'll be asked for a **keystore password**, a **key password**, and your name/org.
**Record all three values + the alias (`mydays`)** in a password manager. Back up
`mydays-release.jks` somewhere safe (NOT in git).

Then upload it to Codemagic:

1. Codemagic → **Teams/App settings → Code signing identities → Android keystores**
2. **Upload** `mydays-release.jks` and enter:
   - **Reference name:** `mydaysyaml`  ← must match `android_signing` in the yaml
   - **Keystore password**, **Key alias** (`mydays`), **Key password**

MyDays' `android/app/build.gradle.kts` reads the keystore directly from the
`CM_KEYSTORE_PATH` / `CM_KEYSTORE_PASSWORD` / `CM_KEY_ALIAS` / `CM_KEY_PASSWORD`
env vars that Codemagic injects from this reference — so **no `key.properties`
step is needed** (that's why the yaml has none).

## 3. Android — Google Play publishing

You can **reuse the same service account** you set up for the prayer app if it's
the same Google Play account — just make sure it has release permission for the
MyDays app in Play Console. Otherwise:

1. In Google Cloud / Play Console, create a **service account** with the *Google
   Play Android Developer API* enabled, grant it release permissions in Play
   Console, and download its **JSON key**.
2. Codemagic → MyDays app → **Environment variables**:
   - Variable: `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`
   - Value: paste the entire JSON file contents
   - Group: `google_play`  ← must match `groups:` in the yaml
   - Check **Secure**.

> First upload to a track must sometimes be done manually in Play Console before
> the API will accept automated uploads. Since MyDays is still a **Draft app**,
> do a manual first `.aab` upload (Internal testing) to activate the app, then CI
> auto-publishes thereafter. Promote internal → production in Play Console.

## 4. iOS — App Store Connect API key + signing

The ASC API key is **account-wide**, so you can **reuse the same key** you set up
for the prayer app:

1. If not already in Codemagic: App Store Connect → **Users and Access →
   Integrations → App Store Connect API** → create a key with **App Manager**
   role. Note the **Issuer ID**, **Key ID**, download the **.p8**.
2. Codemagic → **Teams/App settings → Integrations → App Store Connect** → add
   the key. Its name in Codemagic must match `integrations.app_store_connect` in
   the yaml — currently `mydays_asc_key`. **If you reuse the prayer app's key,
   change that value in the yaml to whatever that integration is named.**

Signing certificates are also account-wide. Reuse the same persistent
`CERTIFICATE_PRIVATE_KEY` (in the `ios_signing` group). The `fetch-signing-files`
step then creates/reuses the distribution cert and a provisioning profile for
`com.mydays.app` automatically — no manual certs.

Set **`APP_STORE_APPLE_ID`** in `codemagic.yaml` (ios-workflow `vars`) to MyDays'
numeric Apple ID — App Store Connect → MyDays → **App Information → Apple ID**
(a number like `1234567890`). This lets CI auto-increment the build number from
TestFlight. If left as `0000000000`, iOS still builds but uses the `pubspec.yaml`
build number.

## 5. Run it

Push to `main` (or press **Start new build** and pick a workflow). Android and
iOS each build, sign, and publish to their store's test track.

## Notes

- **Build numbers:** auto-incremented by CI — each build queries the store for the
  latest build number and adds 1 (Android via Google Play, iOS via TestFlight),
  so you won't hit "version code already used" rejections. The **version name**
  (`1.0.0`) still comes from `pubspec.yaml` — bump that for user-facing releases.
  Auto-increment needs step 3 (Play credentials) and `APP_STORE_APPLE_ID`
  (step 4); until then it safely falls back to the pubspec build number.
- **Play App Signing (recommended):** enrol MyDays in Play App Signing when you
  create the app in Play Console. Google then holds the definitive app signing
  key and your `mydays-release.jks` becomes only the *upload* key — which can be
  reset if lost. Without it, losing `mydays-release.jks` means you can never
  update the app.
- The old **Workflow Editor** settings are ignored once you switch to
  codemagic.yaml — that's intentional; the yaml is the single source of truth.
- The **web** build is separate (see `deploy.ps1`) and is not part of this CI.
