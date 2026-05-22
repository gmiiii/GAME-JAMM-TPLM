# GAME-JAMM-TPLM

Game arcade satu layar (orientasi landscape) dibuat dengan **Godot 4.6**.

Kamu mengendalikan sebuah mobil yang menyeberangi jalan raya penuh lalu lintas.
Seekor ayam penipu mengejar mobilmu, berusaha sengaja tertabrak agar bisa menuntutmu
ke pengadilan dengan rekaman dashcam. Tidak ada kondisi menang — bertahanlah selama
mungkin. Satu tabrakan (dengan ayam atau kendaraan lain) langsung mengakhiri permainan.

## Kontrol

| Aksi | Tombol |
|------|--------|
| Gerak per-blok (4 arah) | Panah / `W` `A` `S` `D` |
| Main lagi setelah kalah | `R` / `Enter` / `Spasi` |

## Cara menjalankan

1. Buka Godot 4.6.
2. Import folder proyek ini (pilih `project.godot`).
3. Tekan `F5` atau tombol Play.

## Struktur

```
autoload/   konstanta & state global (GameConfig, GameState)
scripts/    logika gameplay (pemain, ayam, bot car, dll)
scenes/     scene Godot
assets/     aset sprite & audio (placeholder)
```

## Status

Prototipe **playable** dengan art placeholder. Mekanik inti sudah jalan:
gerak pemain grid-stepped, ayam pengejar otomatis, lalu lintas bot car dua arah,
deteksi tabrakan, respawn saat menyeberang, dan layar game over. Aset & polish
final menyusul.
