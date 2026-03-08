# dotfiles Improvements Summary

## 1. **Fixed Hardcoded Path in `.zshrc`**
   - **Issue:** OpenCode path was hardcoded
   - **Fix:** Changed to use `$HOME` environment variable for portability
   - **Location:** [zsh/.zshrc](zsh/.zshrc#L61)

## 2. **Added `zoxide` (Smarter Directory Navigation)**
   - **What it is:** A lightweight replacement for `cd` that learns your frecency patterns
   - **Added to:**
     - `bootstrap.sh` — Auto-installs from official script
     - [zsh/.zshrc](zsh/.zshrc#L18) — Added to plugins list
     - [zsh/.zshrc](zsh/.zshrc#L52) — Initialize zoxide
   - **Usage:** Type `z <partial-path>` and it jumps to your most-visited matching directory
   - **Example:** `z dotfiles` instead of `cd ~/projects/repos/dotfiles`

## 3. **Added `delta` (Better Git Diffs)**
   - **What it is:** A syntax-highlighted, side-by-side diff tool that integrates with git
   - **Added to:**
     - `bootstrap.sh` — Auto-installs latest from GitHub
     - [git/.gitconfig](git/.gitconfig#L8) — Configured as default pager
   - **Features:**
     - Syntax highlighting for source code
     - Side-by-side comparison mode
     - Better conflict resolution visualization (zdiff3)

## 4. **Upgraded Git Tools to GitHub Releases**
   - **Tools:** `bat`, `fd`, `ripgrep`
   - **Why:** Latest versions from GitHub have critical bug fixes and features that Ubuntu repos lack
   - **Impact:** Removed hardcoded workarounds like `batcat` → `bat` symlinks
   - **Location:** [bootstrap.sh](bootstrap.sh#L147-L200)

## 5. **Updated Documentation**
   - Updated `bootstrap.sh` header to reflect all new tools
   - Updated summary section to include `zoxide` and `delta`

## Optional Future Improvements

### Security & Git
- [ ] Add `git-crypt` for encrypted files in the repo
- [ ] Configure SSH config template (currently empty after cloning)
- [ ] Add GPG signing setup documentation

### Development Experience
- [ ] Create a local `.config/nvim/` with basic Neovim setup
- [ ] Add GitHub CLI (`gh`) installation and auth setup
- [ ] Create a `.config/opencode/` config example

### Monitoring & Utilities
- [ ] Add `lazygit` or `gitui` for interactive git workflows
- [ ] Add `bottom` for system monitoring (better than htop)
- [ ] Add `starship` for a faster, more customizable prompt alternative

### Shell Enhancements
- [ ] Add `direnv` for project-specific environment variables
- [ ] Add `just` for task running (like Makefile but simpler)
- [ ] Create custom functions in a separate `.config/zsh/functions.sh`

### Version Management
- [ ] Consider `asdf` instead of NVM for managing multiple runtimes
- [ ] Add Node.js preset to SDKMAN or similar

### CI/CD & Containers
- [ ] Add Docker convenience aliases
- [ ] Add container registry utilities
