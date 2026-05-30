<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:6C63FF,100:48CAE4&height=200&section=header&text=Lingua%20AI&fontSize=70&fontColor=ffffff&fontAlignY=38&desc=Break%20language%20barriers%20with%20the%20power%20of%20AI&descAlignY=58&descSize=18&animation=fadeIn" width="100%"/>

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-22C55E?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![CodeAlpha](https://img.shields.io/badge/CodeAlpha-Internship-FF6B6B?style=for-the-badge&logo=graduation-cap&logoColor=white)](https://codealpha.tech)

<br/>

[![Android](https://img.shields.io/badge/Android-✓-3DDC84?style=flat-square&logo=android&logoColor=white)](https://github.com/SarfrazTechie/CodeAlpha_lingua-Ai)
[![iOS](https://img.shields.io/badge/iOS-✓-000000?style=flat-square&logo=apple&logoColor=white)](https://github.com/SarfrazTechie/CodeAlpha_lingua-Ai)
[![Web](https://img.shields.io/badge/Web-✓-4285F4?style=flat-square&logo=googlechrome&logoColor=white)](https://github.com/SarfrazTechie/CodeAlpha_lingua-Ai)
[![Windows](https://img.shields.io/badge/Windows-✓-0078D4?style=flat-square&logo=windows&logoColor=white)](https://github.com/SarfrazTechie/CodeAlpha_lingua-Ai)
[![macOS](https://img.shields.io/badge/macOS-✓-000000?style=flat-square&logo=apple&logoColor=white)](https://github.com/SarfrazTechie/CodeAlpha_lingua-Ai)
[![Linux](https://img.shields.io/badge/Linux-✓-FCC624?style=flat-square&logo=linux&logoColor=black)](https://github.com/SarfrazTechie/CodeAlpha_lingua-Ai)

<br/>

> *"Speak in your language. Be understood in every language."*

</div>

<br/>

---

## 🌟 What is Lingua AI?

**Lingua AI** is a beautifully crafted, cross-platform Flutter application that demolishes the language barrier. Powered by AI, it listens to your voice, understands what you say, translates it instantly, and speaks it back — all in a smooth, animated interface.

Built as a flagship project for the **CodeAlpha Flutter Internship**, Lingua AI combines cutting-edge AI APIs with a polished mobile-first design to deliver a truly magical experience.

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎙️ Voice Input
Speak naturally — the app transcribes your voice in real time using `speech_to_text`, no typing needed.

</td>
<td width="50%">

### 🔊 Text-to-Speech
Hear every translation spoken aloud with expressive, natural-sounding voices via `flutter_tts`.

</td>
</tr>
<tr>
<td width="50%">

### 🌍 AI Translation
Instant, accurate translation across dozens of languages powered by a cloud AI API over HTTP.

</td>
<td width="50%">

### 💾 Smart Persistence
Your language preferences and history are saved locally with `shared_preferences` — always where you left off.

</td>
</tr>
<tr>
<td width="50%">

### 🎵 Audio Playback
Full audio engine via `audioplayers` — play, pause, and replay translated speech on demand.

</td>
<td width="50%">

### 📤 One-Tap Sharing
Share your translated text to any app instantly using the `share_plus` plugin.

</td>
</tr>
<tr>
<td width="50%">

### ✨ Lottie Animations
Silky smooth Lottie animations and shimmer loading states for a premium, app-store-quality UI.

</td>
<td width="50%">

### 🎨 Gorgeous Typography
Curated Google Fonts pairings for a beautiful, readable, and expressive visual experience.

</td>
</tr>
</table>

---

## 🛠️ Tech Stack

<div align="center">

| Category | Technology | Version |
|:---:|:---:|:---:|
| 📱 **Framework** | Flutter / Dart | `^3.10.3` |
| 🧠 **State Management** | Provider | `^6.1.2` |
| 🌐 **Networking** | http | `^1.2.1` |
| 🎙️ **Voice Input** | speech_to_text | `^7.4.0` |
| 🔊 **Text-to-Speech** | flutter_tts | `^4.0.2` |
| 🎵 **Audio Engine** | audioplayers | `^6.1.0` |
| 💾 **Local Storage** | shared_preferences | `^2.2.3` |
| 📤 **Sharing** | share_plus | `13.1.0` |
| 🎨 **Typography** | google_fonts | `^6.2.1` |
| ✨ **Animations** | lottie + shimmer | `^3.1.2` |
| 🔐 **Environment** | flutter_dotenv | `^5.1.0` |
| 🌍 **Localization** | intl | `^0.19.0` |

</div>

---

## 📁 Project Structure

```
🗂️ CodeAlpha_lingua-Ai/
│
├── 📱 android/              ── Android platform files
├── 🍎 ios/                  ── iOS platform files
├── 🌐 web/                  ── Web platform files
├── 🖥️ windows/              ── Windows desktop files
├── 🍏 macos/                ── macOS desktop files
├── 🐧 linux/                ── Linux desktop files
│
├── 📦 lib/                  ── Main Dart source code
│   ├── 🚀 main.dart         ── App entry point
│   ├── 🖼️  screens/         ── UI screens & pages
│   ├── 🧩 widgets/          ── Reusable UI components
│   ├── ⚙️  services/         ── API calls & business logic
│   └── 🔄 providers/        ── State management
│
├── 🔐 .env                  ── API keys (not committed)
├── 📋 pubspec.yaml          ── Dependencies & config
└── 📖 README.md
```

---

## 🚀 Getting Started

### 📋 Prerequisites

Before you begin, ensure you have the following installed:

- ✅ [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.10.3`
- ✅ Dart `^3.x`
- ✅ Android Studio / Xcode (for mobile targets)
- ✅ An AI Translation API key

---

### ⚡ Quick Setup

```bash
# 📥 Step 1 — Clone the repository
git clone https://github.com/SarfrazTechie/CodeAlpha_lingua-Ai.git
cd CodeAlpha_lingua-Ai

# 🔐 Step 2 — Configure environment variables
# Open .env and add your API key:
echo "AI_API_KEY=your_api_key_here" > .env

# 📦 Step 3 — Install dependencies
flutter pub get

# ▶️  Step 4 — Launch the app
flutter run
```

---

### 🎯 Platform-Specific Runs

```bash
flutter run -d android     # 📱 Android device/emulator
flutter run -d ios         # 🍎 iOS simulator/device
flutter run -d chrome      # 🌐 Web browser
flutter run -d windows     # 🖥️  Windows desktop
flutter run -d linux       # 🐧 Linux desktop
flutter run -d macos       # 🍏 macOS desktop
```

---

## 🔐 Environment Setup

Create a `.env` file in the project root:

```env
# 🔑 Your AI Translation API Key
AI_API_KEY=your_translation_api_key_here
```

> [!WARNING]
> Never commit your `.env` file with real API keys. It is already listed in `.gitignore` — keep it that way.

---

## 📲 Required Permissions

<details>
<summary><b>🤖 Android</b> — <code>android/app/src/main/AndroidManifest.xml</code></summary>

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```
</details>

<details>
<summary><b>🍎 iOS</b> — <code>ios/Runner/Info.plist</code></summary>

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Lingua AI needs microphone access for voice translation.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Lingua AI uses speech recognition to transcribe your voice.</string>
```
</details>

---

## 🤝 Contributing

Contributions, issues and feature requests are welcome!

```bash
# 1️⃣  Fork the repository
# 2️⃣  Create your feature branch
git checkout -b feature/amazing-feature

# 3️⃣  Commit your changes
git commit -m "✨ Add amazing feature"

# 4️⃣  Push to the branch
git push origin feature/amazing-feature

# 5️⃣  Open a Pull Request 🎉
```

---

## 👤 Author

<div align="center">

<img src="https://avatars.githubusercontent.com/SarfrazTechie" width="80" style="border-radius:50%"/>

**Sarfraz**

[![GitHub](https://img.shields.io/badge/GitHub-@SarfrazTechie-181717?style=for-the-badge&logo=github)](https://github.com/SarfrazTechie)

*Built with ❤️ during the **CodeAlpha** Flutter Internship Program*

</div>

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:48CAE4,100:6C63FF&height=120&section=footer" width="100%"/>

**⭐ Star this repo if Lingua AI helped or inspired you!**

</div>
