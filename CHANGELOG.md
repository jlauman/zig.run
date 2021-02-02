# Changelog
All notable changes to the `zig.run` project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


## [Unreleased]
### Added
### Changed
### Fixed


## [210201] - 20210201
### Added
- Code files for two more examples.
### Changed
### Fixed


## [210130] - 20210130
### Added
- Tooltips to run, test, and format buttons.
- Two examples and updated others.
- Ctrl-/ line comment behavior to codemirror.
- Example caching to reduce network requests.
### Changed
- Example run state indicator color.
- Sliding half-screen layout for views.
- Reordered examples.
- CGI stderr output for logging.
### Fixed
- Zig-orange color in CSS.


## [210124] - 2021-01-24
### Added
- Elapsed compile+run time protection -- currently 10 seconds.
- Clean-up script to remove temporary files.
- Run status indicator and arguments input field.
### Changed
- The play.zig CGI passes main.zig command-line arguments.
### Fixed
- Source file format command.


## [210123] - 2021-01-23
### Added
- Build tag and git short hash to `window.ZigRun` and UI.
- Credits for projects used in `zig.run` UI.
- Link highlight and click handler in output panel.
- Next/previous example buttons near example title.
### Changed
- Split example selection menu and welcome/about page.
- Switch `podman` to `docker` in bash scripts.
