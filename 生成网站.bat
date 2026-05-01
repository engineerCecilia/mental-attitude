@echo off
chcp 65001 >nul
echo ========================================
echo 心理学实验 - 网站生成器
echo ========================================
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0generate-site.ps1"

echo.
pause
