# GDScript 代码风格自动修复工具 (PowerShell)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  GDScript 代码风格自动修复工具" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 gdformat 是否安装
if (-not (Get-Command gdformat -ErrorAction SilentlyContinue)) {
    Write-Host "❌ gdformat 未安装" -ForegroundColor Red
    Write-Host ""
    Write-Host "请先安装 gdtoolkit:"
    Write-Host "  pip install gdtoolkit==4.*"
    Write-Host ""
    exit 1
}

Write-Host "✓ gdformat 已安装" -ForegroundColor Green
Write-Host ""

# 进入 engine 目录
Push-Location engine

try {
    Write-Host "开始格式化 GDScript 文件..." -ForegroundColor Yellow
    Write-Host ""

    # 格式化文件
    Write-Host "1. 格式化 core/ 目录..."
    gdformat core/

    Write-Host "2. 格式化 renderer/services/ 目录..."
    gdformat renderer/services/

    Write-Host "3. 格式化 renderer/scripts/ 目录..."
    gdformat renderer/scripts/

    Write-Host "4. 格式化 renderer/ui/ 目录..."
    gdformat renderer/ui/

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "  格式化完成！" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    # 运行检查查看剩余问题
    Write-Host "检查剩余问题..." -ForegroundColor Yellow
    Write-Host ""

    $lintResult = gdlint renderer/ core/ 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 所有代码风格问题已修复！" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠️  还有一些问题需要手动修复:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "常见问题:"
        Write-Host "  - 行太长 (max-line-length): 需要手动拆分长行"
        Write-Host "  - 不必要的 elif/else: 需要重构代码逻辑"
        Write-Host "  - 定义顺序: 需要调整类定义顺序"
        Write-Host ""
        Write-Host "运行以下命令查看详细问题:"
        Write-Host "  cd engine"
        Write-Host "  gdlint renderer/ core/"
    }
} catch {
    Write-Host "❌ 格式化过程中出错: $_" -ForegroundColor Red
} finally {
    Pop-Location
}

Write-Host ""

