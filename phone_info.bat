@echo off
chcp 65001 > nul & rem Устанавливаем кодировку консоли под русскую

setlocal enabledelayedexpansion

:: Получаем дату в формате YYYY-MM-DD
for /f "tokens=2-4 delims=.-/ " %%a in ('date /t') do (
    set DATE=2025-04-26
)

:: Название выходного файла
set OUTPUT_FILE=%~dp0phone_info_%DATE%.txt

:: Проверка, установлен ли ADB
where adb >nul 2>nul
if %errorlevel% neq 0 (
    echo [ОШИБКА] ADB не найден. Убедись, что он установлен и добавлен в PATH.
    pause
    exit /b
)

:: Проверка подключения устройства
adb get-state 1>nul 2>nul
if %errorlevel% neq 0 (
    echo [ОШИБКА] Устройство не подключено или отладка USB не разрешена.
    pause
    exit /b
)

:: Получаем состояние устройства
for /f "tokens=*" %%a in ('adb get-state') do (
    set DEVICE_STATE=%%a
)

:: Проверяем, что устройство в состоянии "device"
if /i "!DEVICE_STATE!" neq "device" (
    echo [ОШИБКА] Устройство не в состоянии "device". Проверь разрешение отладки USB.
    pause
    exit /b
)

:: Выводим инфо с эмодзи
for /f "tokens=*" %%m in ('adb shell getprop ro.product.marketname') do set PHONE_MODEL=%%m

echo 📱 Информация об устройстве: !PHONE_MODEL! > "%OUTPUT_FILE%"
echo ========================================= >> "%OUTPUT_FILE%"

:: Собираем информацию о свойствах устройства с пояснениями
call :GetProp "Модель устройства" ro.product.model
call :GetProp "Код модели устройства" ro.product.mod_device
call :GetProp "Версия Android" ro.build.version.release
call :GetProp "Версия MIUI" ro.miui.ui.version.name
call :GetProp "Устройство" ro.product.device
call :GetProp "Патч безопасности" ro.build.version.security_patch
call :GetProp "Отпечаток сборки" ro.build.fingerprint
call :GetProp "Описание прошивки" ro.build.description

echo ---------------------------------------- >> "%OUTPUT_FILE%"

call :GetProp "Регион устройства" ro.boot.hwc
call :GetProp "Язык и регион прошивки" ro.product.locale
call :GetProp "Регион прошивки" ro.product.locale.region
call :GetProp "Язык прошивки" ro.product.locale.language
call :GetProp "Язык и регион системы" persist.sys.locale

:: Проверяем статус загрузчика
call :CheckBootloader

echo ========================================= >> "%OUTPUT_FILE%"
echo Информация собрана в файл: %OUTPUT_FILE%
pause
exit /b

:GetProp
setlocal
set "TITLE=%~1"
set "PROP=%~2"
for /f "tokens=*" %%a in ('adb shell getprop %PROP%') do (
    if not "%%a"=="" (
        echo %TITLE%: %%a >> "%OUTPUT_FILE%"
        :: Добавляем расшифровку для каждого параметра
        if "%PROP%"=="ro.boot.hwc" (
            if "%%a"=="GL" (
                echo     → GL = Глобальная версия [для международных рынков] >> "%OUTPUT_FILE%"
            ) else if "%%a"=="IN" (
                echo     → IN = Индийская версия [для индийского рынка] >> "%OUTPUT_FILE%"
            ) else if "%%a"=="CN" (
                echo     → CN = Китайская версия [для китайского рынка] >> "%OUTPUT_FILE%"
            ) else if "%%a"=="RU" (
                echo     → RU = Российская версия [для российского рынка] >> "%OUTPUT_FILE%"
            ) else (
                echo     → %%a = Неизвестный регион >> "%OUTPUT_FILE%"
            )
        ) else if "%PROP%"=="ro.product.locale" (
            if "%%a"=="en-GB" (
                echo     → en-GB = Английский язык - Великобритания >> "%OUTPUT_FILE%"
            ) else if "%%a"=="en-US" (
                echo     → en-US = Английский язык - США >> "%OUTPUT_FILE%"
            ) else if "%%a"=="th" (
                echo     → th = Тайский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="ru-RU" (
                echo     → ru-RU = Русский язык - Россия >> "%OUTPUT_FILE%"
            ) else if "%%a"=="zh-CN" (
                echo     → zh-CN = Китайский язык - Китай >> "%OUTPUT_FILE%"
            ) else if "%%a"=="es-ES" (
                echo     → es-ES = Испанский язык - Испания >> "%OUTPUT_FILE%"
            ) else if "%%a"=="fr-FR" (
                echo     → fr-FR = Французский язык - Франция >> "%OUTPUT_FILE%"
            ) else if "%%a"=="de-DE" (
                echo     → de-DE = Немецкий язык - Германия >> "%OUTPUT_FILE%"
            ) else if "%%a"=="it-IT" (
                echo     → it-IT = Итальянский язык - Италия >> "%OUTPUT_FILE%"
            ) else if "%%a"=="pt-PT" (
                echo     → pt-PT = Португальский язык - Португалия >> "%OUTPUT_FILE%"
            ) else if "%%a"=="ja-JP" (
                echo     → ja-JP = Японский язык - Япония >> "%OUTPUT_FILE%"
            ) else if "%%a"=="ko-KR" (
                echo     → ko-KR = Корейский язык - Южная Корея >> "%OUTPUT_FILE%"
            ) else if "%%a"=="pl-PL" (
                echo     → pl-PL = Польский язык - Польша >> "%OUTPUT_FILE%"
            ) else (
                echo     → %%a = Неизвестная локаль >> "%OUTPUT_FILE%"
            )
        ) else if "%PROP%"=="ro.product.locale.region" (
            if "%%a"=="TH" (
                echo     → TH = Таиланд >> "%OUTPUT_FILE%"
            ) else if "%%a"=="IN" (
                echo     → IN = Индия >> "%OUTPUT_FILE%"
            ) else if "%%a"=="CN" (
                echo     → CN = Китай >> "%OUTPUT_FILE%"
            ) else if "%%a"=="RU" (
                echo     → RU = Россия >> "%OUTPUT_FILE%"
            ) else if "%%a"=="US" (
                echo     → US = США >> "%OUTPUT_FILE%"
            ) else (
                echo     → %%a = Неизвестный регион >> "%OUTPUT_FILE%"
            )
        ) else if "%PROP%"=="ro.product.locale.language" (
            if "%%a"=="th" (
                echo     → th = Тайский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="en" (
                echo     → en = Английский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="ru" (
                echo     → ru = Русский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="zh" (
                echo     → zh = Китайский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="es" (
                echo     → es = Испанский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="fr" (
                echo     → fr = Французский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="de" (
                echo     → de = Немецкий язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="it" (
                echo     → it = Итальянский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="pt" (
                echo     → pt = Португальский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="ja" (
                echo     → ja = Японский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="ko" (
                echo     → ko = Корейский язык >> "%OUTPUT_FILE%"
            ) else if "%%a"=="pl" (
                echo     → pl = Польский язык >> "%OUTPUT_FILE%"
            ) else (
                echo     → %%a = Неизвестный язык >> "%OUTPUT_FILE%"
            )
        )
    ) else (
        echo %TITLE%: Не найдено >> "%OUTPUT_FILE%"
    )
)
endlocal
exit /b

:CheckBootloader
setlocal
:: Разделитель перед статусом загрузчика
echo ----------------------------------------- >> "%OUTPUT_FILE%"

:: Проверка состояния загрузчика
for /f "tokens=*" %%z in ('adb shell getprop ro.boot.verifiedbootstate') do (
    set BOOT_STATE=%%z
)

echo Статус загрузчика: !BOOT_STATE! >> "%OUTPUT_FILE%"

if /i "!BOOT_STATE!"=="green" (
    echo     → Загрузчик заблокирован. Система полностью проверена. >> "%OUTPUT_FILE%"
) else if /i "!BOOT_STATE!"=="orange" (
    echo     → Загрузчик разблокирован. Прошивка официальная или кастомная. >> "%OUTPUT_FILE%"
) else if /i "!BOOT_STATE!"=="red" (
    echo     → Ошибка проверки загрузчика. Прошивка может быть повреждена. >> "%OUTPUT_FILE%"
) else (
    echo     → Неизвестный статус загрузчика. >> "%OUTPUT_FILE%"
)

endlocal
exit /b
