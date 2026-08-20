# Trace - Lightweight Developer-Oriented Web Browser

Trace is a lightweight, developer-oriented web browser built specifically for personal use. It is designed around a focused workflow rather than trying to reproduce every feature of a general-purpose browser.

Built with Delphi, CEF4Delphi, Chromium and Skia, Trace focuses on a minimal interface, custom rendering, efficient resource usage, and developer-focused features.

The goal is simple: build a browser around the way I actually use a browser.

---

## Screenshots

![Trace Screenshot](screenshots/ss1.png)
![Trace Screenshot](screenshots/ss2.png)
![Trace Screenshot](screenshots/ss3.png)

---

## Features

### Chromium-Based Browser

* Chromium-powered web rendering through CEF4Delphi.
* Full modern web platform support provided by Chromium.
* URL navigation and Google search integration.
* Back / Forward navigation.
* Page reload.
* Popup and `target="_blank"` handling through Trace tabs.

### Custom Tab System

* Fully custom-rendered tab interface.
* Skia-based tab rendering.
* Dynamic tab titles from page titles.
* Favicon loading and rendering.
* Drag & drop tab reordering.
* Animated tab closing.
* Smooth tab repositioning.
* Animated loading indicators.
* Custom new-tab button.
* Custom window interaction.

### Lightweight Architecture

Trace intentionally avoids unnecessary browser functionality and background services that are not useful for its intended workflow.

In my own testing, this focused architecture resulted in approximately **40–50% lower RAM usage compared to Chrome in comparable usage scenarios**.

The goal is not to compete with Chromium on features, but to avoid carrying features that are not needed.

### Developer-Oriented Workflow

Trace is being developed with developer workflows in mind.

Planned developer-focused functionality includes:

* Chromium DevTools.
* Tab Manager.
* Browser task/process management.
* History.
* Downloads.
* Bookmarks.
* Additional browser utilities.

### Skia Rendering

Skia is a core part of Trace's interface and rendering architecture.

It is used to build the custom browser UI instead of relying entirely on standard VCL controls.

Current custom-rendered elements include:

* Tab bar.
* Tab animations.
* Favicons.
* Loading indicators.
* Tab interactions.
* Window controls.

This allows Trace to maintain a custom visual language while keeping the application lightweight.

---

## Why Trace?

* Lightweight and focused
* Built for a personal workflow
* Chromium-based web rendering
* Custom Skia-powered interface
* Native Delphi application
* Developer-oriented feature set
* No unnecessary browser services
* Custom tab management
* Designed with resource usage in mind

Trace is not intended to replace Chrome for everyone.

It is a personal browser project built around a specific use case: having a fast, lightweight browser with the tools and workflow I actually need.

---

## Technology Stack

* **Delphi 12 Athens**
* **VCL**
* **CEF4Delphi**
* **Chromium**
* **Skia4Delphi**

CEF4Delphi is used to embed Chromium into the Delphi application.

CEF4Delphi must be installed separately before building Trace.

Repository:

[CEF4Delphi](https://github.com/salvadordf/CEF4Delphi?utm_source=chatgpt.com)

---

## Installation

### Requirements

* Delphi 12 Athens
* Windows
* CEF4Delphi
* Required CEF binaries

### Setup

1. Clone the repository.

```bash
git clone https://github.com/yushadev0/trace-browser.git
```

2. Install and configure CEF4Delphi.

3. Open `Trace.dproj` in Delphi 12 Athens.

4. Make sure the required CEF binaries are available in the application's output directory.

5. Build and run the project.

---

## Usage

1. Start Trace.
2. Enter a URL or search query in the address bar.
3. Use the navigation controls to move between pages.
4. Open new tabs using the new-tab button.
5. Drag tabs to reorder them.
6. Close tabs using the tab close button.

Trace currently focuses on the core browsing experience. Additional browser functionality is being developed as the project evolves.

---

## Roadmap

### Browser Features

* [ ] History
* [ ] Downloads
* [ ] Bookmarks
* [ ] Chromium DevTools
* [ ] Find in Page
* [ ] Keyboard shortcuts
* [ ] Private browsing

### Tab Management

* [ ] Tab Manager
* [ ] Browser task management
* [ ] Tab memory/process monitoring
* [ ] Tab suspension
* [ ] Tab groups

### Developer Features

* [ ] Developer-focused shortcuts
* [ ] Improved DevTools integration
* [ ] Developer workspace features
* [ ] Additional Chromium debugging utilities

### UI & Performance

* [ ] Further Skia UI improvements
* [ ] Additional tab animations
* [ ] Resource usage optimizations
* [ ] Startup time optimizations
* [ ] More configurable interface

---

## Contributing

Trace is primarily a personal project, but bug reports, suggestions and pull requests are welcome.

---

## Licence

This project uses MIT License.

---

Developed by Yuşa Güverdik for personal use.
