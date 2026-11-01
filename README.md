# Tugas Rutin 4 - Sistem Parkir Rumah Sakit
## Identitas
- Nama  : Nayla Luthfiah Hanan
- NIM   : 4243250054
- Kelas : Ilmu Komputer D 24

## Diagram kelas
<img width="1898" height="2336" alt="mermaid-diagram" src="https://github.com/user-attachments/assets/0dcc9c09-063d-4cc7-8ac5-92c6ea9be74a" />

## Tangkapan layar keluaran
<img width="371" height="298" alt="image" src="https://github.com/user-attachments/assets/51fef420-7493-40bf-9f30-9ed4fc8fdc7c" />

## Penjelasan
Dalam program Sistem Parkir Rumah Sakit ini, enkapsulasi diterapkan pada class Parkiran, yaitu dengan menggunakan variabel privat seperti _aktif, _pendapatan, dan _peristiwa. Data tersebut tidak diakses atau diubah secara langsung dari luar class, tetapi melalui method seperti masuk(), keluar(), serta getter sisa dan pendapatan.
Polimorfisme diterapkan melalui class Kendaraan sebagai class dasar yang memiliki beberapa turunan, yaitu Motor, Mobil, dan Ambulans. Setiap jenis kendaraan memiliki tarif parkir yang berbeda. Contohnya, method biaya() pada class Ambulans diubah menggunakan override sehingga biaya parkirnya menjadi gratis. Selain itu, terdapat MobilMember yang menggunakan mixin DiskonMember untuk mendapatkan potongan harga.
Async diterapkan pada method masuk(), keluar(), dan main() dengan menggunakan async, await, serta Future.delayed(). Tujuannya agar proses parkir dapat disimulasikan berjalan secara bertahap tanpa langsung menghentikan program.

## Penggunaan AI
AI digunakan untuk membantu memahami materi dan mencari tahu penerapan enkapsulasi, polimorfisme, serta async dalam bahasa Dart. Selain itu, AI juga membantu menjelaskan bagian-bagian kode yang berkaitan dengan ketiga konsep tersebut agar lebih mudah dipahami.
