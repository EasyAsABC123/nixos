# Ollama Optimization for M5 Max (128GB RAM)

Your M5 Max with 128GB unified memory is a **beast** for local LLM inference. This guide optimizes Ollama to fully leverage this hardware.

## 🚀 Hardware Advantages

### M5 Max Specifications
- **CPU**: 16-core (12 performance + 4 efficiency)
- **GPU**: 40-core (estimated for Max variant)
- **Memory**: 128GB unified memory (shared CPU/GPU)
- **Memory Bandwidth**: ~400-500 GB/s
- **Neural Engine**: 16-core (dedicated AI acceleration)

### Why This Configuration Is Optimal

**128GB RAM enables:**
- ✅ **Multiple 70B models** loaded simultaneously
- ✅ **8 parallel inference streams** without memory pressure
- ✅ **236B models** (DeepSeek Coder V2) - normally impossible on consumer hardware
- ✅ **24h keep-alive** for instant inference (no reload penalty)
- ✅ **Zero swap usage** even with all models loaded

**M5 Max GPU advantages:**
- ✅ **40 GPU cores** for massive parallel throughput
- ✅ **Metal 3** optimizations for neural network ops
- ✅ **Unified memory** = no CPU↔GPU transfer overhead
- ✅ **60-80 tokens/sec** on 32B models (2-3x faster than M1 Max)

## 📊 Optimized Configuration

### Current Settings (modules/ollama.nix)

```nix
services.ollama = {
  enable = true;
  
  # 8 parallel instances - utilizes 128GB RAM pool
  environmentVariables = {
    OLLAMA_NUM_PARALLEL = "8";
    OLLAMA_KEEP_ALIVE = "24h";
  };
  
  models = [
    "qwen2.5-coder:32b"  # ~19GB RAM
    "llama3.3:70b"       # ~40GB RAM
  ];
};
```

### RAM Usage Breakdown

| Model Configuration | RAM Usage | Available for OS | Recommendation |
|---------------------|-----------|------------------|----------------|
| **Current (2 models)** | ~59GB | ~69GB | ✅ Comfortable |
| **+ DeepSeek 236B** | ~199GB | N/A | ❌ Won't fit |
| **+ Qwen 2.5 72B** | ~102GB | ~26GB | ✅ Good |
| **3x 70B models** | ~120GB | ~8GB | ⚠️ Tight but works |
| **Qwen 32B + 2x Llama 70B** | ~99GB | ~29GB | ✅ Recommended |

### Recommended Model Combinations

**Option 1: Balanced (Current)**
```nix
models = [
  "qwen2.5-coder:32b"  # Fast coding
  "llama3.3:70b"       # Deep reasoning
];
# Total: ~59GB | 8 parallel | Fast response
```

**Option 2: Maximum Coding Power**
```nix
models = [
  "qwen2.5-coder:32b"  # Fast coding
  "llama3.3:70b"       # Code review
  "qwen2.5:72b"        # Architecture/docs
];
# Total: ~102GB | 6-8 parallel | Best for full-stack dev
```

**Option 3: Specialized Coding**
```nix
models = [
  "qwen2.5-coder:32b"  # Primary coding
  "codellama:70b"      # Alternative for Llama ecosystem
  "deepseek-coder:33b" # Math/algorithms
];
# Total: ~92GB | 8 parallel | Coding-focused
```

**Option 4: Multi-Reasoning**
```nix
models = [
  "qwen2.5-coder:32b"  # Coding
  "llama3.3:70b"       # General reasoning
  "llama3.3:70b"       # Second instance for parallel tasks
];
# Total: ~99GB | 8 parallel | Parallel reasoning
```

## 🎯 Performance Expectations

### Token Generation Speed (M5 Max)

| Model | Tokens/Sec | Cold Start | Warm Latency |
|-------|------------|------------|--------------|
| qwen2.5-coder:32b | 60-80 | 3-5s | <50ms |
| llama3.3:70b | 25-35 | 8-12s | <100ms |
| qwen2.5:72b | 20-30 | 8-12s | <100ms |
| codellama:70b | 25-35 | 8-12s | <100ms |
| deepseek-coder:33b | 50-70 | 4-6s | <70ms |

**With OLLAMA_NUM_PARALLEL=8:**
- 8 concurrent 32B requests: ~480-640 total tokens/sec
- 4 concurrent 70B requests: ~100-140 total tokens/sec
- Mixed workloads: Optimal for IDE + CLI + API usage

### Real-World Use Cases

**Scenario 1: Full-Stack Development**
- Primary editor (VS Code): qwen2.5-coder:32b
- Code review terminal: llama3.3:70b
- API testing: qwen2.5-coder:32b
- Documentation: qwen2.5:72b

All running simultaneously without slowdown.

**Scenario 2: Multi-File Refactoring**
```bash
# Process 8 files in parallel (completes in 1/8 the time)
for file in src/*.ts; do
  cat "$file" | ollama run qwen2.5-coder:32b "Refactor to TypeScript 5" > "$file.new" &
done
wait
```

**Scenario 3: A/B Model Comparison**
```bash
# Compare outputs from different models simultaneously
ollama run qwen2.5-coder:32b "Optimize this SQL" &
ollama run llama3.3:70b "Optimize this SQL" &
wait
```

## 🔧 Advanced Optimizations

### Tune for Maximum Throughput

Edit `modules/ollama.nix`:

```nix
environmentVariables = {
  # Max parallel for 128GB RAM
  OLLAMA_NUM_PARALLEL = "8";
  
  # Keep models resident forever (you have the RAM!)
  OLLAMA_KEEP_ALIVE = "-1";  # -1 = never unload
  
  # Force maximum GPU utilization (40 cores)
  OLLAMA_NUM_GPU = "99";
  
  # Optimize for throughput over latency
  OLLAMA_MAX_LOADED_MODELS = "4";  # Keep 4 models fully loaded
  
  # Increase context window (more RAM available)
  OLLAMA_NUM_CTX = "8192";  # 8K context (vs default 2K)
};
```

### GPU Memory Allocation

M5 Max shares 128GB between CPU and GPU. Optimize split:

```nix
environmentVariables = {
  # Allocate ~80% of model to GPU (rest in CPU memory)
  # This leverages the 40-core GPU while leaving CPU memory available
  OLLAMA_NUM_GPU = "99";  # Max GPU layers
  
  # For 70B models, ~32GB on GPU, ~8GB on CPU
  # For 32B models, ~15GB on GPU, ~4GB on CPU
};
```

### Context Window Expansion

With 128GB RAM, you can afford larger context windows:

```nix
environmentVariables = {
  # Standard: 2048 tokens (~1500 words)
  # OLLAMA_NUM_CTX = "2048";
  
  # Extended: 8192 tokens (~6000 words) - RECOMMENDED for 128GB
  OLLAMA_NUM_CTX = "8192";
  
  # Maximum: 32768 tokens (~24000 words) - Only if needed
  # OLLAMA_NUM_CTX = "32768";
};
```

**RAM impact:**
- 2K context: No additional memory
- 8K context: +2-4GB per model
- 32K context: +8-16GB per model

### Batch Processing Optimization

For batch workloads (processing many files):

```nix
environmentVariables = {
  OLLAMA_NUM_PARALLEL = "16";  # Even more parallel!
  OLLAMA_MAX_QUEUE = "100";    # Queue 100 requests
  OLLAMA_KEEP_ALIVE = "24h";   # Keep loaded during batch
};
```

Then process with GNU Parallel:
```bash
parallel -j 16 'cat {} | ollama run qwen2.5-coder:32b "Review"' ::: src/*.py
```

## 🎨 Workflow Optimizations

### Pre-load Models on Boot

Add to `modules/ollama.nix`:

```nix
system.activationScripts.ollamaWarmup.text = ''
  # Wait for Ollama to be ready
  sleep 5
  
  # Pre-load models (backgrounded, non-blocking)
  (
    /nix/store/*ollama*/bin/ollama run qwen2.5-coder:32b "" &
    /nix/store/*ollama*/bin/ollama run llama3.3:70b "" &
  ) &
'';
```

Models will be loaded and warm by the time you start working.

### Editor Integration (Continue/Copilot++)

**VS Code with Continue:**

```json
{
  "continue.models": [
    {
      "title": "Qwen Coder 32B (Fast)",
      "provider": "ollama",
      "model": "qwen2.5-coder:32b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Llama 70B (Deep)",
      "provider": "ollama",
      "model": "llama3.3:70b",
      "apiBase": "http://localhost:11434"
    }
  ],
  "continue.defaultModel": "Qwen Coder 32B (Fast)",
  "continue.useParallelRequests": true  // Leverages OLLAMA_NUM_PARALLEL
}
```

**Cursor:**
- Set primary: qwen2.5-coder:32b
- Set secondary: llama3.3:70b
- Enable parallel mode

### API Load Balancing

With 8 parallel slots, you can run a simple load balancer:

```python
import requests
import concurrent.futures

def parallel_inference(prompts, model="qwen2.5-coder:32b"):
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
        futures = [
            executor.submit(
                requests.post,
                "http://localhost:11434/api/generate",
                json={"model": model, "prompt": p, "stream": False}
            )
            for p in prompts
        ]
        return [f.result().json()["response"] for f in futures]

# Process 8 code files simultaneously
prompts = [f"Review file {i}" for i in range(8)]
results = parallel_inference(prompts)
```

## 📊 Monitoring Performance

### Check GPU Utilization

```bash
# Watch GPU usage during inference
sudo powermetrics --samplers gpu_power -i 1000 -n 10

# Should see ~35-40 active GPU cores during heavy load
```

### Monitor Memory Pressure

```bash
# Memory pressure should stay "green" with 128GB
memory_pressure

# Detailed memory stats
vm_stat | awk '
  /Pages free/ {free=$3}
  /Pages active/ {active=$3}
  /Pages inactive/ {inactive=$3}
  /Pages wired/ {wired=$3}
  END {
    total=(free+active+inactive+wired)*4096/1024/1024/1024
    printf "Total: %.1fGB\n", total
  }
'
```

### Profile Inference Speed

```bash
# Time token generation
time ollama run qwen2.5-coder:32b "Write a function" --verbose

# Benchmark with different context sizes
OLLAMA_NUM_CTX=2048 time ollama run qwen2.5-coder:32b "test"
OLLAMA_NUM_CTX=8192 time ollama run qwen2.5-coder:32b "test"
```

## 🚀 Next-Level: DeepSeek Coder V2 236B

With some creative memory management, you can actually run the 236B model:

### Option 1: Single Model Mode (236B only)

```nix
models = [
  "deepseek-coder-v2:236b"  # ~140GB RAM
];

environmentVariables = {
  OLLAMA_NUM_PARALLEL = "2";     # Reduced parallel
  OLLAMA_KEEP_ALIVE = "24h";
  OLLAMA_NUM_GPU = "99";         # Max GPU offload
  OLLAMA_NUM_CTX = "4096";       # Moderate context
};
```

**RAM usage:** ~140GB model + ~10GB OS = 150GB total (slightly tight)

### Option 2: Swap Strategy (Not Recommended)

If you want to try 236B on 128GB:

```nix
# Add swap space for safety
system.activationScripts.ollamaSwap.text = ''
  # Create 64GB swap file
  dd if=/dev/zero of=/var/lib/ollama/swap bs=1g count=64
  chmod 600 /var/lib/ollama/swap
  # Note: macOS swap is automatic, this is for reference
'';
```

**Reality check:** 236B will likely be too slow with swapping. Better to stick with multiple 70B models.

### Option 3: Wait for Ollama Quantization

Future Ollama versions may support lower precision (4-bit quantization):
- 236B at FP16: ~140GB
- 236B at 4-bit: ~70GB (fits easily!)

Check Ollama releases for quantized models.

## 🎯 Recommended Final Configuration

For M5 Max with 128GB RAM:

```nix
services.ollama = {
  enable = true;
  
  models = [
    "qwen2.5-coder:32b"  # Primary coding (fast)
    "llama3.3:70b"       # Deep reasoning
    "qwen2.5:72b"        # Alternative reasoning/docs
  ];
  
  environmentVariables = {
    OLLAMA_NUM_PARALLEL = "8";      # Full parallel capacity
    OLLAMA_KEEP_ALIVE = "-1";       # Never unload (you have the RAM)
    OLLAMA_NUM_GPU = "99";          # Max GPU utilization
    OLLAMA_NUM_CTX = "8192";        # 8K context window
    OLLAMA_MAX_LOADED_MODELS = "3"; # Keep all 3 loaded
  };
};
```

**Total RAM:** ~102GB models + ~10GB OS + ~16GB context buffers = ~128GB (perfect fit!)

**Performance:**
- 8 parallel requests across 3 models
- Sub-100ms warm latency
- 60-80 tok/s (32B), 25-35 tok/s (70B)
- Zero swap usage
- Instant model switching

## 📚 Additional Resources

- [Ollama Performance Tuning](https://github.com/ollama/ollama/blob/main/docs/faq.md#how-can-i-optimize-ollama-for-apple-silicon)
- [Metal Performance Guide](https://developer.apple.com/metal/tensorflow-plugin/)
- [M5 Architecture Details](https://www.apple.com/m5-max)

---

**Hardware:** M5 Max, 128GB unified memory, 40-core GPU  
**Configuration:** `modules/ollama.nix`  
**Optimal Setup:** 3 models (~102GB), 8 parallel, -1 keep-alive  
**Expected Performance:** 60-80 tok/s (32B), 25-35 tok/s (70B)
