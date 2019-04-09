# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.3.4] - 2019-04-09
### Changed
- Treat a non-breaking space (`\u{00a0}`) like a space character. This avoids runtime errors when using `Html.Util.toVirtualDom`. Thanks to @magopian!

## [2.3.3] - 2019-03-25
### Changed
- Support hyphens in tag names (allows parsing web components). Thanks to @andre-dietrich!

## [2.3.2] - 2019-03-23
### Changed
- Fix decimal numeric character references failing to parse if they contained leading zeros ([#8](https://github.com/hecrj/html-parser/pull/8/files)). Thanks to @68kHeart!
- Fix `nodeToString` example in documentation.

## [2.3.1] - 2019-03-10
### Changed
- `Html.Parser.nodeToString` spaces attributes properly.

## [2.3.0] - 2019-03-10
### Added
- `Html.Parser.nodeToString` to turn parser nodes back into its HTML representation.

## [2.2.0] - 2019-02-27
### Added
- Expose `Html.Parser.node` to allow other folks to build different parsers on top of this one!

## [2.1.0] - 2019-02-21
### Added
- Expose `Html.Parser.Attribute` type alias so the documentation is complete.

## [2.0.1] - 2019-02-15
### Changed
- Fix parser erroring when input is an empty string. Thanks to @doanythingfordethklok!

## [2.0.0] - 2018-12-06
### Removed
- `Html.Parser.Util.toVirtualDomSvg` as parsing of SVG nodes is not implemented yet.

## [1.1.0] - 2018-12-06
### Added
- `Html.Parser.Util` to transform parser nodes into virtual dom nodes ([#3](https://github.com/hecrj/html-parser/pull/3)). Thanks to @ccapndave!
- Support for all [named character references][named-character-references].

## [1.0.1] - 2018-09-11
### Added
- Support void elements with a closing slash (like `<br />`, etc.) ([#1](https://github.com/hecrj/html-parser/pull/1)). Thanks to @isaacseymour!

## [1.0.0] - 2018-08-23
### Added
- Initial release!
- `Html.Parser.run`

[named-character-references]: https://www.w3.org/TR/html5/syntax.html#named-character-references

[Unreleased]: https://github.com/hecrj/html-parser/compare/2.3.4...HEAD
[2.3.4]: https://github.com/hecrj/html-parser/compare/2.3.3...2.3.4
[2.3.3]: https://github.com/hecrj/html-parser/compare/2.3.2...2.3.3
[2.3.2]: https://github.com/hecrj/html-parser/compare/2.3.1...2.3.2
[2.3.1]: https://github.com/hecrj/html-parser/compare/2.3.0...2.3.1
[2.3.0]: https://github.com/hecrj/html-parser/compare/2.2.0...2.3.0
[2.2.0]: https://github.com/hecrj/html-parser/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/hecrj/html-parser/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/hecrj/html-parser/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/hecrj/html-parser/compare/1.1.0...2.0.0
[1.1.0]: https://github.com/hecrj/html-parser/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/hecrj/html-parser/compare/1.0.0...1.0.1
