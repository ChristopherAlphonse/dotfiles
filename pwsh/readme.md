<div align="center">
  <a href="#">
    <img src="./logo/PowerShell_Core_6.0_icon.png" alt="Logo" width="70" height="70">
  </a>

<h3 align="center">Chris's Powershell Settings</h3>

  <p align="center">
    This is a bootstrap project, the technologies used aren't my own but rather utilized and modified to fit my preferences.
    <br />
<!--     <a href="https://github.com/ChristopherAlphonse/admindashboard"><strong>Explore the docs »</strong></a> -->
    <br />
    <br />
  
  </p>
</div>

<p>
  <a href="https://www.npmjs.com/package/powershell" target="_blank">
    <img alt="Version" src="https://img.shields.io/npm/v/powershell.svg">
  </a>
  <a href="https://github.com/ChristopherAlphonse/Powershell#readme" target="_blank">
    <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg" />
  </a>
  <a href="https://github.com/ChristopherAlphonse/Powershell/graphs/commit-activity" target="_blank">
    <img alt="Maintenance" src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" />
  </a>
</p>

### 🏠 [Homepage](https://github.com/ChristopherAlphonse/Powershell#readme)

## Author

👤 **Christopher Alphonse**

- Website: christopheralphonse.com
- Github: [@ChristopherAlphonse](https://github.com/ChristopherAlphonse)

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About This Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#terminal-settings">Terminal Settings</a></li>
 <ul>
        <li><a href="#vs-code">VS Code</a></li>
        <li><a href="#terminal">Terminal JSON</a></li>
        <li><a href="#install-font">Font</a></li>
      </ul>
  </ol>
</details>

<!-- GETTING STARTED -->

## Getting Started

Before we get started, this is a tutorial for <i>Windows</i> only. With that being said, lets begin.

- Download [Microsoft Store](https://www.microsoft.com/en-us/download/confirmation.aspx?id=54768)

- Download [App Installer](https://apps.microsoft.com/store/detail/app-installer/9NBLGGH4NNS1?hl=en-us&gl=us)

Open CMD for Windows

```sh
winget install -e --id Microsoft.WindowsTerminal
```

Open the Terminal in Admin mode by pressing on <i> CTRL + SHIFT + Click on Terminal icon</i> <b> OR </b> press the windows key and locate Terminal.exe, and right click on Terminal icon and select <i>Run as Administrator</i> .

Install Winget

```sh
winget install -e --id JanDeDobbeleer.OhMyPosh
```

<!-- ABOUT THE PROJECT -->

## About The Project

These are the final Look for the terminal and vs code integrated terminal

![Product Screen Shot][product-screenshot]
<br/>
![Product Screen Shot][vs-screenshot]

### Prerequisites

Open your terminal and sure node and nodemon is installed and up to date

- Go to Documents Folder

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/ChristopherAlphonse/Powershell.git
   code .
   ```
2. Install packages

```sh
Install-Module -Name posh-git -RequiredVersion 1.0.0
Install-Module -Name PSFzf -AllowPrerelease
Install-Module -Name PSFzf -AllowPrerelease
Install-Module -Name Terminal-Icons
Install-Module -Name z
```

3. Copy the files and remove the Terminal folder, and read for next step

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!--  EXAMPLES -->

## vs code

```json
 "terminal.integrated.defaultProfile.windows": "PowerShell",
 "workbench.colorCustomizations": {
 "terminal.foreground": "#ffffff",
 "terminal.background": "#515761",
 "editor.lineHighlightBackground": "#4046452d",
 "editor.lineHighlightBorder": "#7a05701f",
 "tab.activeBackground": "#2e327195",
 "terminal.integrated.fontFamily": "MesloLGM NF",
"terminal.integrated.defaultProfile.linux": "bash",
"terminal.integrated.gpuAcceleration": "off",
"workbench.colorTheme": " Azalais Dark ",
"terminal.integrated.enableMultiLinePasteWarning": false,
"terminal.integrated.splitCwd": "workspaceRoot",
"terminal.integrated.tabs.defaultColor": "terminal.ansiCyan",
"terminal.integrated.smoothScrolling": true,
"markdown.preview.lineHeight": 2,
"terminal.integrated.cursorWidth": 0,
"terminal.integrated.fontSize": 12,
```

<!--  JSON -->

## Terminal

Open the terminal folder and navigate to JSON file and replace with [Terminal JSON](https://github.com/ChristopherAlphonse/Powershell/blob/master/Terminal/setting.json)

Finding the JSON files

- Press Ctrl+,
- Look Bottom left: OPEN JSON file <br/>
  ![JSON Screen Shot][json]

- Copy and replace the JSON file

## Install font

Open the terminal folder and navigate top Font and Installed [Meslo Font](https://github.com/ChristopherAlphonse/Powershell/blob/master/Terminal/Font)
<br/>
![Font Face][font]

# IF YOU ARE STUCK PLEASE OPEN AN [ISSUE REQUEST](https://github.com/ChristopherAlphonse/Powershell/issues)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

[product-screenshot]: ./logo/Capture.JPG
[vs-screenshot]: ./logo/vs_code.JPG
[json]: ./logo/JSON_terminal.JPG
[font]: ./logo/font.JPG
