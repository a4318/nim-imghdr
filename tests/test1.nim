import unittest
import memfiles

import imghdr

test "check PNG":
  let f = memfiles.open("tests/images/test.png", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == PNG

test "check JFIF":
  let f = memfiles.open("tests/images/JFIF.jpg", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == JPEG

test "check EXIF":
  let f = memfiles.open("tests/images/Exif.JPG", mode = fmRead, mappedSize = -1)

  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == JPEG

test "check without JFIF or Exif":
  let f = memfiles.open("tests/images/FFD8FFDB.jpeg", mode = fmRead, mappedSize = -1)

  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == JPEG

test "check JPG in binary format":
  let f = memfiles.open("tests/images/FFD8FFDB2.jpg", mode = fmRead, mappedSize = -1)

  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem), 1) == JPEG

test "test without JFIF or Exif":
  let f = memfiles.open("tests/images/FFD8FFDB.jpeg", mode = fmRead, mappedSize = -1)

  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == JPEG

test "check GIF89a":
  let f = memfiles.open("tests/images/test.gif", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == GIF

test "check TIFF":
  let f = memfiles.open("tests/images/test.tiff", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == TIFF

test "check RGB":
  let f = memfiles.open("tests/images/test.rgb", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == RGB

test "test PGM":
  check testImage("tests/images/test.pgm") == PGM

test "check PBM":
  let f = memfiles.open("tests/images/test.pbm", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == PBM


test "check PGM":
  let f = memfiles.open("tests/images/test.pgm", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == PGM

test "check PPM":
  let f = memfiles.open("tests/images/test.ppm", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == PPM

test "check PAM":
  let f = memfiles.open("tests/images/test.pam", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == PAM

test "check BMP":
  let f = memfiles.open("tests/images/test.bmp", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == BMP

test "check XBM":
  let f = memfiles.open("tests/images/test.xbm", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == XBM

test "check Rast":
  let f = memfiles.open("tests/images/test.ras", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == Rast

#[
test "check CRW":
  let f = memfiles.open("tests/images/test.crw", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == CRW

test "check CR2":
  let f = memfiles.open("tests/images/test.cr2", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == CR2

test "check MRW":
  let f = memfiles.open("tests/images/test.mrw", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == MRW

test "check X3F":
  let f = memfiles.open("tests/images/test.x3f", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == X3F
]#

test "check WEBP":
  let f = memfiles.open("tests/images/test.webp", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == WEBP

test "check XCF":
  let f = memfiles.open("tests/images/test.xcf", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == XCF

#[
test "check GKSM":
  let f = memfiles.open("tests/images/test.gks", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == GKSM

test "check PM":
  let f = memfiles.open("tests/images/test.pm", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == PM

]#

test "check FITS":
  let f = memfiles.open("tests/images/test.fits", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == FITS

test "check XPM":
  let f = memfiles.open("tests/images/test.xpm", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == XPM

test "check XPM2":
  let f = memfiles.open("tests/images/test2.xpm", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == XPM2

test "check PostScript":
  let f = memfiles.open("tests/images/test.ps", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == PS

#[
test "check XFIG:
  let f = memfiles.open("tests/images/test.xfig", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == XFIG

test "check IRIS":
  let f = memfiles.open("tests/images/test.iris", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == IRIS

test "check SPIFF":
  let f = memfiles.open("tests/images/test.spf", mode = fmRead, mappedSize = -1)
  check checkImage(cast[ptr UncheckedArray[uint8]](f.mem)) == SPIFF
]#
