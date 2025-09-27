#!/usr/bin/env bash

set -euo pipefail

# One-click setup for ritmex-bot (Linux/macOS)
# - Ensures Bun is installed
# - Installs dependencies
# - Prompts for API credentials
# - Generates .env
# - Prepares to start the bot (does not auto-run)

main() {
  require_unix
  ensure_repo
  ensure_bun
  install_deps
  echo
  echo "✅ 安装完成！"
  echo "项目目录：$PROJECT_DIR"
  echo "请在终端中依次输入以下命令启动："
  echo
  echo "  cd ritmex-bot"
  echo "  bun start"
  echo
  echo "提示：启动前可在项目目录内检查或编辑 .env 文件。"
}

require_unix() {
  case "$(uname -s)" in
    Linux|Darwin) ;;
    *) echo "This script supports only Linux and macOS." >&2; exit 1 ;;
  esac
}

ensure_bun() {
  if command -v bun >/dev/null 2>&1; then
    echo "✔ Bun found: $(bun --version)"
    return
  fi
  echo "ℹ Bun not found. Installing Bun..."
  if [ "$(uname -s)" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
    brew install bun
  else
    # Non-interactive install via official script
    curl -fsSL https://bun.sh/install | bash
    # shellcheck disable=SC1090
    if [ -f "$HOME/.bun/bun" ] || [ -d "$HOME/.bun" ]; then
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
    fi
  fi
  if ! command -v bun >/dev/null 2>&1; then
    echo "❌ Failed to install Bun. Please install it manually from https://bun.sh" >&2
    exit 1
  fi
  echo "✔ Bun installed: $(bun --version)"
}

ensure_repo() {
  # Detect if running inside project root already
  if [ -f "package.json" ] && grep -q '"name"\s*:\s*"ritmex-bot"' package.json 2>/dev/null; then
    PROJECT_DIR="$PWD"
    echo "✔ Project detected in current directory: $PROJECT_DIR"
    return
  fi

  local REPO_URL="https://github.com/discountry/ritmex-bot.git"
  local TAR_URL="https://github.com/discountry/ritmex-bot/archive/refs/heads/main.tar.gz"
  local TARGET_DIR="${RITMEX_DIR:-ritmex-bot}"

  if [ -d "$TARGET_DIR" ] && [ -f "$TARGET_DIR/package.json" ]; then
    PROJECT_DIR="$(cd "$TARGET_DIR" && pwd)"
    echo "✔ Project directory found: $PROJECT_DIR"
    return
  fi

  echo "Fetching ritmex-bot sources..."
  if command -v git >/dev/null 2>&1; then
    git clone --depth=1 "$REPO_URL" "$TARGET_DIR"
  else
    echo "ℹ git not found; downloading tarball..."
    curl -fsSL "$TAR_URL" -o /tmp/ritmex-bot.tar.gz
    mkdir -p "$TARGET_DIR"
    tar -xzf /tmp/ritmex-bot.tar.gz --strip-components=1 -C "$TARGET_DIR"
    rm -f /tmp/ritmex-bot.tar.gz
  fi
  PROJECT_DIR="$(cd "$TARGET_DIR" && pwd)"
}

install_deps() {
  echo "Installing dependencies with Bun..."
  (cd "$PROJECT_DIR" && bun install)
}

main "$@"


