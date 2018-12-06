# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2018-12-06
### Removed
- `Html.Parser.Util.toVirtualDomSvg` as parsing of SVG nodes is not implemented yet.

## [1.1.0] - 2018-12-06
### Added
- `Html.Parser.Util` to transform parser nodes into virtual dom nodes.
- Support for all [named character references][named-character-references].

## [1.0.1] - 2018-09-11
### Added
- Support void elements with a closing slash (like `<br />`, etc.).

## [1.0.0] - 2018-08-23
### Added
- Initial release!
- `Html.Parser.run`

[named-character-references]: https://www.w3.org/TR/html5/syntax.html#named-character-references

[Unreleased]: https://github.com/hecrj/html-parser/compare/2.0.0...HEAD
[2.0.0]: https://github.com/hecrj/html-parser/compare/1.1.0...2.0.0
[1.1.0]: https://github.com/hecrj/html-parser/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/hecrj/html-parser/compare/1.0.0...1.0.1
