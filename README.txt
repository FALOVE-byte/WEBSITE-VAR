TEAM VAR — WEBSITE

Halaman utama: index.html
Panel admin: admin.html

Musik pada bagian "KOMPOSISI TEAM VAR" mulai saat bagian itu terlihat dan
dijeda saat Anda scroll menjauh. Jika browser memblokir autoplay, tekan tombol
"Putar musik" pada bagian tersebut. File atasbawahcantik.mp3 harus tetap berada
di folder yang sama dengan index.html.

Untuk memakai panel admin, jangan buka file HTML dengan klik ganda. Dari
PowerShell, jalankan:

  .\start-website.ps1

Jika PowerShell menolak menjalankan skrip, jalankan:

  powershell -ExecutionPolicy Bypass -File .\start-website.ps1

Saat server dinyalakan, masukkan username (default: admin) dan buat password
minimal 12 karakter. Browser akan meminta username dan password saat membuka
http://127.0.0.1:8765/admin.html. Kredensial berlaku selama proses server
berjalan; jalankan ulang server untuk menggantinya.

Lalu buka http://127.0.0.1:8765/ untuk halaman utama dan
http://127.0.0.1:8765/admin.html untuk panel admin. Biarkan jendela PowerShell
tetap terbuka selama website digunakan; tekan Ctrl+C untuk menghentikan server.

Di panel admin, Anda dapat mengubah banner informasi, mengganti atau menambah
gambar galeri banner, nama dunia, keterangan umum Maxreff dan keterangan
masing-masing dari empat kolom Maxreff, tautan Instagram/TikTok/WhatsApp/
Discord/YouTube/Admin VAR, serta nama, role, deskripsi, dan foto anggota
struktur team. Foto dan gambar banner yang dipilih akan diperkecil otomatis
sebelum disimpan.

Pengaturan tersimpan di localStorage browser. Server lokal ini membuat panel
admin dan halaman utama memakai alamat yang sama agar perubahan tersinkron.
Perubahan hanya berlaku di browser/komputer ini; untuk memublikasikannya kepada
pengunjung lain diperlukan backend dan penyimpanan online. Login ini melindungi
panel saat diakses melalui server lokal, yang hanya menerima koneksi dari
komputer ini; ini bukan sistem login untuk website yang dipublikasikan online.

Panel menyediakan Export JSON, Import JSON, dan Reset Settings untuk mengelola
cadangan pengaturan.
