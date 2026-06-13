@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "ServiceName=odd"
set "DriverFile=odd.sys"
set "DriverDest=%WINDIR%\system32\drivers\%DriverFile%"

echo ================================================
echo          ODD Driver 安装脚本 (修复版)
echo ================================================
echo.

:: 1. 切换到脚本所在目录
pushd "%~dp0"

:: 2. 先清理旧服务（忽略不存在的错误）
echo [1/5] 正在清理旧服务...
sc stop %ServiceName% >nul 2>nul
sc delete %ServiceName% >nul 2>nul
timeout /t 1 >nul

:: 3. 复制驱动文件
echo [2/5] 正在复制驱动文件...
copy /y "%~dp0\%DriverFile%" "%DriverDest%"
if errorlevel 1 (
    echo [错误] 驱动复制失败！请以管理员身份运行。
    pause
    exit /b 1
)
echo     已复制到: %DriverDest%

:: 4. 创建服务（关键修复：使用完整路径 + 加引号）
echo [3/5] 正在创建服务...
sc create %ServiceName% binPath= "%DriverDest%" type= kernel start= demand
if errorlevel 1 (
    echo [错误] 服务创建失败！错误码: %errorlevel%
    pause
    exit /b 1
)
echo     服务创建成功。

:: 5. 启动服务
echo [4/5] 正在启动服务...
sc start %ServiceName%
if errorlevel 1 (
    echo [警告] 服务启动失败（可能被杀毒拦截或需要测试签名模式）
) else (
    echo     服务启动成功！
)

echo.
echo ================================================
echo 驱动已加载，按任意键停止并卸载...
echo ================================================
pause >nul

:: 6. 停止并删除服务
echo [5/5] 正在停止并卸载服务...
sc stop %ServiceName% >nul 2>nul
timeout /t 2 >nul
sc delete %ServiceName% >nul 2>nul

echo.
echo ODD have terminated.
echo 按任意键退出...
pause >nul

popd
exit /b 0