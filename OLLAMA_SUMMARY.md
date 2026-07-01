# Ollama Configuration Summary

## ✨ What Was Added

A complete Ollama LLM service configuration for local AI-powered coding assistance on your Apple Silicon Mac.

## 📁 Files Created

```
modules/
└── ollama.nix                    # Ollama service configuration module

docs/
└── OLLAMA_SETUP.md               # Complete Ollama documentation

scripts/
└── test-ollama.sh                # Service verification script
```

## 🎯 Configuration Details

### Service Configuration (`modules/ollama.nix`)

```nix
services.ollama = {
  enable = true;
  acceleration = null;  # Uses Metal framework (Apple Silicon GPU)

  models = [
    "qwen2.5-coder:32b"  # ~19GB - Code generation
    "llama3.3:70b"       # ~40GB - General reasoning
  ];

  environmentVariables = {
    OLLAMA_NUM_PARALLEL = "4";    # 4 concurrent instances
    OLLAMA_KEEP_ALIVE = "24h";    # Keep models loaded
  };
};
```

### LaunchDaemon Optimization

- **Priority**: Nice=-10 (higher priority for responsive inference)
- **Keep Alive**: Automatic restart on failure
- **Process Type**: Interactive (better resource allocation)
- **Logging**: `/var/log/ollama/` (stdout.log, stderr.log)

## 🚀 Quick Start

### 1. Rebuild System

```bash
cd ~/github/nixos
darwin-rebuild switch --flake .#jschuhmann-macbook
```

**This will:**
- Install Ollama service
- Start downloading models (10-30 minutes)
- Configure LaunchDaemon
- Set up logging directory

### 2. Verify Installation

```bash
# Run verification script
./scripts/test-ollama.sh

# Or manually check
launchctl list | grep ollama
curl http://localhost:11434/api/tags
ollama list
```

### 3. Test Inference

```bash
# Interactive chat
ollama run qwen2.5-coder:32b

# One-shot generation
ollama run qwen2.5-coder:32b "Write a Python function to parse JSON"

# API test
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:32b",
  "prompt": "Write a quicksort in Rust",
  "stream": false
}'
```

## 💾 Resource Requirements

| Component | Storage | RAM (Active) |
|-----------|---------|--------------|
| qwen2.5-coder:32b | ~19GB | ~24GB |
| llama3.3:70b | ~40GB | ~50GB |
| **Total** | **~59GB** | **~74GB** |

**Recommended Hardware:**
- Apple Silicon (M1/M2/M3 Max or Ultra)
- 64GB+ unified memory
- 100GB+ free storage

## 🔧 Configuration Options

### Add More Models

Edit `modules/ollama.nix`:

```nix
models = [
  "qwen2.5-coder:32b"
  "llama3.3:70b"
  "codellama:34b"        # Add this
  "mistral:7b-instruct"  # Lightweight option
];
```

### Adjust Performance

```nix
environmentVariables = {
  OLLAMA_NUM_PARALLEL = "8";     # More parallel (if >128GB RAM)
  OLLAMA_KEEP_ALIVE = "10m";     # Shorter keep-alive
  OLLAMA_NUM_GPU = "99";         # Force max GPU offload
};
```

### Enable Network Access

```nix
environmentVariables = {
  OLLAMA_HOST = "0.0.0.0:11434";  # Bind to all interfaces
};
```

## 📊 Performance Expectations

### Apple Silicon M1/M2/M3 Max (32-64GB)
- **qwen2.5-coder:32b**: ~20-30 tokens/sec
- **llama3.3:70b**: ~8-15 tokens/sec
- **Cold start**: 5-10 seconds
- **Warm (24h keep-alive)**: <100ms latency

### Apple Silicon Ultra (64-192GB)
- **qwen2.5-coder:32b**: ~40-60 tokens/sec
- **llama3.3:70b**: ~20-30 tokens/sec
- **Parallel instances**: 4x simultaneous queries

## 🔍 Monitoring & Troubleshooting

### Check Service Status

```bash
# LaunchDaemon status
launchctl list com.ollama.ollama

# View logs
tail -f /var/log/ollama/stdout.log
tail -f /var/log/ollama/stderr.log

# Check download progress
grep -i "pulling" /var/log/ollama/stdout.log
```

### Common Issues

**Service not starting:**
```bash
sudo launchctl kickstart -k system/com.ollama.ollama
cat /var/log/ollama/stderr.log
```

**Models not downloading:**
```bash
# Manual download
ollama pull qwen2.5-coder:32b
ollama pull llama3.3:70b
```

**High memory usage:**
```bash
# Check active models
curl http://localhost:11434/api/tags

# Reduce keep-alive in modules/ollama.nix:
# OLLAMA_KEEP_ALIVE = "10m"
```

## 🎨 Integration Examples

### VS Code (Continue)

```json
{
  "continue.modelProvider": "ollama",
  "continue.ollamaUrl": "http://localhost:11434",
  "continue.model": "qwen2.5-coder:32b"
}
```

### Python

```python
import requests

def query_ollama(prompt, model="qwen2.5-coder:32b"):
    response = requests.post(
        "http://localhost:11434/api/generate",
        json={"model": model, "prompt": prompt, "stream": False}
    )
    return response.json()["response"]

code = query_ollama("Write a binary search in Python")
```

### Command Line

```bash
# Code generation
ollama run qwen2.5-coder:32b "Write a Dockerfile for a Node.js app"

# Code review
cat script.py | ollama run qwen2.5-coder:32b "Review for bugs"

# Generate tests
cat function.go | ollama run qwen2.5-coder:32b "Generate unit tests"
```

## 📚 Documentation

**Complete Guide**: [docs/OLLAMA_SETUP.md](docs/OLLAMA_SETUP.md)

Covers:
- Detailed installation steps
- Model management
- Performance tuning
- API reference
- Troubleshooting guide
- Security considerations
- Integration examples

## 🔄 Updates & Maintenance

### Update Models

```bash
ollama pull qwen2.5-coder:32b
ollama pull llama3.3:70b
```

### Update Ollama Service

```bash
cd ~/github/nixos
nix flake update
darwin-rebuild switch --flake .#jschuhmann-macbook
```

### Remove Models

```bash
# Free up disk space
ollama rm mistral:7b-instruct
```

## 🔒 Security Notes

- **Default**: Binds to 127.0.0.1 (localhost only)
- **No Auth**: Ollama API has no built-in authentication
- **Local Only**: All inference happens on your Mac
- **Logs**: Prompts/responses logged to `/var/log/ollama/`

## ✅ Verification Checklist

After rebuild, verify:

- ✅ `launchctl list | grep ollama` shows service
- ✅ `curl http://localhost:11434/api/tags` returns JSON
- ✅ `ollama list` shows both models (after download completes)
- ✅ `ollama run qwen2.5-coder:32b "test"` generates response
- ✅ Models directory exists: `ls /var/lib/ollama/models/`
- ✅ Logs are being written: `tail /var/log/ollama/stdout.log`

## 🎯 Next Steps

1. **Rebuild system** to install Ollama
2. **Wait for model downloads** (10-30 minutes)
3. **Run test script**: `./scripts/test-ollama.sh`
4. **Try inference**: `ollama run qwen2.5-coder:32b "Hello"`
5. **Integrate with editor** (VS Code, Cursor, etc.)
6. **Read full docs**: [docs/OLLAMA_SETUP.md](docs/OLLAMA_SETUP.md)

---

**Module**: `modules/ollama.nix`  
**API Endpoint**: `http://127.0.0.1:11434`  
**Models**: qwen2.5-coder:32b, llama3.3:70b  
**RAM Required**: 74GB (both models active)  
**Storage**: ~59GB
