# NOVOX Mobile

Flutter client for Android and web browsers (including Microsoft Edge).

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

The default API address is the NOVOX LAN server at `http://192.168.29.166:8000`.
For Edge or the Android emulator, override it with the appropriate host address
(`127.0.0.1` for Edge or `10.0.2.2` for the emulator). For another physical
Android device, use the computer's LAN address and ensure the device can reach it:

```powershell
flutter run -d <android-device-id> --dart-define=API_BASE_URL=http://<computer-lan-ip>:8000
```

`API_BASE_URL` can also be set for Edge or a production deployment. Use an
HTTPS URL outside local development.

## Build

```powershell
flutter build web
flutter build apk
```
