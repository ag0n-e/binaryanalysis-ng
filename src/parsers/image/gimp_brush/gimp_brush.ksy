meta:
  id: gimp_brush
  title: GIMP (GNU Image Manipulation Program) brush version 2 file
  license: CC0-1.0
  doc-ref: https://gitlab.gnome.org/GNOME/gimp/-/blob/master/devel-docs/gbr.txt
  endian: be
seq:
  - id: header_size
    type: u4be
  - id: version
    type: u4be
  - id: width
    type: u4be
  - id: height
    type: u4be
  - id: color_depth
    type: u4be
  - id: magic
    contents: GIMP
  - id: spacing
    type: u4be
  - id: brush_name
    type: strz
    size: header_size-1 - 28
    encoding: UTF-8
instances:
  body_size:
    value: width * height * color_depth
  body:
    pos: header_size
    size: body_size
