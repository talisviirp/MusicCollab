# 🎶 iOS Collaborative DAW MVP Backlog (for GitHub Copilot)

This file defines the **execution plan** for the iOS DAW + Collaboration MVP.  
Each epic is broken into **issues/tasks**.  
Copilot should work on **one task at a time**, following the cycle instructions below.

---

## 🔄 Copilot Development Cycle Instructions

When starting a task, **always follow this cycle**:

1. **Read the Task**
    - Understand scope, inputs, outputs, and acceptance criteria.
    - Identify which files/modules need to be created or updated.

2. **Implement the Feature**
    - Write clean Swift/SwiftUI code.
    - Use `AVAudioEngine`, `AVAudioUnitSampler`, and Apple APIs when working with audio.
    - Follow MVVM + SwiftUI best practices.
    - Use dependency injection where possible.

3. **Verify Locally**
    - Build and run in Xcode.
    - Add quick manual tests (button press → sound, toggle → step active, etc.).
    - Log errors clearly (`print`, `os_log`).

4**Mark Task as Done**
    - Update this backlog or GitHub issue status.

---

## 📌 Backlog by Epics

### **Epic 1 — Project Setup & Foundations** ✅ **COMPLETED**

**Task 1.1 — Create SwiftUI Xcode project** ✅ **DONE**
- Initialize new SwiftUI iOS project.
- Add targets for iOS 16+.
- Configure bundle identifier.  
  ✅ *Acceptance Criteria*: Project builds and runs "Hello World".

**Task 1.2 — Configure entitlements & session** ✅ **DONE**
- Enable file access + audio background mode in entitlements.
- Setup `AVAudioSession` with low-latency category.  
  ✅ *Acceptance Criteria*: App launches with active audio session, no crash.

**Task 1.3 — Base architecture** ✅ **DONE**
- Create `AudioManager`, `ProjectManager`, `CollaborationManager` stubs.
- Create SwiftUI navigation skeleton: Onboarding → Room List → Sequencer.  
  ✅ *Acceptance Criteria*: User can navigate between empty screens.

---

### **Epic 2 — User & Room Management** ✅ **COMPLETED**

**Task 2.1 — Onboarding screen** ✅ **DONE**
- Screen: enter nickname.
- Persist `userId` + nickname in `UserDefaults`.  
  ✅ *Acceptance Criteria*: Relaunch app → nickname persists.

**Task 2.2 — Room list API integration** ✅ **DONE**
- Fetch rooms with `GET /rooms` (implemented with mock data).
- Display list of rooms in SwiftUI.  
  ✅ *Acceptance Criteria*: Rooms load and refresh without crash.

**Task 2.3 — Create/Join/Leave room** ✅ **DONE**
- Integrate `POST /rooms/create`, `POST /rooms/join/:roomId`, `POST /rooms/leave/:roomId` (mock implementation).
- Navigate to room lobby on join.  
  ✅ *Acceptance Criteria*: User can create/join/leave without error.

---

### **Epic 3 — Core Audio Engine Bootstrapping** ✅ **COMPLETED**

**Task 3.1 — AudioManager setup** ✅ **DONE**
- Implement `AudioManager` with `AVAudioEngine` + master mixer node.
- Safe start/stop of engine.  
  ✅ *Acceptance Criteria*: Engine starts successfully.

**Task 3.2 — Load & play sample** ✅ **DONE**
- Add `AVAudioUnitSampler`.
- Load bundled WAV into sampler.
- Hardcoded button plays sample via `noteOn`.  
  ✅ *Acceptance Criteria*: Button press → audible playback.

---

### **Epic 4 — Sequencer Core** ✅ **COMPLETED**

**Task 4.1 — Sequencer models** ✅ **DONE**
- Create `Pattern`, `Track`, `Step` data models.
- In-memory only.  
  ✅ *Acceptance Criteria*: Can create a pattern with 16 steps.

**Task 4.2 — AVAudioSequencer integration** ✅ **DONE**
- Create sequencer instance tied to AudioEngine.
- Map steps to MIDI events.  
  ✅ *Acceptance Criteria*: Hardcoded pattern loops on play.

**Task 4.3 — Transport controls** ✅ **DONE**
- Play/stop buttons in UI.
- Tempo slider.  
  ✅ *Acceptance Criteria*: Playback starts/stops, tempo changes reflected.

---

### **Epic 5 — Sequencer UI & Collaboration**

**Task 5.1 — Step grid UI**
- Build SwiftUI grid of 16 steps.
- Toggle step on/off with tap.  
  ✅ *Acceptance Criteria*: Tapping toggles state visually.

**Task 5.2 — Pattern binding**
- Toggle updates `Patt
