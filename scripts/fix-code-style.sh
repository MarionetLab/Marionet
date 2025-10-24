#!/bin/bash
# 自动修复 GDScript 代码风格问题

set -e

echo "=========================================="
echo "  GDScript 代码风格自动修复工具"
echo "=========================================="
echo ""

# 检查 gdformat 是否安装
if ! command -v gdformat &> /dev/null; then
    echo "❌ gdformat 未安装"
    echo ""
    echo "请先安装 gdtoolkit:"
    echo "  pip install gdtoolkit==4.*"
    echo ""
    exit 1
fi

echo "✓ gdformat 已安装"
echo ""

# 进入 engine 目录
cd engine

echo "开始格式化 GDScript 文件..."
echo ""

# 格式化文件
echo "1. 格式化 core/ 目录..."
gdformat core/

echo "2. 格式化 renderer/services/ 目录..."
gdformat renderer/services/

echo "3. 格式化 renderer/scripts/ 目录..."
gdformat renderer/scripts/

echo "4. 格式化 renderer/ui/ 目录..."
gdformat renderer/ui/

echo ""
echo "=========================================="
echo "  格式化完成！"
echo "=========================================="
echo ""

# 运行检查查看剩余问题
echo "检查剩余问题..."
echo ""

if gdlint renderer/ core/; then
    echo ""
    echo "🎉 所有代码风格问题已修复！"
else
    echo ""
    echo "⚠️  还有一些问题需要手动修复:"
    echo ""
    echo "常见问题:"
    echo "  - 行太长 (max-line-length): 需要手动拆分长行"
    echo "  - 不必要的 elif/else: 需要重构代码逻辑"
    echo "  - 定义顺序: 需要调整类定义顺序"
    echo ""
    echo "运行以下命令查看详细问题:"
    echo "  cd engine"
    echo "  gdlint renderer/ core/"
fi

echo ""

