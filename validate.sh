#!/usr/bin/env bash
# Configuration validation script for modular Nix-on-macOS setup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔍 Validating Nix-on-macOS configuration..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check counters
PASSED=0
FAILED=0
WARNINGS=0

check_pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((PASSED++))
}

check_fail() {
  echo -e "${RED}✗${NC} $1"
  ((FAILED++))
}

check_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
  ((WARNINGS++))
}

echo "📋 Configuration Files"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# Check required files exist
if [ -f "config.nix" ]; then
  check_pass "config.nix exists"
else
  check_fail "config.nix missing"
fi

if [ -f "flake.nix" ]; then
  check_pass "flake.nix exists"
else
  check_fail "flake.nix missing"
fi

if [ -f "home.nix" ]; then
  check_pass "home.nix exists"
else
  check_fail "home.nix missing"
fi

echo ""
echo "🔧 Configuration Variables"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Parse config.nix values (basic extraction)
if [ -f "config.nix" ]; then
  USERNAME=$(grep 'username = ' config.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')
  FULLNAME=$(grep 'fullName = ' config.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')
  EMAIL=$(grep 'email = ' config.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')
  HOSTNAME=$(grep 'hostname = ' config.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')
  ARCH=$(grep 'architecture = ' config.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')

  echo "Username:     $USERNAME"
  echo "Full Name:    $FULLNAME"
  echo "Email:        $EMAIL"
  echo "Hostname:     $HOSTNAME"
  echo "Architecture: $ARCH"

  # Validate username matches system
  CURRENT_USER=$(whoami)
  if [ "$USERNAME" = "$CURRENT_USER" ]; then
    check_pass "Username matches current user ($CURRENT_USER)"
  else
    check_warn "Username ($USERNAME) differs from current user ($CURRENT_USER)"
  fi

  # Validate architecture matches system
  CURRENT_ARCH=$(uname -m)
  if [ "$ARCH" = "aarch64-darwin" ] && [ "$CURRENT_ARCH" = "arm64" ]; then
    check_pass "Architecture matches system (Apple Silicon)"
  elif [ "$ARCH" = "x86_64-darwin" ] && [ "$CURRENT_ARCH" = "x86_64" ]; then
    check_pass "Architecture matches system (Intel)"
  else
    check_warn "Architecture ($ARCH) may not match system ($CURRENT_ARCH)"
  fi

  # Validate email format
  if [[ "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    check_pass "Email format is valid"
  else
    check_warn "Email format may be invalid: $EMAIL"
  fi
else
  check_fail "Cannot validate config.nix (file missing)"
fi

echo ""
echo "🔗 Variable Usage"
echo "━━━━━━━━━━━━━━━━━━━"

# Check that variables are used (not hardcoded)
if grep -q 'config.user.username' flake.nix; then
  check_pass "flake.nix uses config.user.username"
else
  check_warn "flake.nix may not be using config.user.username"
fi

if grep -q 'userConfig.user' home.nix; then
  check_pass "home.nix uses userConfig.user variables"
else
  check_warn "home.nix may not be using userConfig.user variables"
fi

# Check for hardcoded username (should be none)
HARDCODED_COUNT=$(grep -r '"jschuhmann"' flake.nix home.nix 2>/dev/null | wc -l || echo 0)
if [ "$HARDCODED_COUNT" -eq 0 ]; then
  check_pass "No hardcoded username in flake.nix or home.nix"
else
  check_warn "Found $HARDCODED_COUNT hardcoded username references"
fi

echo ""
echo "🏗️  Nix Flake Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━"

# Check if Nix is installed
if command -v nix &> /dev/null; then
  check_pass "Nix is installed ($(nix --version | head -1))"

  # Check if flakes are enabled
  if nix flake show --help &> /dev/null; then
    check_pass "Nix flakes are enabled"

    # Validate flake structure
    echo ""
    echo "Running: nix flake check --no-build"
    if nix flake check --no-build 2>&1; then
      check_pass "Flake structure is valid"
    else
      check_fail "Flake validation failed"
    fi
  else
    check_warn "Nix flakes may not be enabled"
  fi
else
  check_warn "Nix is not installed (validation limited)"
fi

echo ""
echo "📦 Package Definitions"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# Count packages in home.nix
PKG_COUNT=$(grep -c '^    [a-z]' home.nix || echo 0)
echo "Packages defined: ~$PKG_COUNT"

if [ "$PKG_COUNT" -gt 50 ]; then
  check_pass "Substantial package list defined"
elif [ "$PKG_COUNT" -gt 0 ]; then
  check_warn "Small package list ($PKG_COUNT packages)"
else
  check_warn "No packages found in home.nix"
fi

echo ""
echo "🍺 Homebrew Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count Homebrew casks
CASK_COUNT=$(grep -A 100 'casks = \[' flake.nix | grep '".*"' | wc -l || echo 0)
echo "Homebrew casks: $CASK_COUNT"

if [ "$CASK_COUNT" -gt 0 ]; then
  check_pass "Homebrew casks configured"
else
  check_warn "No Homebrew casks defined"
fi

# Check if Homebrew is installed
if command -v brew &> /dev/null; then
  check_pass "Homebrew is installed ($(brew --version | head -1))"
else
  check_warn "Homebrew not installed (will be installed on first build)"
fi

echo ""
echo "📊 Summary"
echo "━━━━━━━━━━"
echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC}   $FAILED"

echo ""

if [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}✨ Configuration validation successful!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Review config.nix and update personal information"
  echo "  2. Run: darwin-rebuild switch --flake .#$HOSTNAME"
  exit 0
else
  echo -e "${RED}❌ Configuration validation failed${NC}"
  echo ""
  echo "Please fix the errors above before building."
  exit 1
fi
