---
name: git-github-push
description: Push git commits to GitHub repositories using SSH with correct agent setup.
---

# Git GitHub Push

When pushing commits to GitHub repositories, SSH requires proper agent setup because the container has a read-only filesystem that prevents SSH from writing `known_hosts` to `/home/node/.ssh/`.

## Problem

- SSH key at `~/.ssh/id_ed25519`
- Key is bound to GitHub account `ai-vibeqodez`
- `/home/node/.ssh/` does not exist or is read-only — SSH fails with `Could not create directory '/home/node/.ssh'`
- `ssh-add` fails with `Could not open a connection to your authentication agent`

## Solution: Use writable temp directory for SSH

### Step 1: Prepare writable SSH directory

```bash
mkdir -p /tmp/ssh
cp ~/.ssh/id_ed25519 /tmp/ssh/
cp ~/.ssh/id_ed25519.pub /tmp/ssh/
touch /tmp/ssh/known_hosts
chmod 700 /tmp/ssh
chmod 600 /tmp/ssh/id_ed25519
```

### Step 2: Start ssh-agent and load key

```bash
eval "$(ssh-agent -s)"
ssh-add /tmp/ssh/id_ed25519
```

### Step 3: Push with GIT_SSH_COMMAND

```bash
GIT_SSH_COMMAND="ssh -i /tmp/ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/ssh/known_hosts" git push origin main
```

### One-liner (all steps)

```bash
mkdir -p /tmp/ssh && cp ~/.ssh/id_ed25519 /tmp/ssh/ && cp ~/.ssh/id_ed25519.pub /tmp/ssh/ && touch /tmp/ssh/known_hosts && chmod 700 /tmp/ssh && chmod 600 /tmp/ssh/id_ed25519 && eval "$(ssh-agent -s)" && ssh-add /tmp/ssh/id_ed25519 && GIT_SSH_COMMAND="ssh -i /tmp/ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/ssh/known_hosts" git push origin main
```

## Current repositories

| Repository | Remote | Status |
|---|---|---|
| `ai-warevo/.github` | `git@github.com:ai-warevo/.github.git` | ✅ Active, push works |
| `ai-warevo/qwen-fast-coder-4080` | `git@github.com:ai-warevo/qwen-fast-coder-4080.git` | 📦 Archived (read-only) |

## Git user config

```
user.email: ai_vibeqodez@vk.com
user.name: Anatoly Ivanov
```

This email is verified in GitHub account `ai-vibeqodez` and ensures commits appear in the contribution graph.

## Common pitfalls

1. **Forgot `GIT_SSH_COMMAND`** — without it, SSH tries to write to `/home/node/.ssh` and fails.
2. **Key with password** — `ssh-add` will prompt; in non-interactive environments the key must be passphrase-less or agent must be pre-started.
3. **Wrong remote** — always check `git remote -v` before pushing.
4. **Archived repos** — `ai-warevo/qwen-fast-coder-4080` is archived and read-only.
5. **Organization repos** — commits in `ai-warevo/*` repos count toward `ai-vibeqodez` contribution graph because email matches, but only if pushed from `ai-vibeqodez` SSH key.
