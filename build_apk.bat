@echo off
echo ========================================================
echo       Compilando PhysioVision para Android (APK)
echo ========================================================
echo Limpiando proyecto...
call flutter clean
echo Obteniendo dependencias...
call flutter pub get
echo Construyendo el APK...
call flutter build apk --release
echo ========================================================
echo Compilacion Terminada! Ruta: build\app\outputs\flutter-apk\app-release.apk
pause
