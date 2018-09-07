## Configuration

This document describes how a user can configure Tenji.

### Overview

There are three levels to Tenji's configuration options:

1. system options;
2. default gallery options; and
3. specific gallery options.

System options and default gallery options are defined in the user's
Jekyll configuration file (by default `_config.yml`) under the `galleries` key.
Specific gallery options are defined in the frontmatter of a given gallery's
`index` file.

Tenji uses a convention over configuration approach. If a user does not
expressly define a configuration option, Tenji will use the default value
defined in {Tenji::Config::DEFAULTS}.

### Site Options

The site option keys are defined immediately under the `galleries` key. The
keys are presented here alphabetically but may be defined in any order.

#### `cover`

default
: `{ 'resize' => 'fit', 'x' => 200, 'y' => 200 }`

details
: This defines the settings for the cover thumbnail that is generated for each
  gallery. The value must be a hash with a `resize` key that defines the type of
  resize function that will be used by ImageMagick. The permitted values are
  `'fill'` and `'fit'`. If the value is `'fill'`, the user must define integer
  values for both `x` and `y`. If the value is `'fit'`, the user may define
  integer values for either or both of `x` and `y`.

#### `galleries_dir`

default
: `'_albums'`

details
: This is the name of the directory at the source level of the Jekyll site that
  contains the galleries. In order to avoid being processed by Jekyll as a
  normal directory, the name must begin with an underscore. Tenji will output
  the galleries into a directory with the same name, minus the leading
  underscore.

#### `galleries_per_page`

default
: `10`

details
: This is the number of galleries to display on the gallery list page before
  the page should be paginated. If the value is set to `false`, pagination will
  be disabled.

#### `layout_list`

default
: `'gallery_list'`

details
: This is the name of the layout to be used when generating the list page. If a
  layout with this name does not exist in the `_layouts` directory, Jekyll will
  fail when building the site.

#### `list_index`

default
: `true`

details
: There may be situations where a user does not want Tenji to generate a list
  page. The common case when this occurs is if the user is creating a site that
  will list the galleries on the site's top-level index page. Note that Tenji
  exposes the galleries available to Liquid templates via the `tenji` object.
  See the {file:Templates.md} document for more information. This value must be
  either `true` or `false`.

#### `scale_max`

default
: `2`

details
: A key feature of Tenji is its support for generating multiple versions of an
  image for display on screens of different pixel densities. A user can control
  the number of versions that will be created by setting the maximum scaling
  factor.

#### `scale_suffix`

default
: `'-#x`

details
: This is the suffix that will be appended to thumbnails that are generated for
  different scaling factors. The value must be a string and must contain the `#`
  character. Tenji will replace this character with the scaling factor of the
  relevant thumbnail.

#### `sort`

default
: `{ 'name' => 'desc', 'time' => 'desc' }`

details
: This hash contains the sorting options for galleries. Two keys are permitted,
  `name` and `time`. The `name` key refers to the way in which Tenji will sort
  galleries when comparing the directory names. The `time` key refers to the
  way in which Tenji will sort galleries when comparing the `period` value of
  the gallery (if set for the given gallery). The `name` key can be associated
  with the values `'asc'` and `'desc'`. The `time` key can be associated with the
  values `'asc'`, `'desc'` and `'ignore'`. As the value suggests, if `time` is
  set to `'ignore'`, Tenji will ignore the date and time value in a gallery's
  `period`.

#### `thumbs_dir`

default
: `_thumbs`

details
: This is the name of the directory at the source level of the Jekyll site that
  contains the thumbnails. Because thumbnail generation is the slowest aspect
  of building the site, Tenji puts all generated thumbnails into the
  `thumbs_dir` and checks this directory before generation. Tenji will only
  generate a new thumbnail for a given size if the source image has been
  modified more recently than the existing thumbnail (or if no thumbnail
  exists). This also means that a user can generate their own thumbnails if
  they prefer.

### Default Gallery Options

The default gallery option keys are defined immediately under the
`gallery_settings` key. The keys are presented here alphabetically but may be
defined in any order.

#### `cover`

default
: `nil`

details
: This is the filename of the image within a given gallery to use as the source
  for the cover image for that gallery. The filename should be relative to the
  gallery directory (eg. `'image.jpg'`). If the value for a given gallery is
  `nil`, Tenji will use the first image (after sorting) as the source.

#### `downloadable`

default
: `true`

details
: This determines whether the source image will be downloadable. If the image is
  downloadable, Tenji will copy it to the destination directory and the `image`
  object that is exposed to Liquid templates will return true when the method
  `#downloadable?` is called. The value must be either `true` or `false`.

#### `hidden`

default
: `false`

details
: This determines whether the gallery is treated by Tenji as being a hidden
  gallery. Hidden galleries have the following characteristics: (1) they do not
  appear in the list page; (2) they are not included under the `galleries` key
  in the `tenji` object (see the {file:Templates.md} document for more
  information); and (3) the directory name is obfuscated in the destination
  directory (eg. a directory called `gallery` in the source directory would be
  written as `Z2FsbGVyeQ` in the destination directory). The value must be
  either `true` or `false`.

#### `images_per_page`

default
: `25`

details
: This is the number of images to display on a gallery page before the page
  should be paginated. If the value is set to `false`, pagination will be
  disabled.

#### `layout_gallery`

default
: `'gallery_index'`

details
: This is the name of the layout to be used when generating the gallery page. If
  a layout with this name does not exist in the `_layouts` directory, Jekyll
  will fail when building the site.

#### `layout_single`

default
: `'gallery_single'`

details
: This is the name of the layout to be used when generating the individual page
  for each image in a gallery (if `single_pages` is set to `true`). If a layout
  with this name does not exist in the `_layouts` directory, Jekyll will fail
  when building the site.

#### `single_pages`

default
: `true`

details
: This determines whether Tenji will generate individual pages for each image
  within a gallery. The value must be either `true` or `false`.

#### `sizes`

default
: `{ 'small' => { 'resize' => 'fit', 'x' => 400 } }`

details
: This is a list of settings that will be used by Tenji to determine what
  thumbnails to generate for a given gallery. As with the `cover` site option,
  the value for each size must be a hash with a `resize` key that defines the
  type of resize function that will be used by ImageMagick. The permitted values
  are `'fill'` and `'fit'`. If the value is `'fill'`, the user must define
  integer values for both `x` and `y`. If the value is `'fit'`, the user may
  define integer values for either or both of `x` and `y`. In contrast to the
  `cover` site option, the `sizes` option must associate each setting with a
  key that represents the name of that size. Names are arbitrary and have no
  inherent meaning within Tenji.

#### `sort`

default
: `{ 'name' => 'asc', 'time' => 'asc' }`

details
: This hash contains the sorting options for images. Two keys are permitted,
  `name` and `time`. The `name` key refers to the way in which Tenji will sort
  images when comparing the image filename. The `time` key refers to the
  way in which Tenji will sort images when comparing the date and time of the
  image in the EXIF data for that image (if it exists). The `name` key can be
  associated with the values `'asc'` and `'desc'`. The `time` key can be associated
  with the values `'asc'`, `'desc'` and `'ignore'`. As the value suggests, if
  `time` is set to `'ignore'`, Tenji will ignore the date and time value in an
  image's EXIF data.

### Specific Gallery Options

As noted above, specific gallery options are defined in the frontmatter of a
given gallery's `index` file. In addition to all of the default gallery options
(all of which may be redefined for a given gallery using the same keys), there is
one additional option.

#### `period`

details
: This represents the period during which the images in the gallery were
  created. The period can be expressed as either a single date or as a period
  between two dates separated by a `-`. The value must be written as a string.
  Tenji uses Ruby's [Date::parse](https://ruby-doc.org/stdlib/libdoc/date/rdoc/Date.html#method-c-parse)
  method to parse the dates.