# ⚓ CareerOS (Commander Edition)

CareerOS is an immersive, sci-fi-themed digital workspace designed to calibrate, guide, and accelerate professionals along their career voyages. Built with a futuristic aesthetic and robust administrative lockdowns, CareerOS combines professional development, productivity tracking, and AI-driven mentorship into an integrated vessel system.

---

## 🚀 Key Features

### 📡 1. Deep AI Calibrator & Mentor (Career Pilot)
- Powered by the **Gemini 1.5 Pro/Flash architecture**, acting as your personal First Officer.
- Evaluates professional skills and calibrates career goals through an advanced conversational interface.
- Stores local context to guide developers and professionals along dynamic custom tracks.

### 🗺️ 2. Custom Voyage Planner (Roadmaps)
- Design structured roadmaps divided into actionable legs and tactical steps.
- Interactive roadmaps support custom description guides, deleting paths, or creating sequential objectives.
- Seamless connection with local SQLite ledger data using the **Drift backend**.

### 🔒 3. Zen Sanctuary (Inescapable Extreme Lockdown)
- **Zero-Feature Hardware Freeze**: Utilizes native Android enterprise-level APIs (`LockTaskMode`) to completely lock Home, Recents, and system navigation gestures (`LOCK_TASK_FEATURE_NONE`).
- **Notification Defense**: Intercepts and completely suppresses incoming notifications or the Control Center shade.
- **Inescapable Matrix**: Overrides all hardware buttons (Back, Home, Volume) and enforces custom full-screen immersive loops every single second to disable edge swipes or gesture panels.
- **Focus Sentry**: Automatically re-claims focus and forces the app back to the front if any system interruption occurs.

### 📅 4. Voyage Performance & Metrics
- **Mission Consistency Matrix**: A live 30-day continuous scrolling attendance ledger tracking prompt vs late vs missed study blocks.
- **Vessel Health Matrix**: Live checking capability for checking API response and local SQLite ledger integrity.
- **Lifetime Tracking Grid**: A unique grid overlay for mapping macro-level career milestones and learning blocks.

### 📺 5. Scholar Stream
- Seamless integration with media networks for educational streams.
- Full immersive player support built directly inside the transparent glass panels.

---

## 🛠️ Tech Stack & Architecture

CareerOS is built with clean, state-of-the-art Flutter architectural patterns coupled with robust Native Android extensions.

### Flutter Layer
- **State Management:** Fully reactive system controlled by **Riverpod 2.x** and `StateNotifier` protocols.
- **Local Ledger Database:** Multi-table schema utilizing **Drift (SQLite)** for performance data, roadmaps, steps, and consistency matrix data.
- **Navigation Architecture:** Type-safe path resolution via **GoRouter** supporting Stateful Indexed Stack Shell layers.
- **Atmospheric UI Feel:** Dark vantablack themes, real-time glassmorphism, and hardware-accelerated motion blur animations powered by **Flutter Animate**.

### Native Android Layer
- **Bridge Framework:** Flutter **MethodChannel API** (`com.example.careeros/lockdown`) for physical hardware communication.
- **Enterprise Controls:** Android `DevicePolicyManager` receiver for setting the application as a standalone dedicated system kiosk.
- **Hardware Sentry:** Seizure of hardware elements using `AudioManager` audio focus requests and window params (`FLAG_KEEP_SCREEN_ON`).

---

## 🔧 Installation & Device Setup

### 1. Prerequisites
- **Flutter SDK:** `^3.12.0`
- **Android Target SDK:** API 21 to 34+

### 2. Standard Build
```bash
# Clone the repository
git clone https://github.com/your-repo/careeros.git
cd careeros

# Fetch system dependencies
flutter pub get

# Generate local model ledger classes (Drift, Freezed, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Execute debug build onto device
flutter run
```

### 3. [CRITICAL] Activating Extreme Lockdown (Zen Mode Kiosk)
To activate the **Zero-Feature Hard Lock** (blocking Home button, Recents button, status bar control center, and gesture swipes), you must elevate CareerOS to a **Device Policy Owner** via ADB.

1. Connect your Android phone via USB with **USB Debugging** enabled.
2. Ensure no other accounts (like Google or Microsoft accounts) are on the phone during development, or test on an emulator.
3. Execute the following terminal instruction:
```bash
adb shell dpm set-device-owner com.example.careeros/.DeviceAdmin
```
4. Enter **Zen Mode** within the application to engage the extreme isolation protocol.

---

## 📂 System File Architecture
lib/
├── core/
│   ├── initialization/     # Application splash/boot configurations
│   ├── persistence/        # SQLite databases (Drift) and SharedPreferences
│   ├── providers/          # Global application cross-cutting state
│   ├── routing/            # GoRouter multi-branch path engine
│   ├── services/           # AI, Lockdown, and Media network bridges
│   └── theme/              # High-fidelity custom sci-fi dark styles
├── features/
│   ├── home/               # Daily briefing, metrics hub, and attendance ledgers
│   ├── chat/               # Mentor pilot interface
│   ├── roadmap/            # Custom path designer and leg tracks
│   ├── zen/                # Lockdown pre-flight checklist and deep-sea sanctuary
│   ├── profile/            # API key management and critical data purges
│   └── scholar_stream/     # Educational video playback panels
└── main.dart               # Core entry-point of CareerOS

## 📜 Version Controls & License
- **Current Core Engine:** `v1.0.0-PROXIMA`
- **License Type:** Private / Kiosk Workspace Engine Pro
