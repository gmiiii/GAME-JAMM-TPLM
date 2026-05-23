# Folder Aset

Tempat menaruh aset game & audio. Saat ini game memakai placeholder (kotak berwarna
yang digambar via kode), jadi folder ini boleh kosong dulu — game tetap bisa dijalankan.

## Struktur

```
assets/
├── models/                  file model 3D (FBX)
│   ├── vehicles/            mobil pemain & mobil traffic
│   │   ├── player_car.fbx
│   │   ├── family_car.fbx
│   │   ├── formula_car.fbx
│   │   ├── truck.fbx
│   │   └── fancy_car.fbx
│   ├── chicken/             ayam (animasi: run / idle / dead / triumphant)
│   │   └── chicken.fbx
│   └── environment/         jalan, bahu, props
│       ├── road_chunk.fbx
│       ├── shoulder.fbx
│       └── props/
├── materials/               material & tekstur bersama
└── audio/
    ├── music/               musik latar (loop) — format .ogg
    │   └── bgm_loop.ogg
    └── sfx/                 efek suara pendek — format .wav
        ├── crash.wav        tabrakan dengan mobil
        ├── chicken_catch.wav  saat tertabrak ayam
        ├── chicken_squash.wav ayam mati ditabrak mobil
        └── game_over.wav
```

## Catatan teknis FBX
- Godot 4.6 mengimpor FBX secara langsung (tidak perlu konverter).
- Orientasi depan model = sumbu +Z, pivot di alas-tengah.
- 1 lebar lane ≈ 3 satuan di game.

## Lisensi aset pihak ketiga
Jika memakai aset dari sumber luar, catat lisensinya di file `CREDITS.md` terpisah.
