<!-- #host-reference -->
<h1 align="center">consession</h1>
<!-- markdownlint-disable-next-line -->
<p align="center">
  <img width="250" src="./logo.png" alt="consession logo">
</p>



---

**consession** is a **tmux session manager** powered by **fzf** and **zoxide**. It lists your existing tmux sessions for quick attachment and lets you create new sessions based on your most-used directories cached by zoxide.

---

## 🚀 Features

- **List and attach** to open tmux sessions using fzf for fuzzy searching.
- **Create new sessions** automatically from your frequently used directories (via zoxide).
- **Interactive preview** of session output and directory contents.
- **Keybindings** for renaming and killing sessions directly from the fzf interface.
- **Customizable** appearance and behavior through configuration variables.

![Screenshot of consession](screenshot.png)
---

## 📦 Installation

1. **Clone the repo**

   ```bash
   git clone https://github.com/itsfernnn/consession.git
   cd consession
   ```

2. **Make it executable**

   ```bash
   chmod +x consession.sh
   ```

3. **Move to your PATH**

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
3. Automatically switches to zoxide view when query does not match any existing session 
4. Switch back to the session view by pressing `Backspace` on an empty query.
5. Switch to an existing session or create a new one in the selected directory by pressing `Enter`.

### Keybindings

| Action                 | Key Combination |
| ---------------------- | --------------- |
| Kill session           | Ctrl-D          |
| Rename session         | Ctrl-R          |
| Switch to zoxide view  | unique query    |
| Reset to sessions view | backspace       |
| create or switch session | enter           |

---

## 🛠 Configuration

`TODO`

---


## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- Inspired by fzf-tmux workflows
- Thanks to the maintainers of tmux, fzf, zoxide, and eza


