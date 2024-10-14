WebSocket Proxy Server
WebSocket Proxy adalah script berbasis Python yang memungkinkan Anda untuk membuat layanan proxy menggunakan protokol WebSocket. Ini berguna untuk meneruskan koneksi SSH melalui WebSocket, memungkinkan akses yang lebih fleksibel dengan menggunakan layanan CDN atau HTTP injector.

Fitur
Mendukung koneksi WebSocket.
Memungkinkan akses SSH melalui WebSocket dengan CDN.
Konfigurasi port SSH dan HTTP secara dinamis.
Dilengkapi dengan service management menggunakan systemd.
Otentikasi password untuk keamanan tambahan.
Persyaratan
Python 3.x
Paket Python:
websockets
asyncio
bcrypt
Akses sudo untuk menginstal paket dan mengelola service.
Instalasi
Clone Repository:

 
git clone https://github.com/fajarenjoyneer/ssh-webproxy.git
ssh-webproxy
Install Dependencies:

 
sudo apt update
sudo apt install python3 python3-pip -y
pip install websockets bcrypt
Konfigurasi dan Jalankan:

 
sudo bash wsproxy.sh
Pilih opsi "Install WebSocket Proxy" untuk mengatur layanan.

Cara Menggunakan
Setelah layanan berjalan, Anda dapat mengakses WebSocket proxy dengan menggunakan IP dan port yang telah dikonfigurasi. Untuk SSH melalui WebSocket, gunakan payload seperti contoh berikut di HTTP injector:

GET / HTTP/1.1
Host: <hostname-cdn>
Connection: Upgrade
Upgrade: websocket
Manajemen Layanan
Memulai WebSocket Proxy:
 
sudo systemctl start wsproxy
Menghentikan WebSocket Proxy:
 
sudo systemctl stop wsproxy
Restart WebSocket Proxy:
 
sudo systemctl restart wsproxy
Kontributor
Terima kasih kepada semua kontributor yang membantu dalam pengembangan proyek ini.

Lisensi
Proyek ini dilisensikan di bawah MIT License.
