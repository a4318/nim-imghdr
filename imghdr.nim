# Nim module for determining the type of image files.
# Ported from Python's imghdr module.

# Written by Adam Chesak.
# Released under the MIT open source license.


## nim-imghdr is a Nim module for determining the type of image files.
##
## List of detectable formats:
##
## - PNG (Portable Network Graphics) format - ImageType.PNG
## - JPEG (Joint Photographic Experts Group) format (either JFIF or Exif) - ImageType.JPEG
## - GIF (Graphics Interchange Format) format - ImageType.GIF
## - TIFF (Tagged Image File Format) format - ImageType.TIFF
## - SVG (Scalable Vector Graphics) format - ImageType.SVG
## - SGI (Silicon Graphics workstation) format - ImageType.RGB
## - PBM (portable bitmap) format - ImageType.PBM
## - PGM (portable graymap) format - ImageType.PGM
## - PPM (portable pixmap) format - ImageType.PPM
## - PAM format - ImageType.PAM
## - BMP (bitmap) format - ImageType.BMP
## - XBM (X10 or X11 bitmap) format - ImageType.XBM
## - Rast (Sun raster) format - ImageType.Rast
## - CRW (Canon camera RAW) format - ImageType.CRW
## - CR2 (Canon camera RAW 2) format - ImageType.CR2
## - MRW (Minolta camera RAW) format - ImageType.MRW
## - X3F (Sigma camera RAW) format - ImageType.X3F
## - WEBP format - ImageType.WEBP
## - XCF (GIMP native) format - ImageType.XCF
## - GKSM (Graphics Kernel System) format - ImageType.GKSM
## - PM (XV image) format - ImageType.PM
## - FITS (Flexible Image Transport System) format - ImageType.FITS
## - XPM (X PixMap 1 and 3) format - ImageType.XPM
## - XPM2 (X PixMap 2) format - ImageType.XPM2
## - PS (PostScript) format - ImageType.PS
## - Xfig format - ImageType.Xfig
## - IRIS format - ImageType.IRIS
## - SPIFF (Still Picture Interchange File Format) format - ImageType.SPIFF
## - GEM (GEM Raster) format - ImageType.GEM
## - Amiga icon format - ImageType.Amiga
## - TIB (Acronis True Image) format - ImageType.TIB
## - JB2 (JBOG2) format - ImageType.JB2
## - CIN (Kodak Cineon) format - ImageType.CIN
## - PSP (Corel Paint Shop Pro) format - ImageType.PSP
## - EXR (OpenEXR) format - ImageType.EXR
## - CALS (CALS raster bitmap) format - ImageType.CALS
## - DPX (Society of Motion Picture and Television Engineers Digital Picture Exchange image) format - ImageType.DPX
## - SYM (Windows SDK graphics symbol) format - ImageType.SYM
## - SDR (SmartDraw Drawing) format - ImageType.SDR
## - IMG (Img Software Set Bitmap) format - ImageType.IMG
## - ADEX (ADEX Corp. ChromaGraph Graphics Card Bitmap Graphic) format - ImageType.ADEX
## - NITF (National Imagery Transmission Format) format - ImageType.NITF
## - BigTIFF (Big Tagged Image File Format; TIFF > 4 GB) format - ImageType.BigTIFF
## - GX2 (Show Partner graphics) format - ImageType.GX2
## - PAT (GIMP pattern) format - ImageType.PAT
## - CPT (Corel Photopaint) format - ImageType.CPT
## - SYW (Harvard Graphics symbol graphic) format - ImageType.SYW
## - DWG (generic AutoCAD drawing) format - ImageType.DWG
## - PSD (Photoshop image) format - ImageType.PSD
## - FBM (fuzzy bitmap) format - ImageType.FBM
## - HDR (Radiance High Dynamic Range image) format - ImageType.HDR
## - MP (Monochrome Picture TIFF bitmap) format - ImageType.MP
## - DRW (generic drawing) format - ImageType.DRW
## - Micrografx (Micrografx vector graphics) format - ImageType.Micrografx
## - PIC (generic picture) format - ImageType.PIC
## - VDI (Ventura Publisher/GEM VDI Image Format Bitmap) format - ImageType.VDI
## - ICO (Windows icon) format - ImageType.ICO
## - JP2 (JPEG-2000) format - ImageType.JP2
## - YCC (Kodak YCC image) format - ImageType.YCC
## - FPX (FlashPix) format - ImageType.FPX
## - DCX (Graphics Multipage PCX bitmap) format - ImageType.DCX
## - ITC format - ImageType.ITC
## - NIFF (Navy Image File Format) format - ImageType.NIFF
## - WMP (Windows Media Photo) format - ImageType.WMP
## - BPG format - ImageType.BPG
## - FLIF format - ImageType.FLIF
## - PDF (Portable Document Format) format - ImageType.PDF
## - Unknown format - ImageType.Other


import os
import strutils


proc int2ascii(i : seq[int8]): string =
    ## Converts a sequence of integers into a string containing all of the characters.

    let h = high(uint8).int + 1

    var s : string = ""
    for j, value in i:
        s = s & chr(value %% h)
    return s


proc `==`(i : seq[int8], s : string): bool =
    ## Operator for comparing a seq of ints with a string.

    return int2ascii(i) == s


type ImageType* {.pure.} = enum
    PNG, JPG, GIF, TIFF, RGB, PBM, PGM, PPM, PAM, BMP, XBM, CRW, CR2, SVG, MRW, X3F, WEBP, XCF,
    GKSM, PM, FITS, XPM, XPM2, PS, Xfig, IRIS, Rast, SPIFF, GEM, Amiga, TIB, JB2, CIN, PSP,
    EXR, CALS, DPX, SYM, SDR, IMG, ADEX, NITF, BigTIFF, GX2, PAT, CPT, SYW, DWG, PSD, FBM,
    HDR, MP, DRW, Micrografx, PIC, VDI, ICO, JP2, YCC, FPX, DCX, ITC, NIFF, WMP, BPG, FLIF, PDF,
    Other

proc getExt*(src: ImageType) : string =
    return ($src).toLowerAscii


proc testImage*(data : seq[int8]): ImageType {.gcsafe.}


proc testPNG(value : seq[int8]): ImageType =
    # tests: "\211PNG\r\n"
    return if value[1..3] == "PNG" and value[4] == 13 and value[5] == 10: PNG else: Other

var PNGmagic = [0x89.uint8, 0x50, 0x4e, 0x47]

proc checkPNG(value : ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "\211PNG\r\n" 89 50 4E 47
    return if equalMem(value[pos].addr, PNGmagic[0].addr, 4): PNG else: Other


proc testJFIF(value : seq[int8]): ImageType =
    # tests: "JFIF"
    return if value[6..9] == "JFIF": JPG else: Other

proc testJPEG(value : seq[int8]): ImageType =
    # tests: FFD8FFDB
    return if value[0] == 277 and value[1] == 216 and value[2] == 277 and value[3] == 219: JPG else: Other

var JFIFmagic = [0x4a.uint8, 0x46, 0x49, 0x46]

var EXIFmagic = [0x45.uint8, 0x78, 0x69, 0x66]

var noexif = [0xFF.uint8, 0xD8, 0xFF, 0xDB]

proc checkJPEG*(value : ptr UncheckedArray[uint8], pos: Natural): ImageType =
    # tests: "JFIF" 4a,46,49,46
    # tests: "Exif" 45,78,69,66
    # tests: FFD8FFDB
    return if equalMem(value[pos + 6].addr, JFIFmagic[0].addr, 4) or equalMem(value[pos + 6].addr, EXIFmagic[0].addr, 4) or equalMem(value[pos].addr, noexif[0].addr, 4) : JPG else: Other

proc testEXIF(value : seq[int8]): ImageType =
    # tests: "Exif"
    return if value[6..9] == "Exif": JPG else: Other

#[
proc checkJFIF(value : ptr UncheckedArray[uint8]): ImageType =
    # tests: "JFIF" 4a,46,49,46
    return if equalMem(value[6].addr, JFIFmagic[0].addr, 4): JPG else: Other


proc checkEXIF(value : ptr UncheckedArray[uint8]): ImageType =
    # tests: "Exif" 45,78,69,66
    return if equalMem(value[6].addr, EXIFmagic[0].addr, 4): JPG else: Other
]#

proc testGIF(value : seq[int8]): ImageType =
    # tests: "GIF87a" or "GIF89a"
    return if value[0..5] == "GIF87a" or value[0..5] == "GIF89a": GIF else: Other

var GIF1magic = [0x47.uint8, 0x49, 0x46, 0x38, 0x37, 0x61]
var GIF2magic = [0x47.uint8, 0x49, 0x46, 0x38, 0x39, 0x61]

proc checkGIF(value : ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "GIF87a" or "GIF89a"  47,49,46,38,39,61
    return if equalMem(value[pos].addr, GIF1magic[0].addr, 2) or equalMem(value[0].addr, GIF2magic[0].addr, 2): GIF else: Other


proc testTIFF(value : seq[int8]): ImageType =
    # tests: "MM" or "II"
    return if value[0..1] == "MM" or value[0..1] == "II": TIFF else: Other

var TIFF1magic = [0x4d.uint8, 0x4d]
var TIFF2magic = [0x49.uint8, 0x49]

proc checkTIFF(value : ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "MM" or "II"
    return if equalMem(value[pos].addr, TIFF1magic[0].addr, 2) or equalMem(value[pos].addr, TIFF2magic[0].addr, 2): TIFF else: Other


proc testRGB(value : seq[int8]): ImageType =
    # tests: "\001\332"
    return if value[0] == 1 and value[1] == 332: RGB else: Other

var RGBmagic = [0x01.uint8, 0xda]

proc checkRGB(value : ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "\001\332"
    return if equalMem(value[pos].addr, RGBmagic[0].addr, 2): RGB else: Other


proc testPBM(value : seq[int8]): ImageType =
    # tests: "P[1,4][ \t\n\r]"
    return if len(value) >= 3 and value[0] == 80 and (value[1] == 49 or value[1] == 52) and (value[2] == 32 or value[3] == 9 or value[2] == 10 or value[2] == 13): PBM else: Other

proc checkPBM(value : ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "P[1,4][ \t\n\r]"
    return if value[pos] == 0x50.uint8 and (value[pos + 1] == 0x31.uint8 or value[pos + 1] == 0x34.uint8) and (value[pos + 2] == 0x20.uint8 or value[pos + 2] == 0x09.uint8 or value[pos + 2] == 0x0A.uint8 or value[pos + 2] == 0x0D.uint8): PBM else: Other

proc testPGM(value : seq[int8]): ImageType =
    # tests: "P[2,5][ \t\n\r]"
    return if len(value) >= 3 and value[0] == 80 and (value[1] == 50 or value[1] == 53) and (value[2] == 32 or value[2] == 9 or value[2] == 10 or value[2] == 13): PGM else: Other


proc checkPGM(value : ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "P[2,5][ \t\n\r]"
    return if value[pos] == 0x50.uint8 and (value[pos + 1] == 0x32.uint8 or value[pos + 1] == 0x35.uint8) and (value[pos + 2] == 0x20.uint8 or value[pos + 2] == 0x09.uint8 or value[pos + 2] == 0x0A.uint8 or value[pos + 2] == 0x0D.uint8) : PGM else: Other


proc testPPM(value : seq[int8]): ImageType =
    # tests: "P[3,6][ \t\n\r]"
    return if len(value) >= 3 and value[0] == 80 and (value[1] == 51 or value[1] == 54) and (value[2] == 32 or value[2] == 9 or value[2] == 10 or value[2] == 13): PPM else: Other


proc checkPPM(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "P[3,6][ \t\n\r]"
    return if value[pos] == 0x50.uint8 and (value[pos + 1] == 0x33.uint8 or value[pos + 1] == 0x36.uint8) and (value[pos + 2] == 0x20.uint8 or value[pos + 2] == 0x09.uint8 or value[pos + 2] == 0x0A.uint8 or value[pos + 2] == 0x0D.uint8) : PPM else: Other


proc testPAM(value : seq[int8]): ImageType =
    # tests: "P7"
    return if value[0..1] == "P7": PAM else: Other

var PAMmagic = [0x50.uint8, 0x37]

proc checkPAM(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "P7" 50,37
    return if equalMem(value[pos].addr, PAMmagic[0].addr, 2): PAM else: Other


proc testBMP(value : seq[int8]): ImageType =
    # tests: "BM"
    return if value[0..1] == "BM": BMP else: Other

var BMPmagic = [0x42.uint8, 0x4d]

proc checkBMP(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "BM" 42,4d
    return if equalMem(value[pos].addr, BMPmagic[0].addr, 2): BMP else: Other


proc testXBM(value : seq[int8]): ImageType =
    # tests: "#define "
    return if value[0..6] == "#define ": XBM else: Other

var XBMmagic = [0x23.uint8, 0x64, 0x65, 0x66, 0x69, 0x6e, 0x65, 0x20]

proc checkXBM(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "#define " 23,64,65,66,69,6e,65,20
    return if equalMem(value[pos].addr, XBMmagic[0].addr, 8): XBM else: Other


proc testRast(value : seq[int8]): ImageType =
    # tests: "\x59\xA6\x6A\x95"
    return if value[0] == 89 and value[1] == 166 and value[2] == 106 and value[3] == 149: Rast else: Other

var Rastmagic = [0x59.uint8, 0xa6, 0x6a, 0x95]

proc checkRast(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "\x59\xA6\x6A\x95"
    return if equalMem(value[pos].addr, Rastmagic[0].addr, 4): Rast else: Other


proc testCRW(value : seq[int8]): ImageType =
    # tests: "II" and "HEAPCCDR"
    return if value[0..1] == "II" and value[6..12] == "HEAPCCDR": CRW else: Other

var CRW1magic = [0x49.uint8, 0x49]
var CRW2magic = [0x48.uint8, 0x45, 0x41, 0x50, 0x43, 0x43, 0x44, 0x52]

proc checkCRW(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
     # tests: "II" and "HEAPCCDR" 49, 49 and 48,45,41,50,43,43,44,52
    return if equalMem(value[pos].addr, CRW1magic[0].addr, 2) and equalMem(value[6].addr, CRW2magic[0].addr, 8): CRW else: Other


proc testCR2(value : seq[int8]): ImageType =
    # tests: ("II" or "MM") and "CR"
    return if (value[0..1] == "II" or value[0..1] == "MM") and value[8..9] == "CR": CR2 else: Other

var CR21magic = [0x49.uint8, 0x49]
var CR22magic = [0x4d.uint8, 0x4d]
var CR23magic = [0x43.uint8, 0x52]

proc checkCR2(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: ("II" or "MM") and "CR" (49,49 or 4d,4d) and 43,52
    return if (equalMem(value[pos].addr, CR21magic[0].addr, 2) or equalMem(value[pos].addr, CR22magic[0].addr, 2) ) and equalMem(value[pos + 8].addr, CR23magic[0].addr, 2) : CR2 else: Other


proc testSVG(value : seq[int8]): ImageType =
    # tests: "<?xml"
    # NOTE: this is a bad way of testing for an SVG, as it can easily fail (eg. extra whitespace before the xml definition)
    # TODO: write a better way. Might require changing from testing the first 32 bytes to testing everything, and using an
    # xml parser for ths one.
    return if value[0..4] == "<?xml": SVG else: Other

var SVGmagic = [0x3c.uint8, 0x3f, 0x78, 0x6d, 0x6c]

proc checkSVG(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "<?xml" 3c,3f,78,6d,6c
    # NOTE: this is a bad way of testing for an SVG, as it can easily fail (eg. extra whitespace before the xml definition)
    # TODO: write a better way. Might require changing from testing the first 32 bytes to testing everything, and using an
    # xml parser for ths one.
    return if equalMem(value[pos].addr, SVGmagic[0].addr, 5): SVG else: Other


proc testMRW(value : seq[int8]): ImageType =
    # tests: " MRM"
    return if value[0..3] == " MRM": MRW else: Other

var MRWmagic = [0x4d.uint8, 0x52, 0x4d]

proc checkMRW(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "MRM" 4d,52,4d
    return if equalMem(value[pos].addr, MRWmagic[0].addr, 3): MRW else: Other


proc testX3F(value : seq[int8]): ImageType =
    # tests: "FOVb"
    return if value[0..3] == "FOVb": X3F else: Other

var X3Fmagic = [0x46.uint8, 0x4f, 0x56, 0x62]

proc checkX3F(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "FOVb" 46,4f,56,62
    return if equalMem(value[pos].addr, X3Fmagic[0].addr, 4): X3F else: Other


proc testWEBP(value : seq[int8]): ImageType =
    # tests: "RIFF" and "WEBP"
    return if value[0..3] == "RIFF" and value[8..11] == "WEBP": WEBP else: Other

var WEBP1magic = [0x52.uint8, 0x49, 0x46, 0x46]
var WEBP2magic = [0x57.uint8, 0x45, 0x42, 0x50]

proc checkWEBP(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "RIFF" and "WEBP" 52,49,46,46 57,45,42,50
    return if equalMem(value[pos].addr, WEBP1magic[0].addr, 4) or equalMem(value[pos].addr, WEBP2magic[0].addr, 4): WEBP else: Other


proc testXCF(value : seq[int8]): ImageType =
    # tests: "gimp xcf"
    return if value[0..7] == "gimp xcf": XCF else: Other

var XCFmagic = [0x67.uint8, 0x69, 0x6d, 0x70, 0x20, 0x78, 0x63, 0x66]

proc checkXCF(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "gimp xcf" 67,69,6d,70,20,78,63,66
    return if equalMem(value[pos].addr, XCFmagic[0].addr, 8): XCF else: Other


proc testGKSM(value : seq[int8]): ImageType =
    # tests: "GKSM"
    return if value[0..3] == "GKSM": GKSM else: Other

var GKSMmagic = [0x47.uint8, 0x4b, 0x53, 0x4d]

proc checkGKSM(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "GKSM" 47,4b,53,4d
    return if equalMem(value[pos].addr, GKSMmagic[0].addr, 4): GKSM else: Other


proc testPM(value : seq[int8]): ImageType =
    # tests: "VIEW"
    return if value[0..3] == "VIEW": PM else: Other

var PMmagic = [0x56.uint8, 0x49, 0x45, 0x57]

proc checkPM(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "VIEW" 56,49,45,57
    return if equalMem(value[pos].addr, PMmagic[0].addr, 4): PM else: Other


proc testFITS(value : seq[int8]): ImageType =
    # tests: "SIMPLE"
    return if value[0..5] == "SIMPLE": FITS else: Other

var FITSmagic = [0x53.uint8, 0x49, 0x4d, 0x50, 0x4c, 0x45]

proc checkFITS(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "SIMPLE" 53,49,4d,50,4c,45
    return if equalMem(value[pos].addr, FITSmagic[0].addr, 6): FITS else: Other


proc testXPM(value : seq[int8]): ImageType =
    # tests: "/* XPM */"
    return if value[0..8] == "/* XPM */": XPM else: Other

var XPMmagic = [0x2f.uint8, 0x2a, 0x20, 0x58, 0x50, 0x4d, 0x20, 0x2a, 0x2f]

proc checkXPM(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "/* XPM */" 2f,2a,20,58,50,4d,20,2a,2f
    return if equalMem(value[pos].addr, XPMmagic[0].addr, 9): XPM else: Other


proc testXPM2(value : seq[int8]): ImageType =
    # tests: "! XPM2"
    return if value[0..5] == "! XPM2": XPM2 else: Other

var XPM2magic = [0x21.uint8, 0x20, 0x58, 0x50, 0x4d, 0x32]

proc checkXPM2(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "! XPM2" 21,20,58,50,4d,32
    return if equalMem(value[pos].addr, XPM2magic[0].addr, 6): XPM2 else: Other


proc testPS(value : seq[int8]): ImageType =
    # tests: "%!"
    return if value[0..1] == "%!": PS else: Other

var PSmagic = [0x25.uint8, 0x21]

proc checkPS(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "%!" 25,21
    return if equalMem(value[pos].addr, PSmagic[0].addr, 2): PS else: Other


proc testXFIG(value : seq[int8]): ImageType =
    # tests: "#FIG"
    return if value[0..3] == "#FIG": XFIG else: Other

var XFIGmagic = [0x23.uint8, 0x46, 0x49, 0x47]

proc checkXFIG(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "#FIG" 23,46,49,47
    return if equalMem(value[pos].addr, XFIGmagic[0].addr, 4): XFIG else: Other


proc testIRIS(value : seq[int8]): ImageType =
    # tests: 01 da
    return if value[0] == 1 and value[1] == 218: IRIS else: Other

var IRISmagic = [0x01.uint8, 0xda]

proc checkIRIS(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 01 da
    return if equalMem(value[pos].addr, IRISmagic[0].addr, 2): IRIS else: Other


proc testSPIFF(value : seq[int8]): ImageType =
    # tests: "SPIFF"
    return if value[6..10] == "SPIFF": SPIFF else: Other

var SPIFFmagic = [0x53.uint8, 0x50, 0x49, 0x46, 0x46]

proc checkSPIFF(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "SPIFF" 53,50,49,46,46
    return if equalMem(value[pos + 6].addr, SPIFFmagic[0].addr, 5): SPIFF else: Other


proc testGEM(value : seq[int8]): ImageType =
    # tests: EB 3C 90 2A
    return if value[0] == 235 and value[1] == 60 and value[2] == 144 and value[3] == 42: GEM else: Other

var GEMmagic = [0xeb.uint8, 0x3c, 0x90, 0x2a]

proc checkGEM(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: EB 3C 90 2A
    return if equalMem(value[pos].addr, GEMmagic[0].addr, 4): GEM else: Other


proc testAmiga(value : seq[int8]): ImageType =
    # tests: E3 10 00 01 00 00 00 00
    return if value[0] == 227 and value[1] == 16 and value[2] == 0 and value[3] == 1 and value[4] == 0 and value[5] == 0 and value[6] == 0 and value[7] == 0: Amiga else: Other

var Amigamagic = [0xe3.uint8, 0x10, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00]

proc checkAmiga(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: E3 10 00 01 00 00 00 00
    return if equalMem(value[pos].addr, Amigamagic[0].addr, 8): Amiga else: Other


proc testTIB(value : seq[int8]): ImageType =
    # tests: "´nhd"
    return if value[0..3] == "´nhd": TIB else: Other

var TIBmagic = [0xc2.uint8, 0xb4, 0x6e, 0x68, 0x64]

proc checkTIB(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "´nhd" c2,b4,6e,68,64
    return if equalMem(value[pos].addr, TIBmagic[0].addr, 5): TIB else: Other


proc testJB2(value : seq[int8]): ImageType =
    # tests: 97 and "JB2"
    return if value[0] == 151 and value[1..3] == "JB2": JB2 else: Other

var JB2magic = [0x97.uint8, 0x4a, 0x42, 0x32]

proc checkJB2(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 97 and "JB2" 97,4a,42,32
    return if equalMem(value[pos].addr, JB2magic[0].addr, 4): JB2 else: Other


proc testCIN(value : seq[int8]): ImageType =
    # tests: 80 2A 5F D7
    return if value[0] == 128 and value[1] == 42 and value[2] == 95 and value[3] == 215: CIN else: Other

var CINmagic = [0x80.uint8, 0x2a, 0x5f, 0xd7]

proc checkCIN(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 80 2A 5F D7
    return if equalMem(value[pos].addr, CINmagic[0].addr, 4): CIN else: Other


proc testPSP(value : seq[int8]): ImageType =
    # tests: "BK" and 00
    return if value[1..2] == "BK" and value[3] == 0: PSP else: Other

var PSPmagic = [0x42.uint8, 0x4b, 0x00]

proc checkPSP(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "BK" and 00 42,4b,00
    return if equalMem(value[pos + 1].addr, PSPmagic[0].addr, 3): PSP else: Other


proc testEXR(value : seq[int8]): ImageType =
    # tests: "v/1" and 01
    return if value[0..2] == "v/1" and value[2] == 1: EXR else: Other

var EXRmagic = [0x76.uint8, 0x2f, 0x31, 0x01]

proc checkEXR(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "v/1" and 01 76,2f,31, 01
    return if equalMem(value[pos].addr, EXRmagic[0].addr, 4): EXR else: Other


proc testCALS(value : seq[int8]): ImageType =
    # tests: "srcdocid:"
    return if value[0..8] == "srcdocid:": CALS else: Other

var CALSmagic = [0x73.uint8, 0x72, 0x63, 0x64, 0x6f, 0x63, 0x69, 0x64, 0x3a]

proc checkCALS(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "srcdocid:" 73,72,63,64,6f,63,69,64,3a
    return if equalMem(value[pos].addr, CALSmagic[0].addr, 8): CALS else: Other


proc testDPX(value : seq[int8]): ImageType =
    # tests: "XPDS" or "SDPX"
    return if value[0..3] == "XPDS" or value[0..3] == "SDPX": DPX else: Other

var DPX1magic = [0x58.uint8, 0x50, 0x44, 0x53]
var DPX2magic = [0x53.uint8, 0x44, 0x50, 0x58]

proc checkDPX(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "XPDS" or "SDPX" 58,50,44,53 53,44,50,58
    return if equalMem(value[pos].addr, DPX1magic[0].addr, 4) or equalMem(value[pos].addr, DPX2magic[0].addr, 4) : DPX else: Other


proc testSYM(value : seq[int8]): ImageType =
    # tests: "Smbl"
    return if value[0..3] == "Smbl": SYM else: Other

var SYMmagic = [0x53.uint8, 0x6d, 0x62, 0x6c]

proc checkSYM(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "Smbl" 53,6d,62,6c
    return if equalMem(value[pos].addr, SYMmagic[0].addr, 4): SYM else: Other


proc testSDR(value : seq[int8]): ImageType =
    # tests: "SMARTDRW"
    return if value[0..7] == "SMARTDRW": SDR else: Other

var SDRmagic = [0x53.uint8, 0x4d, 0x41, 0x52, 0x54, 0x44, 0x52, 0x57]

proc checkSDR(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "SMARTDRW" 53,4d,41,52,54,44,52,57
    return if equalMem(value[pos].addr, SDRmagic[0].addr, 8): SDR else: Other


proc testIMG(value : seq[int8]): ImageType =
    # tests: "SCMI"
    return if value[0..3] == "SCMI": IMG else: Other

var IMGmagic = [0x53.uint8, 0x43, 0x4d, 0x49]

proc checkIMG(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "SCMI" 53,43,4d,49
    return if equalMem(value[pos].addr, IMGmagic[0].addr, 4): IMG else: Other


proc testADEX(value : seq[int8]): ImageType =
    # tests: "PICT" and 00 08
    return if value[0..3] == "PICT" and value[4] == 0 and value[5] == 8: ADEX else: Other

var ADEXmagic = [0x50.uint8, 0x49, 0x43, 0x54, 0x00, 0x08]

proc checkADEX(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "PICT" and 00 08 50,49,43,54,00,08
    return if equalMem(value[pos].addr, ADEXmagic[0].addr, 6): ADEX else: Other


proc testNITF(value : seq[int8]): ImageType =
    # tests: "NITF0"
    return if value[0..4] == "NITF0": NITF else: Other

var NITFmagic = [0x4e.uint8, 0x49, 0x54, 0x46, 0x30]

proc checkNITF(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "NITF0" 4e,49,54,46,30
    return if equalMem(value[pos].addr, NITFmagic[0].addr, 5): NITF else: Other

proc testBigTIFF(value : seq[int8]): ImageType =
    # tests: "MM" and 00 2B
    return if value[0..1] == "MM" and value[2] == 0 and value[3] == 43: BigTIFF else: Other

var BigTIFFmagic = [0x4d.uint8, 0x4d, 0x00, 0x2b]

proc checkBigTIFF(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "MM" and 00 2B
    return if equalMem(value[pos].addr, BigTIFFmagic[0].addr, 4): BigTIFF else: Other


proc testGX2(value : seq[int8]): ImageType =
    # tests: "GX2"
    return if value[0..2] == "GX2": GX2 else: Other

var GX2magic = [0x47.uint8, 0x58, 0x32]

proc checkGX2(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "GX2" 47,58,32
    return if equalMem(value[pos].addr, GX2magic[0].addr, 3): GX2 else: Other


proc testPAT(value : seq[int8]): ImageType =
    # tests: "GPAT"
    return if value[0..3] == "GPAT": PAT else: Other

var PATmagic = [0x47.uint8, 0x50, 0x41, 0x54]

proc checkPAT(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "GPAT" 47,50,41,54
    return if equalMem(value[pos].addr, PATmagic[0].addr, 4): PAT else: Other


proc testCPT(value : seq[int8]): ImageType =
    # tests: "CPTFILE" or "CPT7FILE"
    return if value[0..6] == "CPTFILE" or value[0..7] == "CPT7FILE": CPT else: Other

var CPTmagic = [0x43.uint8, 0x50, 0x54, 0x46, 0x49, 0x4c, 0x45]
var CPT7magic = [0x43.uint8, 0x50, 0x54, 0x37, 0x46, 0x49, 0x4c, 0x45]

proc checkCPT(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "CPTFILE" or "CPT7FILE" 43,50,54,37,46,49,4c,45
    return if equalMem(value[pos].addr, CPTmagic[0].addr, 7) or equalMem(value[pos].addr, CPT7magic[0].addr, 8) : CPT else: Other


proc testSYW(value : seq[int8]): ImageType =
    # tests: "AMYO"
    return if value[0..3] == "AMYO": SYW else: Other

var SYWmagic = [0x41.uint8, 0x4d, 0x59, 0x4f]

proc checkSYW(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "AMYO" 41,4d,59,4f
    return if equalMem(value[pos].addr, SYWmagic[0].addr, 4): SYW else: Other


proc testDWG(value : seq[int8]): ImageType =
    # tests: "AC10"
    return if value[0..3] == "AC10": DWG else: Other

var DWGmagic = [0x41.uint8, 0x43, 0x31, 0x30]

proc checkDWG(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "AC10" 41,43,31,30
    return if equalMem(value[pos].addr, DWGmagic[0].addr, 4): DWG else: Other


proc testPSD(value : seq[int8]): ImageType =
    # tests: "8BPS"
    return if value[0..3] == "8BPS": PSD else: Other

var PSDmagic = [0x38.uint8, 0x42, 0x50, 0x53]

proc checkPSD(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "8BPS" 38,42,50,53
    return if equalMem(value[pos].addr, PSDmagic[0].addr, 4): PSD else: Other


proc testFBM(value : seq[int8]): ImageType =
    # tests: "%bitmap"
    return if value[0..6] == "%bitmap": FBM else: Other

var FBMmagic = [0x25.uint8, 0x62, 0x69, 0x74, 0x6d, 0x61, 0x70]

proc checkFBM(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "%bitmap" #25,62,69,74,6d,61,70
    return if equalMem(value[pos].addr, FBMmagic[0].addr, 7): FBM else: Other


proc testHDR(value : seq[int8]): ImageType =
    # tests: "#?RADIANCE"
    return if value[0..9] == "#?RADIANCE": HDR else: Other

var HDRmagic = [0x23.uint8, 0x3f, 0x52, 0x41, 0x44, 0x49, 0x41, 0x4e, 0x43, 0x45, 0x0a]

proc checkHDR(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "#?RADIANCE" #23 3f 52 41 44 49 41 4e 43 45 0a
    return if equalMem(value[pos].addr, HDRmagic[0].addr, 11): HDR else: Other


proc testMP(value : seq[int8]): ImageType =
    # tests: 0C ED
    return if value[0] == 12 and value[1] == 237: MP else: Other

var MPmagic = [0x0c.uint8, 0xed]

proc checkMP(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 0C ED
    return if equalMem(value[pos].addr, MPmagic[0].addr, 2): MP else: Other


proc testDRW(value : seq[int8]): ImageType =
    # tests: 07
    return if value[0] == 7: DRW else: Other

var DRWmagic = [0x07.uint8]

proc checkDRW(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 07
    return if equalMem(value[pos].addr, DRWmagic[0].addr, 1): DRW else: Other


proc testMicrografx(value : seq[int8]): ImageType =
    # tests: 01 FF 02 04 03 02
    return if value[0] == 1 and value[1] == 255 and value[2] == 2 and value[3] == 4 and value[4] == 3 and value[5] == 2: Micrografx else: Other

var Micrografxmagic = [0x01.uint8, 0xff, 0x02, 0x04, 0x03, 0x02]

proc checkMicrografx(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 01 FF 02 04 03 02
    return if equalMem(value[pos].addr, Micrografxmagic[0].addr, 6): Micrografx else: Other


proc testPIC(value : seq[int8]): ImageType =
    # tests: 01 00 00 00 01
    return if value[0] == 1 and value[1] == 0 and value[2] == 0 and value[3] == 0 and value[4] == 1: PIC else: Other

var PICmagic = [0x01.uint8, 0x00, 0x00, 0x00, 0x01]

proc checkPIC(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 01 00 00 00 01
    return if equalMem(value[pos].addr, PICmagic[0].addr, 5): PIC else: Other


proc testVDI(value : seq[int8]): ImageType =
    # tests: 00 01 00 08 00 01 00 01 01
    return if value[0] == 0 and value[1] == 1 and value[2] == 0 and value[3] == 8 and value[4] == 0 and value[5] == 1 and value[6] == 0 and
        value[7] == 1 and value[8] == 1: VDI else: Other

var VDImagic = [0x00.uint8, 0x01, 0x00, 0x08, 0x00, 0x01, 0x00, 0x01, 0x01]

proc checkVDI(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 00 01 00 08 00 01 00 01 01
    return if equalMem(value[pos].addr, VDImagic[0].addr, 9): VDI else: Other


proc testICO(value : seq[int8]): ImageType =
    # tests: 00 00 01 00
    return if value[0] == 0 and value[1] == 0 and value[2] == 1 and value[3] == 0: ICO else: Other

var ICOmagic = [0x00.uint8, 0x00, 0x01, 0x00]

proc checkICO(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 00 00 01 00
    return if equalMem(value[pos].addr, ICOmagic[0].addr, 4): ICO else: Other


proc testJP2(value : seq[int8]): ImageType =
    # tests: 00 00 00 0C and "jP"
    return if value[0] == 0 and value[1] == 0 and value[2] == 0 and value[3] == 12 and value[4..5] == "jP": JP2 else: Other

var JP2magic = [0x00.uint8, 0x00, 0x00, 0x0C, 0x6a, 0x50]

proc checkJP2(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 00 00 00 0C and "jP"
    # 0000 000C 6A50 2020 0D0A 870A #RFC 3745 - MIME Type Registrations for JPEG 2000 (ISO/IEC 15444) #https://datatracker.ietf.org/doc/html/rfc3745
    return if equalMem(value[pos].addr, JP2magic[0].addr, 6): JP2 else: Other


proc testYCC(value : seq[int8]): ImageType =
    # tests: 59 65 60 00
    return if value[0] == 59 and value[1] == 65 and value[2] == 60 and value[3] == 0: YCC else: Other

var YCCmagic = [0x59.uint8, 0x65, 0x60, 0x00]

proc checkYCC(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 59 65 60 00
    return if equalMem(value[pos].addr, YCCmagic[0].addr, 4): YCC else: Other


proc testFPX(value : seq[int8]): ImageType =
    # tests: 71 B2 39 F4
    return if value[0] == 113 and value[1] == 178 and value[2] == 57 and value[3] == 244: FPX else: Other

var FPXmagic = [0x71.uint8, 0xb2, 0x39, 0xf4]

proc checkFPX(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: 71 B2 39 F4
    return if equalMem(value[pos].addr, FPXmagic[0].addr, 4): FPX else: Other


proc testDCX(value : seq[int8]): ImageType =
    # tests: B1 68 DE 3A
    return if value[0] == 177 and value[1] == 104 and value[2] == 222 and value[3] == 58: DCX else: Other

var DCXmagic = [0xb1.uint8, 0x68, 0xde, 0x3a]

proc checkDCX(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: B1 68 DE 3A
    return if equalMem(value[pos].addr, DCXmagic[0].addr, 4): DCX else: Other


proc testITC(value : seq[int8]): ImageType =
    # tests: F1 00 40 BB
    return if value[0] == 241 and value[1] == 0 and value[2] == 64 and value[3] == 187: ITC else: Other

var ITCmagic = [0xf1.uint8, 0x00, 0x40, 0xbb]

proc checkITC(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: F1 00 40 BB
    return if equalMem(value[pos].addr, ITCmagic[0].addr, 4): ITC else: Other


proc testNIFF(value : seq[int8]): ImageType =
    # tests: "IIN1"
    return if value[0..3] == "IIN1": NIFF else: Other

var NIFFmagic = [0x49.uint8, 0x49, 0x4e, 0x31]

proc checkNIFF(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "IIN1"
    return if equalMem(value[pos].addr, NIFFmagic[0].addr, 4): NIFF else: Other


proc testWMP(value : seq[int8]): ImageType =
    # tests: "II" and BC
    return if value[0..1] == "II" and value[2] == 188: WMP else: Other

var WMPmagic = [0x49.uint8, 0x49, 0xbc]

proc checkWMP(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "II" and BC
    return if equalMem(value[pos].addr, WMPmagic[0].addr, 3): WMP else: Other

proc testBPG(value : seq[int8]): ImageType =
    # tests: "BPG" and FB
    return if value[0..2] == "BPG" and value[3] == 251: BPG else: Other

var BPGmagic = [0x42.uint8, 47, 44, 0xFB]

proc checkBPG(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "BPG" and FB
    return if equalMem(value[pos].addr, BPGmagic[0].addr, 4): BPG else: Other


proc testFLIF(value : seq[int8]): ImageType =
    # tests: "FLIF"
    return if value[0..3] == "FLIF": FLIF else: Other

var FLIFmagic = [0x46.uint8, 0x4c, 0x49, 0x46]

proc checkFLIF(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "FLIF"
    return if equalMem(value[pos].addr, FLIFmagic[0].addr, 4): FLIF else: Other


proc testPDF(value: seq[int8]): ImageType =
    # tests: "%PDF"
    return if value[0..3] == "%PDF": PDF else: Other

var PDFmagic = [0x25.uint8, 0x50, 0x44, 0x46]

proc checkPDF(value: ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    # tests: "%PDF"
    return if equalMem(value[pos].addr, PDFmagic[0].addr, 4): PDF else: Other


proc testImage*(file : File): ImageType {.gcsafe.} =
    ## Determines the format of the image file given.

    var data = newSeq[int8](32)
    discard file.readBytes(data, 0, 32)
    return testImage(data)


proc testImage*(filename : string): ImageType {.gcsafe.} =
    ## Determines the format of the image with the specified filename.

    var file : File = open(filename)
    var format : ImageType = testImage(file)
    file.close()
    return format


proc testImage*(data : seq[int8]): ImageType =
    ## Determines the format of the image from the bytes given.

    let testers = @[testPNG, testJFIF, testEXIF, testJPEG, testGIF, testTIFF, testRGB, testPBM,
        testPGM, testPPM, testPAM, testBMP, testXBM, testRast, testCRW, testCR2,
        testSVG, testMRW, testX3F, testWEBP, testXCF, testGKSM, testPM, testFITS,
        testXPM, testXPM2, testPS, testXFIG, testIRIS, testSPIFF, testGEM, testAmiga,
        testTIB, testJB2, testCIN, testPSP, testEXR, testCALS, testDPX, testSYM,
        testSDR, testIMG, testADEX, testNITF, testBigTIFF, testGX2, testPAT, testCPT,
        testSYW, testDWG, testPSD, testFBM, testHDR, testMP, testDRW, testMicrografx,
        testPIC, testVDI, testICO, testJP2, testYCC, testFPX, testDCX, testITC,
        testNIFF, testWMP, testBPG, testFLIF, testPDF
    ]

    for tester in testers:
        if tester(data) != Other:
            return tester(data)
    return Other

proc checkImage*(data : ptr UncheckedArray[uint8], pos: Natural = 0): ImageType =
    let checkers = @[checkJPEG, checkPNG, checkGIF, checkTIFF, checkRGB, checkPBM,
        checkPGM, checkPPM, checkPAM, checkBMP, checkXBM, checkRast, checkCRW, checkCR2,
        checkSVG, checkMRW, checkX3F, checkWEBP, checkXCF, checkGKSM, checkPM, checkFITS,
        checkXPM, checkXPM2, checkPS, checkXFIG, checkIRIS, checkSPIFF, checkGEM, checkAmiga,
        checkTIB, checkJB2, checkCIN, checkPSP, checkEXR, checkCALS, checkDPX, checkSYM,
        checkSDR, checkIMG, checkADEX, checkNITF, checkBigTIFF, checkGX2, checkPAT, checkCPT,
        checkSYW, checkDWG, checkPSD, checkFBM, checkHDR, checkMP, checkDRW, checkMicrografx,
        checkPIC, checkVDI, checkICO, checkJP2, checkYCC, checkFPX, checkDCX, checkITC,
        checkNIFF, checkWMP, checkBPG, checkFLIF, checkPDF
    ]

    for checker in checkers:
        let a = checker(data, pos)
        if a != Other:
            return a
    return Other


# When run as it's own program, determine the type of the provided image file:
when isMainModule:

    if paramCount() < 1:
        echo("Invalid number of parameters. Usage:\nimghdr [filename1] [filename2] ...")

    for i in 1..paramCount():
        echo("Detected file type for \"" & paramStr(i) & "\": " & $testImage(paramStr(i)))
