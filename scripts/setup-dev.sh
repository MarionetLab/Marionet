#!/bin/bash
# Marionet 开发环境快速设置脚本
# 适用于 Linux / macOS

set -e

echo "=========================================="
echo "  Marionet 开发环境设置"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 打印成功信息
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# 打印警告信息
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 打印错误信息
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# 1. 检查 Git
echo "1. 检查 Git..."
if command_exists git; then
    GIT_VERSION=$(git --version)
    print_success "Git 已安装: $GIT_VERSION"
else
    print_error "Git 未安装，请先安装 Git"
    exit 1
fi

# 2. 检查 Python
echo ""
echo "2. 检查 Python..."
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version)
    print_success "Python 已安装: $PYTHON_VERSION"
else
    print_error "Python 3 未安装，请先安装 Python 3.11+"
    exit 1
fi

# 3. 安装 gdtoolkit
echo ""
echo "3. 安装 GDScript 检查工具..."
if pip3 install --user gdtoolkit==4.* ; then
    print_success "gdtoolkit 安装成功"
else
    print_warning "gdtoolkit 安装失败，请手动安装: pip3 install gdtoolkit"
fi

# 4. 检查 .NET SDK
echo ""
echo "4. 检查 .NET SDK..."
if command_exists dotnet; then
    DOTNET_VERSION=$(dotnet --version)
    print_success ".NET SDK 已安装: $DOTNET_VERSION"

    # 检查版本是否为 8.0+
    MAJOR_VERSION=$(echo $DOTNET_VERSION | cut -d. -f1)
    if [ "$MAJOR_VERSION" -lt 8 ]; then
        print_warning ".NET SDK 版本过低，建议使用 8.0+"
    fi
else
    print_warning ".NET SDK 未安装"
    echo "   下载地址: https://dotnet.microsoft.com/download"
fi

# 5. 检查 Godot
echo ""
echo "5. 检查 Godot Engine..."
if command_exists godot; then
    GODOT_VERSION=$(godot --version 2>&1 | head -n1)
    print_success "Godot 已安装: $GODOT_VERSION"
else
    print_warning "Godot 未在 PATH 中找到"
    echo "   下载地址: https://godotengine.org/download"
    echo "   需要: Godot 4.5+ (Mono/.NET 版本)"
fi

# 6. 检查 gd_cubism 插件
echo ""
echo "6. 检查 GD Cubism 插件..."
if [ -f "engine/addons/gd_cubism/bin/libgd_cubism.windows.release.x86_64.dll" ] || \
   [ -f "engine/addons/gd_cubism/bin/libgd_cubism.linux.release.x86_64.so" ] || \
   [ -f "engine/addons/gd_cubism/bin/libgd_cubism.macos.release.universal.dylib" ]; then
    print_success "GD Cubism 插件已安装"
else
    print_warning "GD Cubism 插件二进制未找到"
    echo "   请查看: engine/addons/gd_cubism/bin/README.md"
    echo "   下载地址: https://github.com/MizunagiKB/gd_cubism/releases"
fi

# 7. 设置 Git hooks（可选）
echo ""
echo "7. 配置 Git hooks（可选）..."
read -p "是否安装 pre-commit hook？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 创建 pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
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
EOF
    chmod +x .git/hooks/pre-commit
    print_success "Pre-commit hook 已安装"
else
    print_warning "跳过 Git hooks 安装"
fi

# 8. 运行初始检查
echo ""
echo "8. 运行初始代码检查..."
cd engine

if command_exists gdlint; then
    echo "检查 GDScript 代码..."
    if gdlint renderer/ core/ 2>&1 | head -n 20; then
        print_success "GDScript 代码检查通过"
    else
        print_warning "发现一些代码风格问题，建议修复"
    fi
else
    print_warning "跳过 GDScript 检查（gdlint 未安装）"
fi

if command_exists dotnet; then
    echo "检查 C# 项目..."
    if dotnet build MarionetEngine.csproj --configuration Release > /dev/null 2>&1; then
        print_success "C# 项目编译成功"
    else
        print_warning "C# 项目编译有问题，请检查"
    fi
else
    print_warning "跳过 C# 检查（.NET SDK 未安装）"
fi

cd ..

# 完成
echo ""
echo "=========================================="
echo "  设置完成！"
echo "=========================================="
echo ""
echo "下一步:"
echo "1. 确保安装了 Godot 4.5+ (Mono 版本)"
echo "2. 下载 GD Cubism 插件到 engine/addons/gd_cubism/bin/"
echo "3. 在 Godot 中打开项目: cd engine && godot project.godot"
echo "4. 开始开发！"
echo ""
echo "文档:"
echo "- 贡献指南: docs/CONTRIBUTING.md"
echo "- 编码规范: docs/CODING_STANDARDS.md"
echo "- CI/CD 指南: docs/CI_CD_GUIDE.md"
echo ""

