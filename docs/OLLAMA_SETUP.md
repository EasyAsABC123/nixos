# Ollama LLM Service Configuration

This system includes Ollama, a local LLM inference engine optimized for Apple Silicon, running as a system daemon.

## 🎯 What's Configured

### Service Configuration
- **Ollama Daemon**: Runs as a system service via `launchd`
- **Acceleration**: Native Metal framework (Apple Silicon GPU acceleration)
- **Auto-loaded Models**: 
  - `qwen2.5-coder:32b` (~19GB) - Excellent for code generation
  - `llama3.3:70b` (~40GB) - Strong general reasoning and coding

### Performance Optimization
- **OLLAMA_NUM_PARALLEL = 4**: Allows 4 concurrent model instances
- **OLLAMA_KEEP_ALIVE = 24h**: Keeps models in memory for instant inference
- **LaunchDaemon Priority**: Runs with Nice=-10 for responsive performance

### Storage & Network
- **Models Directory**: `/var/lib/ollama/models/`
- **API Endpoint**: `http://127.0.0.1:11434` (localhost only)
- **Logs**: `/var/log/ollama/` (stdout.log, stderr.log)

## 📦 Model Details

| Model | Size | RAM Usage | Use Case |
|-------|------|-----------|----------|
| `qwen2.5-coder:32b` | ~19GB | ~24GB | Code generation, refactoring, explanation |
| `llama3.3:70b` | ~40GB | ~50GB | General reasoning, architecture design, docs |

**Total RAM Required**: ~74GB (recommended: 64GB+ unified memory)

## 🚀 Quick Start

### First Time Setup

After rebuilding your system, models will auto-download:

```bash
# Rebuild system (this triggers model downloads)
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook

# Monitor download progress (runs in background)
tail -f /var/log/ollama/stdout.log

# Check service status
launchctl list | grep ollama
```

**Note**: Initial model downloads take 10-30 minutes depending on internet speed.

### Verify Installation

```bash
# Check Ollama service is running
launchctl list com.ollama.ollama
# Should show PID and status

# Test API endpoint
curl http://localhost:11434/api/tags
# Should return JSON with model list

# List available models
ollama list
# Should show:
# qwen2.5-coder:32b
# llama3.3:70b
```

## 💻 Using Ollama

### Command Line Interface

```bash
# Start interactive chat with Qwen Coder
ollama run qwen2.5-coder:32b

# Start interactive chat with Llama 3.3
ollama run llama3.3:70b

# One-shot code generation
ollama run qwen2.5-coder:32b "Write a Python function to parse JSON"

# Pipe input for batch processing
echo "Explain this code: $(cat script.py)" | ollama run qwen2.5-coder:32b
```

### REST API

```bash
# Generate completion
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:32b",
  "prompt": "Write a quicksort in Rust",
  "stream": false
}'

# Chat completion
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.3:70b",
  "messages": [
    {"role": "user", "content": "Explain closures in JavaScript"}
  ],
  "stream": false
}'

# List loaded models
curl http://localhost:11434/api/tags
```

### Integration Examples

**With VS Code (Continue extension):**

```json
// settings.json
{
  "continue.modelProvider": "ollama",
  "continue.ollamaUrl": "http://localhost:11434",
  "continue.model": "qwen2.5-coder:32b"
}
```

**With Cursor:**

```
Settings → Models → Add Model
- Provider: Ollama
- URL: http://localhost:11434
- Model: qwen2.5-coder:32b
```

**With Python:**

```python
import requests

def query_ollama(prompt, model="qwen2.5-coder:32b"):
    response = requests.post(
        "http://localhost:11434/api/generate",
        json={"model": model, "prompt": prompt, "stream": False}
    )
    return response.json()["response"]

# Example usage
code = query_ollama("Write a binary search function in Python")
print(code)
```

## 🔧 Configuration

### Change Models

Edit `modules/ollama.nix`:

```nix
models = [
  "qwen2.5-coder:32b"
  "llama3.3:70b"
  "codellama:34b"        # Add new model
  "mistral:7b-instruct"  # Lightweight option
];
```

Then rebuild:
```bash
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook
```

### Adjust Performance Settings

Edit `modules/ollama.nix`:

```nix
environmentVariables = {
  # Increase parallel instances (if you have >128GB RAM)
  OLLAMA_NUM_PARALLEL = "8";

  # Reduce keep-alive (if RAM is constrained)
  OLLAMA_KEEP_ALIVE = "10m";

  # Force max GPU offload
  OLLAMA_NUM_GPU = "99";
};
```

### Enable Network Access

To allow other devices on your network to use Ollama:

Edit `modules/ollama.nix`:

```nix
environmentVariables = {
  # ... existing vars ...
  OLLAMA_HOST = "0.0.0.0:11434";  # Bind to all interfaces
};
```

Uncomment firewall rule:
```nix
networking.firewall.allowedTCPPorts = [ 11434 ];
```

**Security Warning**: Only enable network access on trusted networks.

## 📊 Monitoring & Management

### Check Service Status

```bash
# LaunchDaemon status
launchctl list com.ollama.ollama

# Process info
ps aux | grep ollama

# Resource usage
top | grep ollama
```

### View Logs

```bash
# Live log streaming
tail -f /var/log/ollama/stdout.log

# Error logs
tail -f /var/log/ollama/stderr.log

# Check for errors
grep -i error /var/log/ollama/*.log
```

### Model Management

```bash
# List all models
ollama list

# Show model info
ollama show qwen2.5-coder:32b

# Remove a model (saves disk space)
ollama rm mistral:7b-instruct

# Pull a new model manually
ollama pull deepseek-coder:33b

# Update existing models
ollama pull qwen2.5-coder:32b
ollama pull llama3.3:70b
```

### Performance Tuning

```bash
# Check model load time
time ollama run qwen2.5-coder:32b "hello" --verbose

# Monitor memory usage during inference
sudo memory_pressure
```

## 🐛 Troubleshooting

### Service Not Starting

```bash
# Check LaunchDaemon status
launchctl list | grep ollama

# View error logs
cat /var/log/ollama/stderr.log

# Restart service manually
sudo launchctl kickstart -k system/com.ollama.ollama

# Verify Ollama binary exists
which ollama
ls -la /nix/store/*ollama*/bin/ollama
```

### Models Not Downloading

```bash
# Check download progress
tail -f /var/log/ollama/stdout.log

# Verify network connectivity
curl -I https://registry.ollama.ai

# Check disk space
df -h /var/lib/ollama

# Manual download
ollama pull qwen2.5-coder:32b
ollama pull llama3.3:70b
```

### High Memory Usage

```bash
# Check active models
curl http://localhost:11434/api/tags

# Reduce keep-alive time
# Edit modules/ollama.nix:
# OLLAMA_KEEP_ALIVE = "10m"

# Force unload models
sudo launchctl stop com.ollama.ollama
sudo launchctl start com.ollama.ollama
```

### Slow Inference

**Verify Metal acceleration:**
```bash
# Check GPU usage during inference
sudo powermetrics --samplers gpu_power -i 1000

# Ensure OLLAMA_NUM_GPU is set (check logs)
grep OLLAMA_NUM_GPU /var/log/ollama/stdout.log
```

**Optimize for your hardware:**
```nix
# For M1/M2 (8-10 GPU cores)
OLLAMA_NUM_GPU = "99";  # Max offload

# For M1/M2 Ultra (48-76 GPU cores)
OLLAMA_NUM_PARALLEL = "4";  # More parallel instances

# For memory-constrained systems
OLLAMA_KEEP_ALIVE = "5m";  # Shorter keep-alive
```

### API Connection Refused

```bash
# Check if service is running
launchctl list com.ollama.ollama

# Test API endpoint
curl -v http://localhost:11434/api/version

# Check for port conflicts
lsof -i :11434

# Verify listen address
ps aux | grep ollama | grep -o '127.0.0.1:11434'
```

## 🎨 Common Use Cases

### Code Generation & Review

```bash
# Generate function
ollama run qwen2.5-coder:32b "Write a TypeScript function for debouncing"

# Code review
cat mycode.py | ollama run qwen2.5-coder:32b "Review this code for bugs and suggest improvements"

# Refactor
cat legacy.js | ollama run qwen2.5-coder:32b "Refactor to modern ES6+ syntax"

# Generate tests
cat function.go | ollama run qwen2.5-coder:32b "Generate unit tests using testify"
```

### Documentation & Explanation

```bash
# Explain codebase
ollama run llama3.3:70b "Explain the architecture in this README: $(cat README.md)"

# Generate docs
cat api.py | ollama run qwen2.5-coder:32b "Generate docstrings for all functions"

# Create tutorial
ollama run llama3.3:70b "Write a beginner tutorial for React hooks"
```

### Multi-File Analysis

```bash
# Analyze relationships (leverages OLLAMA_NUM_PARALLEL=4)
for file in src/*.ts; do
  echo "=== $file ===" >> analysis.txt
  cat "$file" | ollama run qwen2.5-coder:32b "Analyze dependencies" >> analysis.txt &
done
wait
cat analysis.txt
```

### Interactive Development

```bash
# Start coding session
ollama run qwen2.5-coder:32b

# Example prompts:
# > I have a REST API in Go. How do I add rate limiting?
# > Show me an example of Go generics
# > Explain the difference between defer and panic
```

## 📈 Performance Benchmarks

**M1/M2/M3 Max (32-64GB RAM):**
- Qwen 2.5 Coder 32B: ~20-30 tokens/sec
- Llama 3.3 70B: ~8-15 tokens/sec
- Cold start (first query): 5-10 seconds
- Warm (24h keep-alive): <100ms latency

**M1/M2/M3 Ultra (64-192GB RAM):**
- Qwen 2.5 Coder 32B: ~40-60 tokens/sec
- Llama 3.3 70B: ~20-30 tokens/sec
- Parallel instances: 4x simultaneous queries

## 🔒 Security Considerations

1. **Localhost Only**: Default config binds to 127.0.0.1 (local access only)
2. **No Authentication**: Ollama API has no built-in auth (use firewall rules)
3. **Model Safety**: Models run locally, no data sent to external servers
4. **Log Privacy**: Prompts/responses logged to `/var/log/ollama/`

**Production Recommendations:**
- Keep `OLLAMA_HOST = "127.0.0.1:11434"` (default)
- Add reverse proxy (nginx) with authentication if network access needed
- Rotate logs regularly to prevent disk fill
- Review `/var/log/ollama/` for sensitive data before sharing

## 📚 Additional Resources

- [Ollama Official Docs](https://github.com/ollama/ollama/blob/main/docs/README.md)
- [Ollama API Reference](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Model Library](https://ollama.com/library)
- [Qwen 2.5 Coder](https://ollama.com/library/qwen2.5-coder)
- [Llama 3.3](https://ollama.com/library/llama3.3)

## 🔄 Updating

### Update Models

```bash
# Pull latest versions
ollama pull qwen2.5-coder:32b
ollama pull llama3.3:70b

# Or rebuild system (auto-updates via loadModels)
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook
```

### Update Ollama Service

```bash
# Update nixpkgs
cd ~/github/nixos
nix flake update

# Rebuild (gets latest Ollama version)
darwin-rebuild switch --flake .#jschuhmann-macbook
```

---

**Configuration File**: `modules/ollama.nix`  
**Service Name**: `com.ollama.ollama`  
**API Endpoint**: `http://127.0.0.1:11434`  
**Models Location**: `/var/lib/ollama/models/`
