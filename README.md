<div align="center">

# 🎣 **Veloura HUB - Fish It!**
### ⚡ Ultimate Roblox Fishing Automation Script by Veloura
![Version](https://img.shields.io/badge/version-4.0-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/status-STABLE-success?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-lightgrey?style=for-the-badge)
![Language](https://img.shields.io/badge/made%20with-Lua-red?style=for-the-badge)

</div>

---

## 🧩 Overview

**Veloura HUB - Fish It!** adalah modul *Auto Fishing* cerdas untuk Roblox, dibuat untuk mencapai kecepatan tinggi dan stabilitas sempurna.  
Menggunakan sistem event-based, delay presisi, dan pengaturan fleksibel — menjadikannya auto fishing terbaik untuk semua mode permainan.  

💡 Cocok untuk:
> - Farming ikan otomatis tanpa harus AFK  
> - Event grinding dengan efisiensi tinggi  
> - Simulasi player behavior dengan real-time logic  

---

## 🚀 Features

| Fitur | Deskripsi |
|-------|------------|
| 🧠 **Smart Bite Detection** | Deteksi event `BaitSpawned` & `ReplicateTextEffect` secara real-time. |
| ⚙️ **Modular Method System** | Tersedia 4 mode: `V1`, `V2`, `V3 (Normal)`, dan `Balatant`. |
| 🪝 **Normal Mode (V3)** | Paling stabil dan natural untuk sesi fishing panjang. |
| ⚡ **Balatant Mode** | Instant-catch mode – spam event `FishingCompleted` super cepat. |
| 🕹️ **Auto Safety Timeout** | Mencegah stuck state dengan sistem auto cancel cerdas. |
| 💾 **Save Position** | Simpan posisi saat ini untuk kembali otomatis. |
| 🔧 **Adjustable Delay** | Ubah delay umpan langsung dari UI tanpa restart script. |

---

## 🧭 UI Layout

> Semua kontrol dapat diakses dari **Section: “Fishing”** dalam Veloura HUB UI.

| Komponen | Fungsi |
|----------|---------|
| 🎯 **Mode Selector** | Pilih “Normal” sebagai mode utama (V3). |
| ⏱️ **Fishing Delay Input** | Atur delay (0.05 – 5 detik). |
| 🎣 **Auto Fishing Toggle** | Mengaktifkan atau menghentikan auto fish. |
| 💾 **Save Position Toggle** | Menyimpan lokasi saat ini untuk auto-return. |


---

## ⚙️ Installation

```lua
-- Paste ke executor favoritmu:
loadstring(game:HttpGet("https://raw.githubusercontent.com/sinchanthestar/VelouraHUB/main/module/f/fishit.lua"))()
