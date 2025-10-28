@echo off
echo Limpeza Completa do Android - Metro SP
echo ==========================================
echo.

echo 1. Limpando Flutter...
call flutter clean

echo.
echo 2. Removendo cache do Flutter...
if exist .dart_tool rmdir /s /q .dart_tool
if exist build rmdir /s /q build
if exist .flutter-plugins del /f /q .flutter-plugins
if exist .flutter-plugins-dependencies del /f /q .flutter-plugins-dependencies
if exist pubspec.lock del /f /q pubspec.lock

echo.
echo 3. Limpando Gradle...
cd android
call gradlew.bat clean
call gradlew.bat cleanBuildCache

echo.
echo 4. Removendo cache do Gradle local...
if exist .gradle rmdir /s /q .gradle
if exist app\build rmdir /s /q app\build
if exist build rmdir /s /q build

echo.
echo 5. Removendo cache global do Gradle...
if exist %USERPROFILE%\.gradle\caches rmdir /s /q %USERPROFILE%\.gradle\caches

echo.
echo 6. Voltando ao diretorio raiz...
cd ..

echo.
echo 7. Reinstalando dependencias...
call flutter pub get

echo.
echo ========================================
echo LIMPEZA COMPLETA!
echo.
echo Agora execute:
echo   flutter run
echo.
pause

