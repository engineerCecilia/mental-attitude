@echo off
chcp 65001 >nul
echo ========================================
echo 无路之路 - 网站生成器
echo ========================================
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0generate-site.ps1"

echo.
pause
