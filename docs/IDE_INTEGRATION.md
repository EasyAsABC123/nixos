# IDE Integration with Ollama

Complete guide to integrating your local Ollama models with VS Code, Cursor, and other IDEs.

## 🎯 Overview

Your Ollama configuration includes:
- **Chat Model**: `llama3.3:70b` (deep reasoning)
- **Autocomplete Model**: `qwen2.5-coder:32b` (fast completions)
- **Embeddings Model**: `nomic-embed-text` (semantic search)

All accessible at: `http://localhost:11434`

## 📦 Configuration Files

Pre-configured files are included in this repository:

```
configs/
├── continue/
│   └── config.json          # Continue.dev configuration
└── vscode/
    └── ollama-settings.json # VS Code settings
```

## 🚀 VS Code with Continue.dev (Recommended)

### Installation

1. **Install Continue Extension**
   ```bash
   code --install-extension continue.continue
   ```

2. **Copy Configuration**
   ```bash
   # Create Continue config directory
   mkdir -p ~/.continue

   # Copy pre-configured settings
   cp ~/github/nixos/configs/continue/config.json ~/.continue/config.json
   ```

3. **Restart VS Code**

### Features Enabled

✅ **Tab Autocomplete** - Powered by `qwen2.5-coder:32b`
- Lightning-fast inline suggestions
- Context-aware completions
- Multi-line suggestions

✅ **Chat Interface** - Powered by `llama3.3:70b`
- Deep reasoning for architecture decisions
- Code reviews and refactoring
- 5-minute timeout for complex queries

✅ **Embeddings** - Powered by `nomic-embed-text`
- Semantic codebase search
- Intelligent context retrieval
- RAG (Retrieval Augmented Generation)

✅ **Custom Commands**
- `/test` - Generate test suites
- `/refactor` - Improve code quality
- `/docs` - Write documentation
- `/review` - Comprehensive code review
- `/explain` - Explain complex code

### Usage

**Tab Autocomplete:**
```typescript
// Start typing, suggestions appear automatically
function quicksort(arr: number[]) {
  // Tab to accept suggestion
}
```

**Chat Interface:**
```
Cmd/Ctrl + L → Open Continue chat
@codebase How does authentication work?
```

**Quick Commands:**
```
1. Select code
2. Cmd/Ctrl + L
3. Type /test (or /refactor, /review, etc.)
```

## 🖥️ Cursor (Alternative to VS Code)

### Setup

1. **Open Cursor Settings** → Models

2. **Add Ollama Provider**
   ```
   Provider: Ollama
   Base URL: http://localhost:11434
   ```

3. **Configure Models**

   **Primary (Chat):**
   ```
   Model: llama3.3:70b
   Name: Llama 70B Deep Reasoning
   ```

   **Fast (Autocomplete):**
   ```
   Model: qwen2.5-coder:32b
   Name: Qwen Coder Fast
   ```

4. **Enable Features**
   - ✅ Copilot++ (Tab autocomplete)
   - ✅ Cmd+K (Inline editing)
   - ✅ Cmd+L (Chat)

### Cursor-Specific Features

**Cmd+K (Inline Edit):**
```python
# Highlight code, press Cmd+K
def slow_function():
    # Type: "optimize this function"
    # Cursor will rewrite using qwen2.5-coder:32b
```

**Composer (Multi-file editing):**
```
Cmd+Shift+L → Open Composer
"Refactor authentication to use OAuth 2.0"
# Works across multiple files with llama3.3:70b
```

## 🔌 Other IDE Extensions

### Cody by Sourcegraph

**Installation:**
```bash
code --install-extension sourcegraph.cody-ai
```

**Configuration** (add to `settings.json`):
```json
{
  "cody.serverEndpoint": "http://localhost:11434",
  "cody.autocomplete.enabled": true,
  "cody.autocomplete.advanced.provider": "ollama",
  "cody.autocomplete.advanced.model": "qwen2.5-coder:32b"
}
```

### CodeGPT

**Installation:**
```bash
code --install-extension danielsanmedium.dscodegpt
```

**Configuration:**
```json
{
  "codegpt.provider": "Ollama",
  "codegpt.model": "qwen2.5-coder:32b",
  "codegpt.ollamaApiUrl": "http://localhost:11434",
  "codegpt.maxTokens": 2048,
  "codegpt.temperature": 0.3
}
```

### Tabby (Self-hosted Copilot Alternative)

**Installation:**
```bash
# Install Tabby extension
code --install-extension TabbyML.vscode-tabby
```

**Configuration:**
Point Tabby to your Ollama endpoint as a custom completion server.

## ⚙️ VS Code Settings

Copy the pre-configured settings:

```bash
# Backup existing settings
cp ~/.config/Code/User/settings.json ~/.config/Code/User/settings.json.backup

# Merge Ollama settings
cat ~/github/nixos/configs/vscode/ollama-settings.json >> ~/.config/Code/User/settings.json
```

Or manually add these key settings:

```json
{
  "continue.telemetryEnabled": false,
  "continue.enableTabAutocomplete": true,
  "editor.inlineSuggest.enabled": true,
  "editor.quickSuggestions": {
    "other": true,
    "comments": false,
    "strings": true
  }
}
```

## 🎨 Workflow Examples

### Example 1: Full-Stack Development

**Terminal (Code Review):**
```bash
git diff | ollama run llama3.3:70b "Review these changes"
```

**VS Code (Autocomplete):**
- Tab completions from `qwen2.5-coder:32b`
- Inline suggestions as you type

**Browser (Documentation):**
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.3:70b",
  "prompt": "Explain the architecture of this project",
  "stream": false
}'
```

### Example 2: Refactoring Session

1. **Identify code** - Select function in VS Code
2. **Open Continue** - Cmd/Ctrl + L
3. **Run command** - `/refactor`
4. **Review suggestion** - From `llama3.3:70b`
5. **Apply changes** - One-click accept

### Example 3: Test Generation

```typescript
// 1. Write function
function calculateTax(amount: number, rate: number): number {
  return amount * rate;
}

// 2. Select function, Cmd+L, type /test
// 3. Continue generates comprehensive test suite:

describe('calculateTax', () => {
  it('should calculate tax correctly', () => {
    expect(calculateTax(100, 0.1)).toBe(10);
  });

  it('should handle zero amount', () => {
    expect(calculateTax(0, 0.1)).toBe(0);
  });

  it('should handle zero rate', () => {
    expect(calculateTax(100, 0)).toBe(0);
  });

  it('should handle negative amounts', () => {
    expect(() => calculateTax(-100, 0.1)).toThrow();
  });
});
```

## 🔧 Advanced Configuration

### Continue.dev Custom Models

Edit `~/.continue/config.json`:

```json
{
  "models": [
    {
      "title": "Llama 3.3 70B (Chat)",
      "provider": "ollama",
      "model": "llama3.3:70b",
      "requestOptions": {
        "timeout": 300000  // 5 min for deep reasoning
      }
    },
    {
      "title": "DeepSeek 236B (Ultimate)",
      "provider": "ollama",
      "model": "deepseek-coder-v2:236b",
      "requestOptions": {
        "timeout": 600000  // 10 min for massive model
      }
    }
  ]
}
```

### Model Roles (Continue.dev)

Assign specific models to specific tasks:

```json
{
  "experimental": {
    "modelRoles": {
      "inlineEdit": "qwen2.5-coder:32b",      // Fast edits
      "applyCodeBlock": "qwen2.5-coder:32b",  // Code application
      "summarize": "llama3.3:70b",            // Summarization
      "repoMapFileSelection": "qwen2.5-coder:32b"  // File selection
    }
  }
}
```

### Context Providers

Enable different context sources:

```json
{
  "contextProviders": [
    {"name": "code"},       // Current file
    {"name": "diff"},       // Git diff
    {"name": "terminal"},   // Terminal output
    {"name": "problems"},   // Errors/warnings
    {"name": "folder"},     // File tree
    {"name": "codebase"}    // Semantic search with embeddings
  ]
}
```

## 📊 Performance Tuning

### Autocomplete Speed

**For faster autocomplete** (edit `~/.continue/config.json`):

```json
{
  "tabAutocompleteModel": {
    "model": "qwen2.5:7b",  // Smaller, faster model
    "provider": "ollama"
  }
}
```

**Trade-off:** Less context awareness, but sub-50ms latency

### Chat Response Time

**For faster chat** (less deep reasoning):

```json
{
  "models": [
    {
      "title": "Qwen 32B (Fast Chat)",
      "model": "qwen2.5:32b",
      "requestOptions": {
        "temperature": 0.3,  // More focused
        "num_predict": 512   // Shorter responses
      }
    }
  ]
}
```

## 🐛 Troubleshooting

### Autocomplete Not Working

**Check Ollama service:**
```bash
curl http://localhost:11434/api/tags
# Should return model list
```

**Check Continue logs:**
```
VS Code → Output → Continue
```

**Verify model is loaded:**
```bash
ollama list | grep qwen2.5-coder:32b
```

### Slow Responses

**Check model is warm:**
```bash
# Pre-warm models
ollama run qwen2.5-coder:32b ""
ollama run llama3.3:70b ""
```

**Check CPU/GPU usage:**
```bash
# Should see Ollama using GPU
sudo powermetrics --samplers gpu_power -i 1000
```

**Increase timeout** in `config.json`:
```json
{
  "requestOptions": {
    "timeout": 600000  // 10 minutes
  }
}
```

### Extension Conflicts

**Disable conflicting extensions:**
- GitHub Copilot (if using Continue)
- IntelliCode
- Tabnine

**Or configure priority:**
```json
{
  "continue.enableTabAutocomplete": true,
  "github.copilot.enable": {
    "*": false  // Disable Copilot
  }
}
```

### Embeddings Not Working

**Verify nomic-embed-text is installed:**
```bash
ollama list | grep nomic-embed-text
```

**If missing, install:**
```bash
ollama pull nomic-embed-text
```

**Restart Continue extension:**
```
VS Code → Reload Window
```

## 🎯 Recommended Setup

### For Maximum Productivity

**Primary Model:** `llama3.3:70b`
- Deep reasoning
- Code reviews
- Architecture discussions
- 300-second timeout

**Autocomplete:** `qwen2.5-coder:32b`
- Fast inline suggestions
- Context-aware completions
- <100ms latency

**Embeddings:** `nomic-embed-text`
- Codebase search
- Smart context retrieval
- Minimal overhead

### For Speed-Focused Workflow

**Primary Model:** `qwen2.5-coder:32b`
- Fast responses
- Good code quality
- 120-second timeout

**Autocomplete:** `qwen2.5:7b`
- Ultra-fast suggestions
- Lower memory usage
- <50ms latency

**Embeddings:** `nomic-embed-text`
- Same as above

## 🔗 Additional Resources

- [Continue.dev Documentation](https://continue.dev/docs)
- [Cursor Documentation](https://cursor.sh/docs)
- [Ollama API Reference](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [VS Code Extension Marketplace](https://marketplace.visualstudio.com/)

## 📋 Quick Reference

**Continue.dev Config:** `~/.continue/config.json`  
**VS Code Settings:** `~/.config/Code/User/settings.json`  
**Ollama API:** `http://localhost:11434`  
**Test Connection:** `curl http://localhost:11434/api/tags`

**Models:**
- Chat: `llama3.3:70b`
- Autocomplete: `qwen2.5-coder:32b`
- Embeddings: `nomic-embed-text`

---

**Pre-configured files:** `configs/continue/` and `configs/vscode/`  
**Install:** Copy configs to respective directories  
**Verify:** Check Continue Output panel in VS Code
