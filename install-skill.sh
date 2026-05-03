#!/usr/bin/env bash
# wechat-radar Hermes Skill 一键安装脚本
# 用法: ./install-skill.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="${HOME}/.hermes/skills/wechat-radar"

echo "📡 安装 wechat-radar skill..."
echo "   仓库目录: ${REPO_DIR}"
echo "   Skill 目录: ${SKILL_DIR}"

# 1. 创建 skill 目录（如果需要 sudo）
if [ -d "${HOME}/.hermes/skills" ] && [ ! -w "${HOME}/.hermes/skills" ]; then
    echo "⚠️  .hermes/skills 目录需要权限提升"
    sudo mkdir -p "${SKILL_DIR}"
    NEED_SUDO=true
else
    mkdir -p "${SKILL_DIR}"
    NEED_SUDO=false
fi

# 2. 复制核心文件
echo "📦 复制文件..."
if [ "$NEED_SUDO" = true ]; then
    sudo cp "${REPO_DIR}/SKILL.md" "${SKILL_DIR}/"
    sudo cp "${REPO_DIR}/skill_adapt.py" "${SKILL_DIR}/"
    sudo cp "${REPO_DIR}/main.py" "${SKILL_DIR}/"
    sudo cp "${REPO_DIR}/fetcher.py" "${SKILL_DIR}/"
    sudo cp "${REPO_DIR}/filter.py" "${SKILL_DIR}/"
    sudo cp "${REPO_DIR}/prefilter.py" "${SKILL_DIR}/"
    sudo cp "${REPO_DIR}/dedup.py" "${SKILL_DIR}/"
    sudo cp "${REPO_DIR}/notifier.py" "${SKILL_DIR}/"
    sudo cp "${REPO_DIR}/auth.py" "${SKILL_DIR}/"
    sudo cp "${REPO_DIR}/requirements.txt" "${SKILL_DIR}/"
else
    cp "${REPO_DIR}/SKILL.md" "${SKILL_DIR}/"
    cp "${REPO_DIR}/skill_adapt.py" "${SKILL_DIR}/"
    cp "${REPO_DIR}/main.py" "${SKILL_DIR}/"
    cp "${REPO_DIR}/fetcher.py" "${SKILL_DIR}/"
    cp "${REPO_DIR}/filter.py" "${SKILL_DIR}/"
    cp "${REPO_DIR}/prefilter.py" "${SKILL_DIR}/"
    cp "${REPO_DIR}/dedup.py" "${SKILL_DIR}/"
    cp "${REPO_DIR}/notifier.py" "${SKILL_DIR}/"
    cp "${REPO_DIR}/auth.py" "${SKILL_DIR}/"
    cp "${REPO_DIR}/requirements.txt" "${SKILL_DIR}/"
fi

# 复制配置文件（如果不存在）
if [ ! -f "${SKILL_DIR}/config.yaml" ]; then
    if [ "$NEED_SUDO" = true ]; then
        sudo cp "${REPO_DIR}/config.yaml" "${SKILL_DIR}/"
    else
        cp "${REPO_DIR}/config.yaml" "${SKILL_DIR}/"
    fi
    echo "   已复制 config.yaml"
fi

if [ ! -f "${SKILL_DIR}/.env" ]; then
    if [ -f "${REPO_DIR}/.env" ]; then
        if [ "$NEED_SUDO" = true ]; then
            sudo cp "${REPO_DIR}/.env" "${SKILL_DIR}/"
        else
            cp "${REPO_DIR}/.env" "${SKILL_DIR}/"
        fi
        echo "   已复制 .env"
    elif [ -f "${REPO_DIR}/.env.example" ]; then
        if [ "$NEED_SUDO" = true ]; then
            sudo cp "${REPO_DIR}/.env.example" "${SKILL_DIR}/.env"
        else
            cp "${REPO_DIR}/.env.example" "${SKILL_DIR}/.env"
        fi
        echo "   已复制 .env.example 为 .env（请编辑填写 API Key）"
    fi
fi

# 3. 创建/更新 .venv（如果仓库已有，则复用）
VENV_DIR="${REPO_DIR}/.venv"
if [ -d "${VENV_DIR}" ]; then
    echo "✅ 发现已有 .venv，复用"
else
    echo "🐍 创建虚拟环境..."
    python3 -m venv "${VENV_DIR}"
    source "${VENV_DIR}/bin/activate"
    pip install -q -r "${REPO_DIR}/requirements.txt"
    pip install -q beautifulsoup4 lxml pyyaml
fi

echo ""
echo "✅ 安装完成！"
echo ""

# 修复权限（如果使用了 sudo）
if [ "$NEED_SUDO" = true ]; then
    echo "🔧 修复权限..."
    sudo chown -R "${USER}:staff" "${SKILL_DIR}"
    echo "   已将 ${SKILL_DIR} 所有权改为当前用户"
fi

echo ""
echo "下一步："
echo "  1. 编辑 ${SKILL_DIR}/.env 填写 AI API Key"
echo "  2. 编辑 ${SKILL_DIR}/config.yaml 配置你想监控的公众号"
echo "  3. 运行: cd ${REPO_DIR} && source .venv/bin/activate && python3 main.py --login"
echo ""
echo "使用 skill:"
echo "  python3 ${REPO_DIR}/skill_adapt.py run"
