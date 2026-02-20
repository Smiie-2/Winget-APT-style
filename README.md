# winget-apt

A PowerShell wrapper for `winget` that makes it behave more like `apt-get` on Linux.

## Features

- **Interactive Installation**: If a `winget install` command matches multiple packages, it displays a numbered list of matches and prompts you to select the correct one.
- **Seamless Integration**: Passes all other commands (search, list, upgrade, etc.) and flags directly to the original `winget.exe`.
- **Easy Setup**: Includes an installation script that sets up the alias in your PowerShell profile automatically.

## Installation

1. Clone or download this repository.
2. Open PowerShell in the project directory.
3. Run the installation script:
   ```powershell
   .\Install-WingetApt.ps1
   ```
4. Restart your terminal or reload your profile:
   ```powershell
   . $PROFILE
   ```

## Usage

Simply use `winget` as you normally would. When you try to install a package with an ambiguous name:

```powershell
winget install opera
```

The script will search for "opera", show a list like this:

```
Multiple matches found. Please select a package to install:
[1] Opera Stable (Opera.Opera)
[2] Opera GX (Opera.OperaGX)
...
Enter the number (1-x) or 'q' to quit:
```

Enter the number and hit Enter to proceed with the installation of that specific package ID.

## How it Works

The installer copies the main script to `$HOME\AppData\Local\winget-apt` and adds a function named `winget` to your PowerShell profile. This function intercepts calls, checks if the command is `install`, and handles the interactive selection if needed. It always calls the original `winget.exe` for the actual heavy lifting.
