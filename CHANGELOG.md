# Changelog
All notable changes to the `zig.run` project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


## [Unreleased]
### Added
### Changed
### Fixed


## [210301] - 2021-03-01
### Added
- Example list headers.
### Changed
- Order of examples.
- Moved credits to example list.
### Fixed
- Reading title of empty file or file with no newline.


## [210226] - 2021-02-26
### Added
- Embed example with HTTP GET and base64 snippet encoding.
- Snippet runner for external Zig examples.
- Snippet example with external button and widget generators.
- Copy of Zigg Zagg sample with while loop continuation.
### Changed
- API paths for example list and run (which hides CGI implementation).
- Comments for base64 example.
### Fixed


## [210220] - 2021-02-20
### Added
- Example to confirm openDir on /home/web/tmp folder fails.
- Example to confirm outbound network connection fails.
### Changed
- Prevent Zig openDir on /home/web/tmp folder.
- Title lookup from Zig source files - check test.zig after main.zig.
### Fixed


## [210219] - 2021-02-19
### Added
- Array, struct, and enum examples.
### Changed
### Fixed


## [210202] - 20210202
### Added
- Ability to handle examples with no main.zig file (tests only).
### Changed
- Removed stub main.zig files in test only examples.
- Print formatting in some test examples.
### Fixed
- Slide checkbox label is now clickable.


## [210201] - 2021-02-01
### Added
- Code files for two more examples.
### Changed
### Fixed


## [210130] - 2021-01-30
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
