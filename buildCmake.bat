@echo off
setlocal

:: Указываем путь к CMake. Если CMake в PATH, можно просто указать "cmake".
set "CMAKE_PATH=C:\Program Files\CMake\bin\cmake.exe"

:: Проверка наличия CMake
if not exist "%CMAKE_PATH%" (
    echo Ошибка: CMake не найден по пути %CMAKE_PATH%.
    echo Проверьте правильность пути к CMake или добавьте CMake в PATH.
    pause
    exit /b 1
)

:: Указываем исходную папку и начальное имя папки для сборки
set "SOURCE_DIR=%cd%"
set "BUILD_DIR=%cd%\build"

:: Проверка на существование папки и создание уникального имени
set /a counter=1
set "FINAL_BUILD_DIR=%BUILD_DIR%"

:check_folder
if exist "%FINAL_BUILD_DIR%" (
    set "FINAL_BUILD_DIR=%BUILD_DIR%_%counter%"
    set /a counter+=1
    goto :check_folder
)

:: Создаем уникальный каталог для сборки
mkdir "%FINAL_BUILD_DIR%"
echo Сборка в папке: %FINAL_BUILD_DIR%

:: Переходим в каталог сборки
cd /d "%FINAL_BUILD_DIR%"

:: Выполняем конфигурацию с CMake с генератором Visual Studio 2019
echo Конфигурация CMake...
"%CMAKE_PATH%" -G "Visual Studio 16 2019" "%SOURCE_DIR%"
if %errorlevel% neq 0 (
    echo Ошибка: CMake конфигурация завершилась с ошибкой. Проверьте выходные данные CMake.
    pause
    exit /b %errorlevel%
)

:: Запускаем сборку и выводим отладочные сообщения
echo Запуск сборки...
"%CMAKE_PATH%" --build .
if %errorlevel% neq 0 (
    echo Ошибка: Сборка завершилась с ошибкой. Проверьте выходные данные сборки.
    pause
    exit /b %errorlevel%
)

:: Возвращаемся в исходную директорию
cd /d "%SOURCE_DIR%"

:: Архивируем папку сборки с использованием правильной команды PowerShell
set "ARCHIVE_NAME=build_%date:/=-%_%time::=-%.zip"
powershell -Command "Compress-Archive -Path '%FINAL_BUILD_DIR%\*' -DestinationPath '%ARCHIVE_NAME%'"
if %errorlevel% neq 0 (
    echo Ошибка: Архивирование завершилось с ошибкой.
    pause
    exit /b %errorlevel%
)

echo Сборка завершена успешно и сохранена в архиве %ARCHIVE_NAME%.
endlocal
pause
