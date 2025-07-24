# 🚀 zRxnx's Advanced Tracker System

An advanced and highly customizable tracking system for **FiveM**.

📄 **[Documentation](https://docs.zrxnx.at)**  
💬 **[Support Discord](https://discord.gg/mcN25FJ33K)**  

---

## 🔍 About

### ✅ Features

- ⚙️ Custom sync system  
- 📡 Responsible live sync within OneSync range  
- 🌊 Automatically disables in water or on death  
- 🔔 Optional notification on tracker actions  
- 🔒 Usage restricted to specific jobs  
- 🧍 Changeable self-player blip  
- 🗂️ Supported types:  
  `main`, `automobile`, `bike`, `heli`, `boat`, `plane`, `submarine`, `train`, `trailer`, `water`, `death`  
- 🎨 Color system  
- 📌 Blip settings:  
  `friendly`, `heading`, `height`, `vision`, `flash`, `siren`, `category`, `priority`  
- 🤝 Shared job system (shared GPS with other jobs)  
- 🔄 Built-in update checker  
- 🧠 Optimized and fully synced

---

## 🧩 API

### 🔄 Exports

- `disableTracker` (server)

### 📦 Statebags

- `zrx_tracker:disable`  
- `zrx_tracker:hasItem`  
- `zrx_tracker:water`

### 📡 Events

- `zrx_tracker:server:onSend` (server)  
- `zrx_tracker:client:onSend` (client)

---

## 🛠️ Requirements

- [`ox_lib`](https://overextended.dev/ox_lib) (latest version)

---

## 🎬 Preview

▶️ [Watch the video](https://youtu.be/_o1Xb7hIAAs)

---

## 📦 Installation

1. Download the script from the **Releases**  
2. Place it inside your `resources` folder  
3. Add the following to your `server.cfg`:
   ```cfg
   ensure zrx_tracker