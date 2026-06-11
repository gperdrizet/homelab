# Zed IDE: install on pyrite

[Zed](https://zed.dev/) is a high-performance, GPU-accelerated code editor with
built-in AI assistance. This guide covers installation on pyrite (Ubuntu desktop).

---

## Install

Zed provides an official install script:

```bash
curl -f https://zed.dev/install.sh | sh
```

This installs the `zed` binary to `~/.local/bin/zed`. Make sure `~/.local/bin`
is in your `PATH` (it is by default on modern Ubuntu).

---

## Launch

```bash
zed
# or open a specific file/directory
zed ~/code/my-project
```

A `.desktop` entry is also installed automatically, so Zed will appear in the
application launcher.

---

## Updates

Zed updates itself automatically. To manually trigger an update, open the
command palette (`Cmd/Ctrl+Shift+P`) and run `zed: check for updates`, or
simply re-run the install script.

---

## AI / LLM integration

Zed supports multiple AI backends. To use the local llama.cpp inference server
on pyrite (or via model-gateway):

1. Open settings: `Cmd/Ctrl+,`
2. Set `assistant.provider` to `openai` (Zed uses the OpenAI-compatible API format)
3. Set the endpoint to `http://localhost:8502/v1` (local llama.cpp) or
   `https://promptlyapi.com/v1` (model-gateway, requires API key)

<!-- TODO: document exact settings JSON once tested -->

---

## Useful keybindings

| Action | Keybinding |
|--------|-----------|
| Command palette | `Ctrl+Shift+P` |
| Open file | `Ctrl+P` |
| Toggle terminal | `` Ctrl+` `` |
| AI assistant panel | `Ctrl+?` |
| Multi-cursor | `Ctrl+D` |

---

## See also

- [Zed docs](https://zed.dev/docs)
- [machines/pyrite/README.md](../README.md)
