# Tenji

Tenji is a powerful image gallery plugin for Jekyll.

## Overview

Image galleries suit themselves to static site generation but there are few
options available. Tenji is a plugin for creating image galleries using Jekyll.

Tenji features customisable directory names, easy pagination, flexible sorting,
hidden galleries and thumbnail generation for high density displays. It embraces
convention over configuration that makes it simple to get started while at the
same time providing a large number of options for those who like to make things
just so.

## Installation

The easiest way to install Tenji is to add `gem "jekyll-tenji"` to the 
`:jekyll-plugins` group in your `Gemfile`. Now all you need to do is run `bundle
install`. See [the Jekyll documentation][jd] for more information on how to
install Jekyll plugins.

[jd]: https://jekyllrb.com/docs/plugins/installation/

## Usage

To use Tenji:

1. create the following template files in your template directory (by default, 
   `_layouts`):
   * `gallery_list.html`;
   * `gallery_index.html`;
   * `gallery_single.html`;
2. create a directory for your galleries (by default, `_albums`);
3. put your images in separate subdirectories;
4. generate the site by running `jekyll build`.

Voila! Your images are now ready for the world to see.

## Configuration

You can customise the way Tenji works by adding options to your configuration 
file (by default, `_config.yml`). 

See [the Tenji documentation][td] for more information on configuring Tenji.

[td]: https://rubydoc.info/gems/jekyll-tenji

## Requirements

Tenji has been tested with Ruby 2.5.0 and Jekyll 3.8.4.

## Bugs

Found a bug? I'd love to know about it. The best way is to report the bug in the
[Issues section][ghi] on GitHub.

[ghi]: https://github.com/pyrmont/jekyll-tenji/issues

## Contributing

If you're interested in contributing to Tenji, feel free to fork and submit a 
pull request.

## Versioning

Tenji uses [Semantic Versioning 2.0.0][sv2].

[sv2]: http://semver.org/

## Licence

Tenji is released into the public domain. See [LICENSE.md][lc] for more details.

[lc]: https://github.com/pyrmont/jekyll-tenji/blob/master/LICENSE.md
