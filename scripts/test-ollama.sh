#!/usr/bin/env bash
# Test script for Ollama LLM service configuration

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Testing Ollama Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

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

echo "📦 Service Status"
echo "━━━━━━━━━━━━━━━━━━"

# Check if Ollama service is running
if launchctl list | grep -q "com.ollama.ollama"; then
  check_pass "Ollama LaunchDaemon is loaded"

  # Get PID
  PID=$(launchctl list | grep "com.ollama.ollama" | awk '{print $1}')
  if [ "$PID" != "-" ]; then
    check_pass "Ollama process is running (PID: $PID)"
  else
    check_fail "Ollama LaunchDaemon loaded but process not running"
  fi
else
  check_fail "Ollama LaunchDaemon not found"
fi

# Check if Ollama binary exists
if command -v ollama &> /dev/null; then
  check_pass "Ollama CLI is installed"
  echo "   Version: $(ollama --version 2>&1 | head -1)"
else
  check_fail "Ollama CLI not found in PATH"
fi

echo ""
echo "🌐 API Connectivity"
echo "━━━━━━━━━━━━━━━━━━━"

# Check API endpoint
if curl -s -f http://localhost:11434/api/version &> /dev/null; then
  check_pass "Ollama API is responding"

  # Get version from API
  VERSION=$(curl -s http://localhost:11434/api/version 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
  echo "   API Version: $VERSION"
else
  check_fail "Ollama API not responding at http://localhost:11434"
fi

# Test tags endpoint
if curl -s -f http://localhost:11434/api/tags &> /dev/null; then
  check_pass "Ollama tags endpoint accessible"
else
  check_warn "Ollama tags endpoint not accessible (models may still be downloading)"
fi

echo ""
echo "🤖 Model Status"
echo "━━━━━━━━━━━━━━━━"

# Check for models
if command -v ollama &> /dev/null; then
  MODELS=$(ollama list 2>/dev/null | tail -n +2 || echo "")

  if echo "$MODELS" | grep -q "qwen2.5-coder:32b"; then
    check_pass "qwen2.5-coder:32b is installed"
  else
    check_warn "qwen2.5-coder:32b not found (may still be downloading)"
  fi

  if echo "$MODELS" | grep -q "llama3.3:70b"; then
    check_pass "llama3.3:70b is installed"
  else
    check_warn "llama3.3:70b not found (may still be downloading)"
  fi

  # Count total models
  MODEL_COUNT=$(echo "$MODELS" | grep -v "^$" | wc -l | tr -d ' ')
  echo "   Total models: $MODEL_COUNT"
fi

echo ""
echo "⚙️  Configuration"
echo "━━━━━━━━━━━━━━━━━"

# Check environment variables (from launchd plist)
PLIST="/Library/LaunchDaemons/com.ollama.ollama.plist"
if [ -f "$PLIST" ]; then
  check_pass "LaunchDaemon plist exists"

  # Check for OLLAMA_NUM_PARALLEL
  if grep -q "OLLAMA_NUM_PARALLEL" "$PLIST"; then
    PARALLEL=$(grep -A1 "OLLAMA_NUM_PARALLEL" "$PLIST" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
    check_pass "OLLAMA_NUM_PARALLEL set to $PARALLEL"
  else
    check_warn "OLLAMA_NUM_PARALLEL not configured"
  fi

  # Check for OLLAMA_KEEP_ALIVE
  if grep -q "OLLAMA_KEEP_ALIVE" "$PLIST"; then
    KEEP_ALIVE=$(grep -A1 "OLLAMA_KEEP_ALIVE" "$PLIST" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
    check_pass "OLLAMA_KEEP_ALIVE set to $KEEP_ALIVE"
  else
    check_warn "OLLAMA_KEEP_ALIVE not configured"
  fi
else
  check_warn "LaunchDaemon plist not found at $PLIST"
fi

# Check log directory
if [ -d "/var/log/ollama" ]; then
  check_pass "Log directory exists (/var/log/ollama)"

  # Check for recent logs
  if [ -f "/var/log/ollama/stdout.log" ]; then
    LOG_SIZE=$(du -h /var/log/ollama/stdout.log | cut -f1)
    echo "   stdout.log size: $LOG_SIZE"
  fi

  if [ -f "/var/log/ollama/stderr.log" ]; then
    LOG_SIZE=$(du -h /var/log/ollama/stderr.log | cut -f1)
    echo "   stderr.log size: $LOG_SIZE"
  fi
else
  check_warn "Log directory not found"
fi

# Check models directory
if [ -d "/var/lib/ollama/models" ]; then
  check_pass "Models directory exists"

  MODELS_SIZE=$(du -sh /var/lib/ollama/models 2>/dev/null | cut -f1)
  echo "   Models storage: $MODELS_SIZE"
else
  check_warn "Models directory not found (may not be created yet)"
fi

echo ""
echo "🧪 Inference Test"
echo "━━━━━━━━━━━━━━━━━"

# Only test if API is responding and at least one model exists
if curl -s -f http://localhost:11434/api/tags &> /dev/null; then
  AVAILABLE_MODELS=$(curl -s http://localhost:11434/api/tags 2>/dev/null | grep -o '"name":"[^"]*"' | cut -d'"' -f4)

  if [ -n "$AVAILABLE_MODELS" ]; then
    # Pick first available model
    TEST_MODEL=$(echo "$AVAILABLE_MODELS" | head -1)

    echo "Testing inference with model: $TEST_MODEL"

    # Quick inference test (with timeout)
    RESPONSE=$(curl -s -m 30 http://localhost:11434/api/generate -d "{
      \"model\": \"$TEST_MODEL\",
      \"prompt\": \"Say 'hello' in one word\",
      \"stream\": false
    }" 2>/dev/null | grep -o '"response":"[^"]*"' | cut -d'"' -f4)

    if [ -n "$RESPONSE" ]; then
      check_pass "Inference test successful"
      echo "   Response: $RESPONSE"
    else
      check_warn "Inference test timed out (model may be loading)"
    fi
  else
    check_warn "No models available for testing yet"
  fi
else
  check_warn "Skipping inference test (API not ready)"
fi

echo ""
echo "💾 Resource Usage"
echo "━━━━━━━━━━━━━━━━━"

# Get memory info
TOTAL_RAM=$(sysctl -n hw.memsize | awk '{print $0/1024/1024/1024}')
echo "Total RAM: ${TOTAL_RAM}GB"

# Check for Ollama process
if pgrep -q ollama; then
  OLLAMA_PID=$(pgrep ollama)
  OLLAMA_MEM=$(ps -o rss= -p "$OLLAMA_PID" | awk '{print $1/1024/1024}')
  echo "Ollama memory usage: ${OLLAMA_MEM}GB"

  if (( $(echo "$TOTAL_RAM > 64" | bc -l) )); then
    check_pass "Sufficient RAM for large models (${TOTAL_RAM}GB)"
  elif (( $(echo "$TOTAL_RAM > 32" | bc -l) )); then
    check_warn "RAM may be tight for 70B model (${TOTAL_RAM}GB, recommend 64GB+)"
  else
    check_warn "Low RAM for configured models (${TOTAL_RAM}GB, 70B model needs ~50GB)"
  fi
fi

echo ""
echo "📊 Summary"
echo "━━━━━━━━━━"
echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC}   $FAILED"

echo ""

if [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}✨ Ollama configuration is working!${NC}"
  echo ""
  echo "Next steps:"
  echo "  • Test: ollama run qwen2.5-coder:32b 'Hello, write a function'"
  echo "  • API: curl http://localhost:11434/api/generate -d '{\"model\":\"qwen2.5-coder:32b\",\"prompt\":\"test\"}'"
  echo "  • Logs: tail -f /var/log/ollama/stdout.log"
  echo "  • Docs: See docs/OLLAMA_SETUP.md"
  exit 0
else
  echo -e "${RED}❌ Ollama configuration has issues${NC}"
  echo ""
  echo "Troubleshooting:"
  echo "  • Check logs: cat /var/log/ollama/stderr.log"
  echo "  • Restart service: sudo launchctl kickstart -k system/com.ollama.ollama"
  echo "  • Rebuild: darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook"
  echo "  • Docs: See docs/OLLAMA_SETUP.md"
  exit 1
fi
