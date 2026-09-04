# Nixvim 

## Try it

You can also run this configuration directly from GitHub without cloning:

```
nix run github:yoghurt-x86/nixvim
```

## AI assistant (avante.nvim)

On macOS, avante is configured to use a local [LM Studio](https://lmstudio.ai)
server instead of a cloud provider. Before opening nvim, make sure LM Studio
is running with the **`ornith-1.5-35b-a3b-mlx`** model loaded and its local
server started (default: `http://127.0.0.1:1234`). On Linux, avante falls
back to the Claude provider instead.

