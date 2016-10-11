
Goal
----

The current goals of this gem is :
- to manage all the raw RGBA encodings that are used in OpenGL
  softwares, and convert colors from one encoding to the
  other.
- to extract the encoded color components from popular image
  file formats, like BMP, PNG and JPEG. Currently, only
  uncompressed BMP is supported.

**TODO - Manage the extraction of :**
- [ ] Compressed BMP color components
- [ ] PNG color components
- [ ] JPEG color components

The provided binary convert uncompressed BMP content to raw formats with
different encodings, with a special header that can be used by OpenGL
programs to load the texture directly.

Library Usage
-------------

```ruby
require 'myy-color'

# Encoding / Decoding

encoded_rgba8888 = (200 << 24 | 125 << 16 | 187 << 8 | 127)
decoded_rgba8888 = MyyColor.decode(encoded_rgba8888, encoding: :rgba8888)
# => [200, 125, 187, 127]
encoded_rgba5551 = MyyColor.encode(*decoded_rgba8888, encoding: :rgba5551)
# => 52206
decoded_rgba5551 = MyyColor.decode(encoded_rgba5551, encoding: :rgba5551)
# => [200, 120, 184, 0]
encoded_argb8888 = MyyColor.encode(*decoded_rgba5551, encoding: :argb8888)
# => 13138104
decoded_argb8888 = MyyColor.decode(encoded_argb8888, encoding: :argb8888)
# => [200, 120, 184, 0]

# Get raw content of BMP

raw = MyyColor::BMP.convert_content(filename: "test.bmp",
                                    from: :rgba8888,
                                    to: :rgba4444)
raw[:content]
# => [first_encoded_pixel, second_encoded_pixel, ..., last_encoded_pixel]
raw[:metadata]
# => {width: width (As specified in the BMP header !),
#    height: height (As specified in the BMP header !)}
# Print the following in stderr
#   [Read] width : 137 (89) -- height : 10 (0a)
#   [Read] Starting from : 0x8a
#   Encoded pixels : 1370 - By width : 10

# Convert BMP to raw for use in OpenGL

MyyColor::BMP.convert_bmp(bmp_filename: "test.bmp",
                          raw_filename: "test.raw",
                          from: :argb8888,
                          to: :rgba5551)
# Generate a test.raw file
```

**TODO : Currently, all colors components are implicitly represented by
  normalised values in the range [0,255].
  This is not very terribly flexible.** 
  
One improvement would be to :
- represent the colors with data structures containing all
  the necessary informations (currently encoded value,
  max possible value in the encoding it comes from, ...)
- rewrite all the encoding procedures around the use of these
  data structures instead.

Usage
-----

`myy_bmp2raw file.bmp argb8888 converted.raw rgba4444`

This add the following header to the Raw image :

Offset | Use
-------|----
0x0 | Width
0x4 | Height
0x8 | glTexImage2D format
0xc | glTexImage2D type

Here follows some sample code that can be used to load such library.
**TODO : Provide this example as a C file, directly in the source tree.**
**TODO : Provide a binary that generate a ready to compile minimalist
  OpenGL/EGL example that loads such raw file as a texture.**

```c
  #include <fcntl.h> // open
  #include <stdio.h> // fprintf
  #include <stdlib.h> // free, abort
  #include <string.h> // malloc
  #include <unistd.h> // close
  #include <sys/types.h> // read
  #include <sys/stat.h> // stat

  ...

  tex_filename = "texture_filename.raw";
  int n_textures = 1;
  int textures_id_array[n_textures];
  int current_tex = 0;
  struct stat fstat_results;
  glGenTextures(n_textures, textures_id_array);
  int fd = open(tex_filename, O_RDONLY);
  if (fd != 1) {
    fstat(fd, &fstat_results);
    unsigned int width, height, gl_format, gl_type, bytes_read;
    read(fd, &width, 4);
    read(fd, &height, 4);
    read(fd, &gl_format, 4);
    read(fd, &gl_type, 4);
    char *buffer = malloc(fstat_results.st_size);
    if (buffer) {
      bytes_read = read(fd, buffer, fstat_results.st_size);
      fprintf(stderr, "Texture : %s, Width : %u, Height : %u,\\n"
                        "Format : %x, Type : %x\\n"
                        "Read : %d bytes\\n",
                        tex_filename,
                        width, height, gl_format, gl_type, bytes_read);
      close(fd);
      glBindTexture(GL_TEXTURE_2D, textures_id_array[current_tex]);
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, gl_format, gl_type, buffer);
      glGenerateMipmap(GL_TEXTURE_2D);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
      free(buffer);
      return;
    }
    else {
      fprintf(stderr, "Malloc failed to allocated %zd bytes\\n",
              fstat_results.st_size);
      abort();
    }
  }
  else {
     fprintf(stderr, "Could not open file %s (Not found ?)\\n",
             tex_filename);
     abort();
  }
```

Tipping
-------

[Pledgie](https://pledgie.com/campaigns/32702)

BTC : 16zwQUkG29D49G6C7pzch18HjfJqMXFNrW

[![Tip with Altcoins](https://shapeshift.io/images/shifty/small_light_altcoins.png)](https://shapeshift.io/shifty.html?destination=16zwQUkG29D49G6C7pzch18HjfJqMXFNrW&output=BTC)
