# Trace - Lightweight Developer-Oriented Web Browser

Trace is a lightweight, developer-oriented web browser built specifically for personal use. It is designed around a focused workflow rather than trying to reproduce every feature of a general-purpose browser.

Built with Delphi, CEF4Delphi, Chromium and Skia, Trace focuses on a minimal interface, custom rendering, efficient resource usage, and developer-focused features.

The goal is simple: build a browser around the way I actually use a browser.

**[Download the latest Windows build →](https://github.com/yushadev0/trace-browser/releases/latest)**

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
* Custom title bar with quick-access Downloads and History buttons next to the system controls.

### Bookmarks

* Persistent bookmark bar backed by a local SQLite database.
* Drag & drop reordering of bookmarks.
* Automatic favicon fetching for each bookmark.
* Icon-only bookmarks when no name is given, instead of wasting space on an empty label.
* Click to open, star icon in the address bar to add/edit/remove the current page.

### Downloads

* Native Chromium download handling, saved to a custom, configurable download folder.
* Custom downloads page (`trace://downloads`) instead of Chromium's built-in download UI.
* Live progress bar for downloads in progress.
* Automatic file renaming (`file (1).ext`, `file (2).ext`, ...) so a repeated download never silently overwrites the previous one.
* Real-time detection of manually deleted files, with a faded / strikethrough visual state.
* Copy source URL, show in folder, remove from list, or clear all.
* A small flying animation from the click location to the Downloads icon when a download starts.

### History

* Custom history page (`trace://history`) instead of relying on Chromium's own UI.
* Click any entry to reopen the page.
* Search through visited pages.
* Remove individual entries or clear all history.

### Tasks & To-Do List

* A lightweight task list built into the new tab page.
* Add, complete, and delete tasks, backed by the local database.

### AI Assistant

* Built-in AI assistant (Gemini-powered) accessible from the new tab page.
* Can answer questions, search the web, and help edit saved reports.
* AI-generated email summaries with priority detection over an IMAP connection.
* Responds in the user's selected interface language.

### Settings

* Custom settings page (`trace://settings`) instead of a native dialog.
* Light / dark theme, applied instantly across all open tabs.
* Interface language selection.
* Custom greeting name and avatar on the new tab page.
* Configurable download folder and "show in folder after download" behavior.
* Startup mode: open a fresh new tab, or restore the previous session's tabs.
* Email account configuration for the AI email summaries.

### Task Manager

* Built-in browser task manager (`trace://taskmgr`), similar in spirit to Chrome's own.
* Per-tab CPU, RAM, and network usage.

### Reports

* Save and revisit AI-generated reports from a dedicated reports page.

### Lightweight Architecture

Trace intentionally avoids unnecessary browser functionality and background services that are not useful for its intended workflow.

In my own testing, this focused architecture resulted in approximately **40–50% lower RAM usage compared to Chrome in comparable usage scenarios**.

The goal is not to compete with Chromium on features, but to avoid carrying features that are not needed.

### Developer-Oriented Workflow

Trace is being developed with developer workflows in mind.

Implemented so far:

* History.
* Downloads.
* Bookmarks.
* Task Manager.
* Settings.

Still planned:

* Chromium DevTools.
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
* Local-first bookmarks, history, downloads, and tasks
* Built-in AI assistant
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
* **SQLite** (via FireDAC) for bookmarks, history, downloads, tasks, reports and settings
* **Indy** (IMAP over SSL) for AI email summaries

CEF4Delphi is used to embed Chromium into the Delphi application.

CEF4Delphi must be installed separately before building Trace.

Repository:

[CEF4Delphi](https://github.com/salvadordf/CEF4Delphi)

---

## Installation

### Prebuilt Binaries (Windows)

Don't want to build from source? Download a ready-to-run Windows build from the [Releases page](https://github.com/yushadev0/trace-browser/releases/latest), extract the archive, and run `Trace.exe`.

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
7. Star a page to bookmark it, and drag bookmarks to reorder them.
8. Open Downloads or History from the title bar, or with the built-in shortcuts.
9. Add quick tasks from the new tab page.
10. Ask the built-in AI assistant a question from the new tab page.
11. Adjust theme, language, and other preferences from Settings.

Trace currently focuses on the core browsing experience, alongside the personal productivity features above. Additional browser functionality is being developed as the project evolves.

---

## Roadmap

### Browser Features

* [x] History
* [x] Downloads
* [x] Bookmarks
* [ ] Chromium DevTools
* [ ] Find in Page
* [ ] Keyboard shortcuts
* [ ] Private browsing

### Tab Management

* [x] Tab Manager
* [x] Browser task management
* [x] Tab memory/process monitoring
* [ ] Tab suspension
* [ ] Tab groups

### Developer Features

* [ ] Developer-focused shortcuts
* [ ] Improved DevTools integration
* [ ] Developer workspace features
* [ ] Additional Chromium debugging utilities

### AI & Productivity

* [x] Built-in AI assistant
* [x] AI email summaries
* [x] Tasks / to-do list
* [x] Saved reports
* [ ] Full interface translation (i18n) beyond the AI assistant

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
