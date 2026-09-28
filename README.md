# Aplikasi Perbaikan Kualitas Citra (Image Enhancement Application) - IF4073

Aplikasi berbasis antarmuka grafis (GUI) menggunakan MATLAB untuk melakukan analisis dan perbaikan kualitas citra (image enhancement) tanpa bergantung pada fungsi pemrosesan utama bawaan.

## Anggota Kelompok
* Joel Hotlan Haris Siahaan - 13523025
* Ivant Samuel Silaban - 13523129

## Prasyarat dan Dependensi (Dependencies)
* MATLAB
* Image Processing Toolbox (digunakan terbatas pada fungsi pendukung)

## Cara Menjalankan Program (Execution Guide)
1. Buka aplikasi MATLAB.
2. Pastikan Current Folder MATLAB Anda berada pada direktori utama proyek ini (sejajar dengan file `README.md`).
3. Buka folder `src/app` pada panel Current Folder.
4. Klik kanan pada file `ImageEnhancementGUI.m` dan pilih **Run**, atau ketikkan perintah berikut pada Command Window:
   ```matlab
   cd src/app
   ImageEnhancementGUI
   ```

## Panduan Penggunaan Parameter (GUI)
Beberapa metode _image enhancement_ memerlukan input parameter yang dipisahkan dengan koma pada antarmuka GUI:

* **Intensity Transformation**
  * **Linear / Brightening:** `[Gain/Alpha], [Bias/Beta]` (Contoh: `1.5, 20`)
  * **Log & Inv Log:** `[Konstanta C]` (Contoh: `1`)
  * **Gamma:** `[Gamma], [Konstanta C]` (Contoh: `0.5, 1`)
  * **Contrast Stretching:** `[Rmin], [Rmax]` (Contoh: `50, 200` - Kosongkan untuk rentang otomatis)
* **Image Filtering**
  * **Mean, Median, Min, Max:** `[Ukuran Kernel]` (Contoh: `3` untuk kernel 3x3)
  * **Gaussian:** `[Ukuran Kernel], [Sigma]` (Contoh: `3, 1.0`)
  * **Highboost:** `[Alpha], [Ukuran Kernel]` (Contoh: `1.5, 3`)
  * **Unsharp:** `[Ukuran Kernel]` (Contoh: `3`)
* **Metode Lainnya**
  * **Histogram Equalization:** Tidak memerlukan parameter.
  * **Histogram Specification:** Tidak butuh parameter angka, cukup gunakan tombol *Load Reference Image*.