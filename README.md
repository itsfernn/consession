<!-- #host-reference -->
<!-- markdownlint-disable-next-line -->
<p align="center">
  <img width="160" src="./logo.png" alt="consession logo">
</p>

<h1 align="center">consession</h1>

<div align="center">
<!-- TODO: shields.id -->
</div>

---

**consession** is a **tmux session manager** powered by **fzf** and **zoxide**. It lists your existing tmux sessions for quick attachment and lets you create new sessions based on your most-used directories cached by zoxide.

---

## 🚀 Features

- **List and attach** to open tmux sessions using fzf for fuzzy searching.
- **Create new sessions** automatically from your frequently used directories (via zoxide).
- **Interactive preview** of session output and directory contents.
- **Keybindings** for renaming and killing sessions directly from the fzf interface.
- **Customizable** appearance and behavior through configuration variables.

---

## 📦 Installation

1. **Clone the repo**

   ```bash
   git clone https://github.com/yourusername/consession.git
   cd consession
   ```

2. **Make it executable**

   ```bash
   chmod +x consession.sh
   ```

3. **Move to your PATH** (optional)

   ```bash
   mv consession.sh /usr/local/bin/consession
   ```

4. **Ensure dependencies are installed**

   - [tmux](https://github.com/tmux/tmux)
   - [fzf](https://github.com/junegunn/fzf)
   - [zoxide](https://github.com/ajeetdsouza/zoxide)
   - [eza](https://github.com/eza-community/eza) (optional, for directory preview icons)

---

## ⚙️ Usage

Simply run:

```bash
consession
```

By default, consession will:

1. Show a fuzzy list of your current tmux sessions.
2. Allow you to kill (`Ctrl-D`) or rename (`Ctrl-R`) any session.
3. Press `Zero` (key `0`) to switch to the zoxide directory view and create a new session in a chosen directory.
4. Attach to or switch to the selected session.

### Keybindings

| Action                 | Key Combination |
| ---------------------- | --------------- |
| Kill session           | Ctrl-D          |
| Rename session         | Ctrl-R          |
| Switch to zoxide view  | 0 (zero)        |
| Reset to sessions view | Ctrl-A (start)  |

---

## 🛠 Configuration

You can tweak the following variables at the top of the script:

- `rename_session` – the keybinding to rename a session (default: `ctrl-r`).
- `kill_session` – the keybinding to kill a session (default: `ctrl-d`).
- `fzf_opts` – customize fzf appearance (preview window size, colors, layout).

Feel free to fork and adjust these settings to fit your workflow!

---

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -m 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Open a Pull Request

Please ensure your code follows existing style and includes relevant tests if applicable.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- Inspired by fzf-tmux workflows
- Thanks to the maintainers of tmux, fzf, zoxide, and eza


