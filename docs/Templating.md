## Templating Tenji

This document describes how a user should prepare the templates necessary to 
use Tenji.

### Introduction

Tenji generates three types of pages:

1. zero or one {Tenji::ListPage} objects;
2. one or more {Tenji::GalleryPage} objects; and
3. zero or more {Tenji::ImagePage} objects.

As with any other `Jekyll::Page` object. Jekyll will look for the appropriate 
Liquid template and use that to render the page. See 
[the Jekyll documentation][jd] for more information on Liquid templates.

[jd]: https://jekyllrb.com/docs/liquid/

### Default Templates

By default, each type of page uses a different template:

1. {Tenji::ListPage} uses `gallery_list.html`;
2. {Tenji::GalleryPage} uses `gallery_index.html`; and 
3. {Tenji::ImagePage} uses `gallery_single.html`.

The user **must define these files** and put them in their template directory. 
By default, this is the `_layout` directory within their source directory. The 
Jekyll build process will fail if the necessary template is not provided.

#### Changing the Defaults

The default values are defined in {Tenji::Config}. A user can specify their own 
defaults by setting one or more of the `layout_list`, `layout_gallery` and 
`layout_single` keys in their configuration file. For example:

```yaml
galleries:
  layout_list: my_list_template.html
  gallery_settings:
    layout_gallery: my_gallery_template.html
    layout_single:  my_single_template.html
```

See {file:docs/Configuring.md} 
for more information on how to configure Tenji.

Alternatively, a user can specify a specific template for a page as they can 
with any Jekyll page: by adding a `layout` attribute to the frontmatter of the 
respective file. Tenji will prefer the frontmatter value over the value in the 
configuration file and will prefer the value in the confirmation file over the 
default value set in {Tenji::Config}.

### Custom Filters

Tenji provides the following filters for use in Liquid templates:

* #### `format_datetime`

This filter formats a date and time with an optional format provided. The
format string is the same as used by Ruby's [DateTime#strftime][rd-dt]. If a
format is not provided, the default is `'%e %B %Y'`.

[rd-dt]: https://ruby-doc.org/stdlib/libdoc/date/rdoc/DateTime.html#method-i-strftime

```liquid
{{ obj.time | format_datetime }} 
{{ obj.time | format_datetime: '%e %B %Y' }}
```

* #### `format_period`

This filter formats a period with an optional format and separator provided. The
format string is the same as used by Ruby's [DateTime#strftime][rd-dt]. If a
format is not provided, the default is `'%e %B %Y'` and if a separator is not
provided, the default is `'&ndash;'`.

```liquid
{{ obj.period | format_period }}
{{ obj.period | format_period: '%e %B %Y' }}
{{ obj.period | format_period: '%e %B %Y', '&ndash;' }}
```

* #### `to_dd`

This filter converts an array of numbers into a coordinate in decimal degree 
notation.

```liquid
{{ obj.coordinate | to_dd }}
```

* #### `to_dms`

This filter converts an array of numbers into a coordinate in decimal minute
second notation. The user can set whether the coordinate is a latitude (
`'lat'`) or longitude (`'long'`) coordinate. If this type is not provided, the
default value is `'lat'`. Additionally, the user can set a format for the
output. If a format is not provided, the default format is
`'%{d}&deg; %{m}&prime; %{s}&Prime; %{h}'`. The format string uses the 
following named references: `d` for degree, `m` for minute, `s` for second, `h` 
for the hemisphere.

```liquid
{{ obj.coordinate | to_dms }}
{{ obj.coordinate | to_dms: 'lat' }}
{{ obj.coordinate | to_dms: 'lat', '%{d}&deg; %{m}&prime; %{s}&Prime; %{h} }}
```

* #### `to_float`

This filter converts a number into a string in floating point notation.

```liquid
{{ obj.number | to_float }}
```

* #### `to_srcset`

This filter converts a URL into a format appropriate for the `srcset` attribute
in a `<source>` tag. The output depends on the `scale_max` and `scale_suffix`
settings (see {file:docs/Configuring.md} on how to define these). 

Assuming the default settings, the output for the URL `'image.jpg'` would be
`'image.jpg, image-2x.jpg 2x'`.

```liquid
{{ obj.url | to_srcset }}
```

### Other Templates

While Tenji generates all the pages necessary to display the images saved in the 
galleries directory, a user may wish to incorporate Tenji galleries into other 
pages within their Jekyll site. Tenji adds a `tenji` object to the site payload 
that is accessible from templates and includes. The `tenji` object exposes three 
attributes: `all_galleries`, `galleries` and `hidden_galleries`.

Here's an example of an include that displays all the hidden galleries:

```html
{% for gallery in tenji.hidden_galleries %}
    <li>
      <a href="{{ gallery.url }}">
        <picture>
          <source srcset="{{ gallery.cover.url | to_srcset }}">
          <img src="{{ gallery.cover.url }}"> 
        </picture>
        <h3>{{ gallery.title }}</h3>
        <p>{{ gallery.description }}</p>
      </a>
    </li>
 {% endfor %}
```
