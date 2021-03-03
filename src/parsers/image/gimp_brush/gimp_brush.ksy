meta:
  id: gimp_brush
  title: GIMP (GNU Image Manipulation Program) brush version 2 file
  file-extension: gbr
  license: CC0-1.0
  endian: be
doc-ref: https://gitlab.gnome.org/GNOME/gimp/-/raw/master/devel-docs/gbr.txt
seq:
  - id: header_size
    type: u4be
  - id: header
    type: header
    size: header_size
types:
  header:
    seq:
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
        size-eos: true
        encoding: UTF-8
instances:
  body_size:
    value: header.width * header.height * header.color_depth
  body:
    pos: header_size
    size: body_size
