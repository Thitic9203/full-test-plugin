#!/bin/bash
# One-command install: required skills + full-test plugin + cache symlinks + hooks
# Usage:
#   curl -sL https://raw.githubusercontent.com/Thitic9203/full-test-plugin/main/scripts/install.sh | bash

set -e

SRC_BASE="$HOME/.claude/plugins/src"
CACHE_BASE="$HOME/.claude/plugins/cache"
SETTINGS="$HOME/.claude/settings.json"

echo "=== full-test plugin installer ==="
echo ""

# --- Helper: clone or pull a repo ---
clone_or_pull() {
  local url="$1" dir="$2" label="$3"
  if [ -d "$dir/.git" ]; then
    echo "  [$label] Exists — pulling latest..."
    git -C "$dir" pull origin main --quiet 2>/dev/null || git -C "$dir" pull --quiet 2>/dev/null || true
  else
    echo "  [$label] Cloning..."
    mkdir -p "$(dirname "$dir")"
    git clone "$url" "$dir" --quiet
  fi
}

# --- Helper: create cache symlink ---
setup_cache() {
  local repo_dir="$1" marketplace="$2" plugin="$3" subdir="$4"
  local target="$CACHE_BASE/$marketplace/$plugin"
  local source="$repo_dir"
  [ -n "$subdir" ] && source="$repo_dir/$subdir"

  # Read version from plugin.json or marketplace.json
  local version
  version=$(grep '"version"' "$source/.claude-plugin/plugin.json" 2>/dev/null | head -1 | sed 's/.*"\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/')
  [ -z "$version" ] && version=$(grep '"version"' "$source/.claude-plugin/marketplace.json" 2>/dev/null | head -1 | sed 's/.*"\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/')
  [ -z "$version" ] && version="latest"

  mkdir -p "$target"
  # Remove old entries
  for old in "$target"/*/; do
    [ -e "$old" ] || continue
    rm -rf "$old"
  done
  ln -s "$source" "$target/$version"
  echo "  Cache: $marketplace/$plugin/$version -> $source"
}

# --- Helper: register in settings.json ---
register_settings() {
  # Requires python3 (available on macOS by default)
  if ! command -v python3 &>/dev/null; then
    echo "  Warning: python3 not found — skip settings.json registration"
    echo "  Run these in Claude Code manually:"
    echo "    /plugin marketplace add anthropics/skills"
    echo "    /plugin install document-skills@anthropic-agent-skills"
    echo "    /plugin marketplace add lackeyjb/playwright-skill"
    echo "    /plugin install playwright-skill@playwright-skill"
    echo "    /plugin marketplace add Jeffallan/claude-skills"
    echo "    /plugin install fullstack-dev-skills@fullstack-dev-skills"
    return
  fi

  python3 << 'PYEOF'
import json, os

settings_path = os.path.expanduser("~/.claude/settings.json")

# Read existing settings
if os.path.exists(settings_path):
    with open(settings_path) as f:
        settings = json.load(f)
else:
    settings = {}

# Ensure keys exist
if "extraKnownMarketplaces" not in settings:
    settings["extraKnownMarketplaces"] = {}
if "enabledPlugins" not in settings:
    settings["enabledPlugins"] = {}

# Required marketplaces
marketplaces = {
    "anthropic-agent-skills": {"source": {"source": "github", "repo": "anthropics/skills"}},
    "playwright-skill": {"source": {"source": "github", "repo": "lackeyjb/playwright-skill"}},
    "fullstack-dev-skills": {"source": {"source": "github", "repo": "Jeffallan/claude-skills"}},
    "full-test-dev": {"source": {"source": "github", "repo": "Thitic9203/full-test-plugin"}},
}

# Required plugins
plugins = {
    "document-skills@anthropic-agent-skills": True,
    "playwright-skill@playwright-skill": True,
    "fullstack-dev-skills@fullstack-dev-skills": True,
    "full-test@full-test-dev": True,
}

changed = False
for name, src in marketplaces.items():
    if name not in settings["extraKnownMarketplaces"]:
        settings["extraKnownMarketplaces"][name] = src
        print(f"  Registered marketplace: {name}")
        changed = True

for name, enabled in plugins.items():
    if name not in settings["enabledPlugins"]:
        settings["enabledPlugins"][name] = enabled
        print(f"  Enabled plugin: {name}")
        changed = True
    elif not settings["enabledPlugins"][name]:
        settings["enabledPlugins"][name] = enabled
        print(f"  Re-enabled plugin: {name}")
        changed = True

if changed:
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
    print("  settings.json updated")
else:
    print("  settings.json — already up to date")
PYEOF
}

# ============================================================
# Step 1: Install required skills
# ============================================================
echo "[1/4] Installing required skills..."

# 1a. anthropics/skills → document-skills (source: "./" = repo root)
clone_or_pull "https://github.com/anthropics/skills.git" "$SRC_BASE/anthropic-skills" "document-skills"
setup_cache "$SRC_BASE/anthropic-skills" "anthropic-agent-skills" "document-skills" ""

# 1b. lackeyjb/playwright-skill → playwright-skill (source: "./" = repo root)
clone_or_pull "https://github.com/lackeyjb/playwright-skill.git" "$SRC_BASE/playwright-skill" "playwright-skill"
setup_cache "$SRC_BASE/playwright-skill" "playwright-skill" "playwright-skill" ""

# 1c. Jeffallan/claude-skills → fullstack-dev-skills (source: "./" = repo root)
clone_or_pull "https://github.com/Jeffallan/claude-skills.git" "$SRC_BASE/fullstack-dev-skills" "fullstack-dev-skills"
setup_cache "$SRC_BASE/fullstack-dev-skills" "fullstack-dev-skills" "fullstack-dev-skills" ""

# ============================================================
# Step 2: Install full-test plugin
# ============================================================
echo ""
echo "[2/4] Installing full-test plugin..."

REPO_URL="https://github.com/Thitic9203/full-test-plugin.git"
REPO_DIR="$SRC_BASE/full-test"

clone_or_pull "$REPO_URL" "$REPO_DIR" "full-test"
setup_cache "$REPO_DIR" "full-test-dev" "full-test" ""

# ============================================================
# Step 3: Enable auto-update hooks
# ============================================================
echo ""
echo "[3/4] Enabling auto-update hooks..."
cd "$REPO_DIR"
git config core.hooksPath scripts/hooks
echo "  Hooks: scripts/hooks (pre-commit + post-merge)"

# ============================================================
# Step 4: Register in settings.json
# ============================================================
echo ""
echo "[4/4] Registering plugins..."
register_settings

echo ""
echo "=== Install complete ==="
echo ""
echo "Restart Claude Code, then run:  /full-test"
echo ""
echo "Update:  cd $REPO_DIR && git pull"
echo "         (plugin cache updates automatically — no extra steps)"
