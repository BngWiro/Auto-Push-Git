@echo off
title Auto Commit & Push - by BngWiro
color 0F
set REPO_URL=https://github.com/BngWiro/dts-bot-discord.git
set ROOT_DIR=C:\Users\Administrator\Documents\lavictor-omp\lavictor-openmp\bot-djs
set UPDATE_FILE=update.txt

echo ========================================================
echo                  GITHUB AUTO COMMIT
echo                Developer: BngWiro
echo ========================================================
echo.

:: Pindah ke folder root yang sudah ditentukan
echo [INFO] Membuka direktori: %ROOT_DIR%
cd /d "%ROOT_DIR%"

:: Cek apakah folder benar-benar ada
if errorlevel 1 (
    echo.
    echo [ERROR] Folder tidak ditemukan! Pastikan path direktori benar.
    pause
    exit
)
echo.

if not exist ".git" (
    echo [INFO] Folder ini belum disetup Git. Melakukan inisialisasi...
    git init
    :: Set default branch ke main untuk inisialisasi baru
    git branch -M main
    echo.
)

:: ========================================================
:: DETEKSI BRANCH OTOMATIS
:: ========================================================
set "BRANCH="
for /f "delims=" %%I in ('git branch --show-current') do set "BRANCH=%%I"

:: Jika branch kosong (misal repositori baru belum ada commit sama sekali)
if not defined BRANCH set "BRANCH=main"

echo [INFO] Branch otomatis terdeteksi: %BRANCH%
echo.
:: ========================================================

echo [INFO] Memastikan file .amx dan %UPDATE_FILE% diabaikan oleh Git...
if not exist .gitignore (
    echo *.amx> .gitignore
    echo %UPDATE_FILE%>> .gitignore
) else (
    findstr /x /c:"*.amx" .gitignore >nul 2>&1
    if errorlevel 1 echo *.amx>> .gitignore
    
    findstr /x /c:"%UPDATE_FILE%" .gitignore >nul 2>&1
    if errorlevel 1 echo %UPDATE_FILE%>> .gitignore
)

::git rm -r --cached "*.amx" >nul 2>&1
::git rm -r --cached "gamemodes/*.amx" >nul 2>&1
git rm -r --cached "%UPDATE_FILE%" >nul 2>&1

echo [INFO] Menyiapkan semua file untuk di-commit...
git add .
echo.

if not exist "%UPDATE_FILE%" (
    type nul > "%UPDATE_FILE%"
)

:: Cek apakah file ada isinya
set "ada_isi="
for /f "usebackq delims=" %%A in ("%UPDATE_FILE%") do (
    set "ada_isi=1"
)

:: Jika kosong, pakai tanggal. Jika ada isi, baca per baris.
if not defined ada_isi (
    echo [INFO] File "%UPDATE_FILE%" kosong.
    echo [INFO] Membuat commit otomatis dengan waktu saat ini...
    git commit -m "Update - %DATE% %TIME%"
) else (
    echo [INFO] Membaca pesan commit dari "%UPDATE_FILE%"...
    echo.
    for /f "usebackq delims=" %%A in ("%UPDATE_FILE%") do (
        echo [INFO] Membuat commit: "%%A"
        git commit -m "%%A" --allow-empty
    )
)

echo.
echo ========================================================
echo                  KONFIRMASI PUSH
echo ========================================================
echo  Dari Folder : %ROOT_DIR%
echo  Ke Git Repo : %REPO_URL%
echo  Branch      : %BRANCH%
echo ========================================================
echo.

set /p confirm=" Apakah kamu ingin push ke GitHub sekarang? (Y/N): "

if /i "%confirm%"=="Y" goto do_push
goto cancel_push

:do_push
echo.
echo [INFO] Mengunggah file ke tujuan: %REPO_URL%
git push "%REPO_URL%" %BRANCH%
type nul > "%UPDATE_FILE%"

echo.
echo ========================================================
echo                   GITHUB UPLOAD FINISHED
echo ========================================================
echo [INFO] File "%UPDATE_FILE%" telah dikosongkan secara otomatis.
pause
exit

:cancel_push
echo.
echo [INFO] Push ke GitHub dibatalkan!
echo [INFO] Perubahan kamu tetap sudah tersimpan secara lokal (Commit berhasil).
echo.

type nul > "%UPDATE_FILE%"
pause
exit
