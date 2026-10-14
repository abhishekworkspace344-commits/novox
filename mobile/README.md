# NOVOX App (Android and Web)

Flutter client for Android and web browsers (including Microsoft Edge). The web
build uses the same student, staff, and administrator screens, API services,
FastAPI backend, and configured database as the Android app.

## Prerequisites

- Flutter SDK installed and available as `flutter`
- Android Studio/emulator or an Android device for Android runs
- Microsoft Edge installed for web runs
- The NOVOX backend and its configured database running on port `8000`

## Run locally

Start the backend from a separate PowerShell terminal:

```powershell
cd ..\backend
.\venv\Scripts\python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

From the `mobile` directory, list available targets and launch Edge:

```powershell
flutter devices
flutter run -d edge
```

Launch Android by selecting its device ID from `flutter devices`:

```powershell
flutter run -d <android-device-id>
```

The default API address is `http://127.0.0.1:8000` in Edge and the NOVOX LAN
server at `http://192.168.29.167:8000` on a physical Android phone. For Android
emulator use `10.0.2.2`; for another physical phone use the computer's LAN
address and ensure the device can reach it. Set a different API address with:

```powershell
# Android emulator
flutter run -d <android-device-id> --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Physical Android phone (replace with the computer's current LAN IPv4 address)
flutter run -d <android-device-id> --dart-define=API_BASE_URL=http://192.168.29.167:8000
```

For a physical phone, keep it on the same Wi-Fi as the computer, start FastAPI
with `--host 0.0.0.0`, and allow inbound TCP port 8000 in the computer firewall.
The Android manifest permits cleartext HTTP for local development; use HTTPS
before distributing a production build.

`API_BASE_URL` can also be set for Edge or a production deployment. Build the
web site with the URL of the existing FastAPI service:

```powershell
flutter build web --dart-define=API_BASE_URL=https://api.example.com
```

Serve the generated `build/web` directory over HTTPS and allow that website's
origin in the backend `CORS_ALLOW_ORIGIN_REGEX`. Browser location access for
attendance requires a secure origin (HTTPS, or localhost during development).

## Build

```powershell
flutter build web
flutter build apk
```
