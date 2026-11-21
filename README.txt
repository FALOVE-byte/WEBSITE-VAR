TEAM VAR — WEBSITE

Halaman utama: index.html
Panel admin: admin.html
Pengaturan website yang dipublikasikan: teamvar-settings.json

Musik pada bagian "KOMPOSISI TEAM VAR" mulai saat bagian itu terlihat dan
dijeda saat Anda scroll menjauh. Jika browser memblokir autoplay, tekan tombol
"Putar musik" pada bagian tersebut. File atasbawahcantik.mp3 harus tetap berada
di folder yang sama dengan index.html.

Untuk melihat website secara lokal, jangan buka file HTML dengan klik ganda.
Dari PowerShell, jalankan:

  .\start-website.ps1

Jika PowerShell menolak menjalankan skrip, jalankan:

  powershell -ExecutionPolicy Bypass -File .\start-website.ps1

Lalu buka http://127.0.0.1:8765/ untuk halaman utama. Biarkan jendela
PowerShell tetap terbuka selama website digunakan; tekan Ctrl+C untuk
menghentikan server.

Di panel admin, Anda dapat mengubah banner informasi, mengganti atau menambah
gambar galeri banner, nama dunia, keterangan umum Maxreff dan keterangan
masing-masing dari empat kolom Maxreff, tautan Instagram/TikTok/WhatsApp/
Discord/YouTube/Admin VAR, serta nama, role, deskripsi, dan foto anggota
struktur team. Foto dan gambar banner yang dipilih akan diperkecil otomatis
sebelum disimpan.

Panel admin memakai localStorage di browser admin. Untuk menerbitkan perubahan
ke teamvargt.com:

1. Tekan Export JSON di panel admin.
2. Ganti file teamvar-settings.json di folder website utama dengan file hasil
   ekspor (namanya harus teamvar-settings.json).
3. Deploy ulang folder website utama ke Netlify.

Website utama membaca pengaturan dari teamvar-settings.json. Perubahan baru
terlihat oleh pengunjung setelah deploy ulang. Untuk memisahkan panel, buat
site Netlify baru dan deploy folder admin-site sebagai publish folder. Netlify
akan memberi alamat .netlify.app; domain khusus dapat dihubungkan lewat
pengaturan domain Netlify.

Website utama dan panel admin tidak lagi berbagi localStorage. Jangan deploy
folder admin-site sebagai pembaruan website utama; deploy folder proyek utama
agar index.html, teamvar-settings.json, dan aset website ikut terbit.

Panel menyediakan Export JSON, Import JSON, dan Reset Settings untuk mengelola
pengaturan dan cadangannya.
