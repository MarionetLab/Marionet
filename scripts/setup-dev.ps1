# Marionet 开发环境快速设置脚本
# 适用于 Windows PowerShell

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Marionet 开发环境设置" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

function Print-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Print-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Print-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# 1. 检查 Git
Write-Host "1. 检查 Git..."
if (Test-CommandExists git) {
    $gitVersion = git --version
    Print-Success "Git 已安装: $gitVersion"
} else {
    Print-Error "Git 未安装，请先安装 Git"
    exit 1
}

# 2. 检查 Python
Write-Host ""
Write-Host "2. 检查 Python..."
if (Test-CommandExists python) {
    $pythonVersion = python --version
    Print-Success "Python 已安装: $pythonVersion"
} else {
    Print-Error "Python 未安装，请先安装 Python 3.11+"
    Write-Host "   下载地址: https://www.python.org/downloads/"
    exit 1
}

# 3. 安装 gdtoolkit
Write-Host ""
Write-Host "3. 安装 GDScript 检查工具..."
try {
    pip install --user gdtoolkit==4.* | Out-Null
    Print-Success "gdtoolkit 安装成功"
} catch {
    Print-Warning "gdtoolkit 安装失败，请手动安装: pip install gdtoolkit"
}

# 4. 检查 .NET SDK
Write-Host ""
Write-Host "4. 检查 .NET SDK..."
if (Test-CommandExists dotnet) {
    $dotnetVersion = dotnet --version
    Print-Success ".NET SDK 已安装: $dotnetVersion"

    # 检查版本
    $majorVersion = [int]($dotnetVersion.Split('.')[0])
    if ($majorVersion -lt 8) {
        Print-Warning ".NET SDK 版本过低，建议使用 8.0+"
    }
} else {
    Print-Warning ".NET SDK 未安装"
    Write-Host "   下载地址: https://dotnet.microsoft.com/download"
}

# 5. 检查 Godot
Write-Host ""
Write-Host "5. 检查 Godot Engine..."
if (Test-CommandExists godot) {
    $godotVersion = godot --version 2>&1 | Select-Object -First 1
    Print-Success "Godot 已安装: $godotVersion"
} else {
    Print-Warning "Godot 未在 PATH 中找到"
    Write-Host "   下载地址: https://godotengine.org/download"
    Write-Host "   需要: Godot 4.5+ (Mono/.NET 版本)"
}

# 6. 检查 gd_cubism 插件
Write-Host ""
Write-Host "6. 检查 GD Cubism 插件..."
$pluginPath = "engine\addons\gd_cubism\bin\libgd_cubism.windows.release.x86_64.dll"
if (Test-Path $pluginPath) {
    Print-Success "GD Cubism 插件已安装"
} else {
    Print-Warning "GD Cubism 插件二进制未找到"
    Write-Host "   请查看: engine\addons\gd_cubism\bin\README.md"
    Write-Host "   下载地址: https://github.com/MizunagiKB/gd_cubism/releases"
}

# 7. 设置 Git hooks（可选）
Write-Host ""
Write-Host "7. 配置 Git hooks（可选）..."
$response = Read-Host "是否安装 pre-commit hook？(y/N)"
if ($response -match '^[Yy]$') {
    $hookContent = @'
#!/bin/bash
# Pre-commit hook: 运行代码检查

echo "运行 pre-commit 检查..."

# 检查 GDScript 文件
GD_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.gd$' || true)
if [ -n "$GD_FILES" ]; then
    echo "检查 GDScript 文件..."
    if command -v gdlint >/dev/null 2>&1; then
        cd engine
        if ! gdlint $GD_FILES; then
            echo "GDScript 检查失败，请修复后再提交"
            exit 1
        fi
        cd ..
    else
        echo "警告: gdlint 未安装，跳过 GDScript 检查"
    fi
fi

echo "Pre-commit 检查通过"
'@
    $hookPath = ".git\hooks\pre-commit"
    Set-Content -Path $hookPath -Value $hookContent
    Print-Success "Pre-commit hook 已安装"
} else {
    Print-Warning "跳过 Git hooks 安装"
}

# 8. 运行初始检查
Write-Host ""
Write-Host "8. 运行初始代码检查..."
Push-Location engine

if (Test-CommandExists gdlint) {
    Write-Host "检查 GDScript 代码..."
    try {
        $result = gdlint renderer\ core\ 2>&1 | Select-Object -First 20
        Print-Success "GDScript 代码检查完成"
        Write-Host $result
    } catch {
        Print-Warning "发现一些代码风格问题，建议修复"
    }
} else {
    Print-Warning "跳过 GDScript 检查（gdlint 未安装）"
}

if (Test-CommandExists dotnet) {
    Write-Host "检查 C# 项目..."
    try {
        dotnet build MarionetEngine.csproj --configuration Release | Out-Null
        Print-Success "C# 项目编译成功"
    } catch {
        Print-Warning "C# 项目编译有问题，请检查"
    }
} else {
    Print-Warning "跳过 C# 检查（.NET SDK 未安装）"
}

Pop-Location

# 完成
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  设置完成！" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步:"
Write-Host "1. 确保安装了 Godot 4.5+ (Mono 版本)"
Write-Host "2. 下载 GD Cubism 插件到 engine\addons\gd_cubism\bin\"
Write-Host "3. 在 Godot 中打开项目: cd engine; godot project.godot"
Write-Host "4. 开始开发！"
Write-Host ""
Write-Host "文档:"
Write-Host "- 贡献指南: docs\CONTRIBUTING.md"
Write-Host "- 编码规范: docs\CODING_STANDARDS.md"
Write-Host "- CI/CD 指南: docs\CI_CD_GUIDE.md"
Write-Host ""

