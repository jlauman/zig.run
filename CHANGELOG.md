# Changelog
All notable changes to the `zig.run` project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


## [Unreleased]
### Added
### Changed
- Example run state indicator color.
### Fixed


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
