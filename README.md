# GAME-JAMM-TPLM

Game *endless driver* **3D** dibuat dengan **Godot 4.6**.

Kamu mengendarai mobil di jalan raya tanpa henti. Ayam penipu bermunculan dari bahu jalan
dan sengaja menabrakkan diri ke mobilmu agar bisa menuntut lewat rekaman dashcam. Hindari
ayam **dan** lalu lintas dari dua arah. Tidak ada kondisi menang — bertahan & kumpulkan jarak
sejauh mungkin. Menabrak ayam atau mobil lain langsung mengakhiri permainan.

## Kontrol

| Aksi | Tombol |
|------|--------|
| Gas (maju lebih cepat) | `W` / `↑` |
| Rem (melambat) | `S` / `↓` |
| Pindah lane kiri/kanan | `A` `D` / `←` `→` |
| Main lagi setelah kalah | `R` / `Enter` / `Spasi` |

Mobil selalu bergerak maju; gas/rem hanya mengatur kecepatan.

## Cara menjalankan

1. Buka Godot 4.6.
2. Import folder proyek ini (pilih `project.godot`).
3. Tekan `F5` atau tombol Play.

## Struktur

```
autoload/   konstanta & state global (GameConfig, GameState)
scripts/    logika gameplay (pemain, ayam, traffic, treadmill jalan, dll)
scenes/     scene Godot
assets/     model 3D & audio (lihat assets/README.md)
```

## Status

Prototipe **playable** memakai placeholder 3D (kotak berwarna). Mekanik inti sudah jalan:
mobil maju dengan gas/rem + hop antar-lane, jalan endless ber-treadmill, lalu lintas dua arah
(searah & berlawanan), ayam yang mengejar sambil menghindari mobil dan bisa tertabrak lalu
respawn, eskalasi kesulitan mengikuti jarak, deteksi tabrakan, dan layar game over. Model FBX
& audio final menyusul.
