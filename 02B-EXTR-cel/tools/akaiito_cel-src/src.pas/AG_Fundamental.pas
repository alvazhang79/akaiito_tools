{
  AnimED - Visual Novel Tools
  Basic functions & extensions of EDGE image library
  Copyright � 2007-2010 WinKiller Studio. Open Source.
  This software is free. Please see License for details.
}

unit AG_Fundamental;

interface

uses Classes, Sysutils, AnimED_Math;

type
{ ARGB palette table }
 TARGB = packed record
  B : byte; // Blue
  G : byte; // Green
  R : byte; // Red
  A : byte; // Alpha (partial transparency color)
 end;

{ RGB palette table }
 TRGB = packed record
  B : byte;
  G : byte;
  R : byte;
 end;

 TPalette = packed record
  Palette : array[0..255] of TARGB;
 end;

 TTGAPalette = packed record
  Palette : array[0..255] of TRGB;
 end;

{ Converts between RGB and ARGB }
function ARGBtoRGB(ARGB : TARGB) : TRGB;
function RGBtoARGB(RGB : TRGB) : TARGB;

{ Converts between RGB and ARGB palettes }
function ARGBPtoRGBP(Palette : TPalette) : TTGAPalette;
function RGBPtoARGBP(TGAPalette : TTGAPalette) : TPalette;

{ Generates grayscale palette }
function GrayscalePalette : TPalette;

{ Generates blank palette (resets to zeroes) }
function NullPalette : TPalette;

{ Calculates the length of palette in ARGB (i.e. GetPaletteLength returns number
  of colors in palette, not it's size in bytes)... }
function GetPaletteColors(BitDepth : byte) : integer;
{ ...but this one returns size of palette in bytes :) }
function GetPaletteSize(BitDepth : byte) : integer;

{ Swaps colors in image stream }
procedure SwapColors(var InputStream : TStream; Width, Height, BitDepth, Operation : integer);

{ Swaps colors in 24-bit RGB }
function SwapColors24(RGB : TRGB; Operation : integer) : TRGB;

{ Swaps colors in 32-bit ARGB }
function SwapColors32(ARGB : TARGB; Operation : integer) : TARGB;

{ Flips stream backwards }
procedure StreamFlip(InputStream : TStream);

{ Wrapper for VerticalFlipIO. Made for compatibility }
procedure VerticalFlip(InputStream : TStream; ScanlineLen, Height : integer);
{ Vertically flips RAW image of any type, except for 1-bit images }
procedure VerticalFlipIO(InputStream, OutputStream : TStream; ScanLineLen, Height : integer);

{ Interleaves \ Deinterleaves RAW image stream }
procedure InterleaveStream(InputStream, OutputStream : TStream; Width, Height, BitDepth : integer);
procedure DeInterleaveStream(InputStream, OutputStream : TStream; ScanlineLen, Gap, Height : integer);

{ Calculates the size of interleaved scanline }
function GetScanlineLen(Width, BitDepth : integer) : integer;
function GetScanlineGap(Width, BitDepth : integer) : integer;

{ Calculates the size of non-interleaved (TGA-like) scanline }
function GetScanlineLen2(Width, BitDepth : integer) : integer;

{ Converts between ARGB pixel and grayscale pixel. Alpha byte is ignored }
function ARGBtoGrayScale(ARGB : TARGB; Mode : integer = 0) : byte;

function GrayScaletoARGB(Value : byte) : TARGB;

{ Converts between ARGB and Delphi integer color }
function IntToARGB(Color : integer) : TARGB;
function ARGBToInt(ARGB : TARGB) : integer;

procedure RAW_1ToTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; var Palette : TPalette; Make32 : boolean = True);
procedure RAW_4ToTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; var Palette : TPalette; Make32 : boolean = True);
procedure RAW_8ToTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; var Palette : TPalette; Make32 : boolean = True);
procedure RAW_16ToTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; Make32 : boolean = True);
procedure RAW_24ToTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; Make32 : boolean = True);
procedure RAW_32ToTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; Make32 : boolean = True);

{ Converts image stream to 32-bit image stream }
procedure RAW_AnyToTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; BitDepth : byte; var Palette : TPalette; Make32 : boolean = True);

{ Converts 32-bit image to grayscale 8-bit image }
procedure RAW_TrueColorToGrayScale(InputStream, OutputStream : TStream; Width, Height, BitDepth : integer; GrayScaleMode : integer = 0);

{ Strips alpha from 32-bit stream and converts into non-interleaved 24-bit stream }
procedure StripAlpha(InputStream, OutputStream : TStream; Width, Height : integer);

{ Strips SUBALPHA from the same space as 32-bit image }
procedure StripAlpha2(InputStream, OutputStream : TStream; Width, Height : integer; BitDepth, AlphaPosition : byte);

{ Extracts 8-bit alpha image from 32-bit RAW image stream }
procedure ExtractAlpha(InputStream, OutputStreamA : TStream; Width, Height : integer);

{ Extracts 8-bit SUBALPHA from the same space as 32-bit image }
procedure ExtractAlpha2(InputStream, OutputStreamA : TStream; Width, Height : integer; BitDepth, AlphaPosition : byte; Inverted : boolean = True);

{ Inserts SUBALPHA into 32-bit image }
procedure AppendAlpha2(var InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; BitDepth, AlphaPosition : byte; Inverted : boolean = False);

{ "Cuts" 32-bit image by alpha (useful for preview) }
procedure OverlayAlpha(InputStream, OutputStream : TStream; Width, Height : integer);

{ Generates alpha by comparing 2 24-bit NON-INTERLEAVED streams (converts on-the-fly) }
procedure GenerateAlpha2(var InputStream1,InputStream2,OutputStreamA : TStream; Width, Height : integer);

const scNone = -1;
      scRBG = 0;
      scBGR = 1;
      scBRG = 2;
      scGRB = 3;
      scGBR = 4;

      apLeft   = 0;
      apRight  = 1;
      apTop    = 2;
      apBottom = 3;

    { Current GE library version }
      GE_VERSION = '2009/06/19 16:10';

implementation

{ ����������� ARGB-������� � RGB-������� }
function ARGBPtoRGBP(Palette : TPalette) : TTGAPalette;
var i : integer; TGAPalette : TTGAPalette;
begin
 for i := 0 to 255 do TGAPalette.Palette[i] := ARGBtoRGB(Palette.Palette[i]);
 Result := TGAPalette;
end;

{ ����������� RGB-������� � ARGB-������� }
function RGBPtoARGBP(TGAPalette : TTGAPalette) : TPalette;
var i : integer; Palette : TPalette;
begin
 for i := 0 to 255 do Palette.Palette[i] := RGBtoARGB(TGAPalette.Palette[i]);
 Result := Palette;
end;

{ ����������� ������� ARGB � RGB, ������ �����-����� }
function ARGBtoRGB(ARGB : TARGB) : TRGB;
var RGB : TRGB;
begin
 RGB.B := ARGB.B;
 RGB.G := ARGB.G;
 RGB.R := ARGB.R;
 Result := RGB;
end;

{ ����������� ������� RGB � ARGB, ��������� ������ �����-����� }
function RGBtoARGB(RGB : TRGB) : TARGB;
var ARGB : TARGB;
begin
 ARGB.B := RGB.B;
 ARGB.G := RGB.G;
 ARGB.R := RGB.R;
 ARGB.A := 0;
 Result := ARGB;
end;

{ ����������� TColor-����� Delphi � ��� ARGB }
function IntToARGB(Color : integer) : TARGB;
var ARGB : TARGB;
begin
 ARGB.A := (Color shr 6) and $FF;
 ARGB.B := (Color shr 4) and $FF;
 ARGB.G := (Color shr 2) and $FF;
 ARGB.R := Color and $FF;
 Result := ARGB;
end;

{ ����������� ��� ARGB � TColor-����� Delphi }
function ARGBToInt(ARGB : TARGB) : integer;
var i : integer;
begin
 i := ARGB.A shl 6;
 i := i + ARGB.B shl 4;
 i := i + ARGB.G shl 2;
 i := i + ARGB.R;
 Result := i;
end;

{ ����������� 32-������ ������� � GrayScale-������� }
function ARGBtoGrayScale;
begin
 case Mode of
  0 : Result := (ARGB.R+ARGB.G+ARGB.B) div 3;                         // default mode
  1 : Result := round(0.30*ARGB.R + 0.59*ARGB.G + 0.11*ARGB.B);       // Alternative method (thx to Asceai)
  2 : Result := round(0.2125*ARGB.R + 0.7154*ARGB.G + 0.0721*ARGB.B); // HDR mode (thx to Animeshnik)
  3 : Result := ARGB.R;                                               // from Red channel
  4 : Result := ARGB.G;                                               // from Green channel aka ugly ONScripter mode
  5 : Result := ARGB.B;                                               // from Blue channel
 end;
end;

{ ����������� GrayScale-������� � 32-������, �������� �������� �� ������� }
function GrayScaletoARGB(Value : byte) : TARGB;
var ARGB : TARGB;
begin
 ARGB.B := Value;
 ARGB.G := Value;
 ARGB.R := Value;
 ARGB.A := 0;
 Result := ARGB;
end;

{ "�����������" �����-����� �� ����������� (���������� ��� �������������) }
procedure OverlayAlpha(InputStream, OutputStream : TStream; Width, Height : integer);
var i : integer; ARGB : TARGB;
begin
 if InputStream.Size <> Width*Height*4 then raise Exception.Create('OverlayAlpha : Invalid image stream.');

 InputStream.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);

 for i := 1 to Width*Height do begin
  InputStream.Read(ARGB,4);
  ARGB.R := ARGB.R xor (ARGB.A xor $FF);
  ARGB.G := ARGB.G xor (ARGB.A xor $FF);
  ARGB.B := ARGB.B xor (ARGB.A xor $FF);
  OutputStream.Write(ARGB,4);
 end;
end;

{ ������� �����-����� � 32-������ ������, ��������� ��� � 24-������ ��� ������������ }
procedure StripAlpha(InputStream, OutputStream : TStream; Width, Height : integer);
var i, k : integer; j : byte;
begin
 if InputStream.Size <> Width*Height*4 then raise Exception.Create('StripAlpha : Invalid image stream.');

 InputStream.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);

 for i := 1 to Width*Height do begin
  for k := 1 to 3 do begin
   InputStream.Read(j,1);
   OutputStream.Write(j,1);
  end;
  InputStream.Seek(1,soCurrent);
 end;

end;

{ Note: this function returns NON-INTERLEAVED alpha from 32-bit RAW image stream.
  You must use InterleaveStream function in order to get the valid 8-bit image
  stream and generate grayscale palette by using GrayscalePalette function. }
{ ��������� ����� �� 32-������� ������ }
procedure ExtractAlpha(InputStream, OutputStreamA : TStream; Width, Height : integer);
var i : integer; j : byte;
begin
 if InputStream.Size < Width*Height*4 then raise Exception.Create('ExtractAlpha : Invalid image stream.');

 InputStream.Seek(0,soBeginning);
 OutputStreamA.Seek(0,soBeginning);

 for i := 1 to Width*Height do
  begin
   InputStream.Seek(3,soCurrent);
   InputStream.Read(j,1);
   OutputStreamA.Write(j,1);
  end;
end;

{ ������ ����, ��� � StripAlpha, ������ ������� ��������, ���������� � ������ ������-��������� � ������������ }
procedure StripAlpha2(InputStream, OutputStream : TStream; Width, Height : integer; BitDepth, AlphaPosition : byte);
var k : integer; TempoPalette : TPalette;
    TempoStream : TStream;
begin
 TempoStream := TMemoryStream.Create;

 InputStream.Seek(0,soBeginning);

 if InputStream.Size <> GetScanlineLen2(Width,BitDepth)*Height then raise Exception.Create('ExtractAlpha2 : invalid image stream.');
 TempoPalette := GrayscalePalette;
 if InputStream.Size <> Width*Height*3 then RAW_AnyToTrueColor(InputStream,nil,TempoStream,Width,Height,BitDepth,TempoPalette,False)
 else TempoStream.CopyFrom(InputStream,InputStream.Size);

 TempoStream.Seek(0,soBeginning);
 OutputStream.Size := 0;
 OutputStream.Seek(0,soBeginning);

 case AlphaPosition of
  apLeft   : begin
              for k := 1 to Height do begin
             { Skipping the left side of image }
               TempoStream.Seek((Width*3) div 2,soCurrent);
               OutputStream.CopyFrom(TempoStream,(Width*3) div 2);
              end;
             end;
  apRight  : begin
              for k := 1 to Height do begin
               OutputStream.CopyFrom(TempoStream,(Width*3) div 2);
             { Skipping the right side of image }
               TempoStream.Seek((Width*3) div 2,soCurrent);
              end;
             end;
     apTop : OutputStream.CopyFrom(TempoStream,(TempoStream.Size div 2));
  apBottom : begin
            { Skipping the top side of image }
              TempoStream.Seek(TempoStream.Size div 2,soCurrent);
              OutputStream.CopyFrom(TempoStream,(TempoStream.Size div 2));
             end;
 end;
 FreeAndNil(TempoStream);
end;

{ � ��� ��� ��������� ��� ��������� - ����������� ����� �� ��������
  ��������������� �������, �.�. ����� ����� �������� � ����� ��������
  ������������ ������ � ������������. � ������� �� ���������� �����,
  ���, ��� �������, �������� � ��������������� ���������. }
procedure ExtractAlpha2(InputStream, OutputStreamA : TStream; Width, Height : integer; BitDepth, AlphaPosition : byte; Inverted : boolean = True);
var i, k : integer; j : byte;
    RGB : TRGB;
    TempoStream : TStream;
    TempoPalette : TPalette;
begin
 if InputStream.Size <> GetScanlineLen2(Width,BitDepth)*Height then raise Exception.Create('ExtractAlpha2 : invalid image stream.');
 TempoStream := TMemoryStream.Create;
 TempoPalette := GrayscalePalette;
 InputStream.Seek(0,soBeginning);
 if InputStream.Size <> Width*Height*3 then RAW_AnyToTrueColor(InputStream,nil,TempoStream,Width,Height,BitDepth,TempoPalette,False)
 else TempoStream.CopyFrom(InputStream,InputStream.Size);

 TempoStream.Seek(0,soBeginning);
 OutputStreamA.Size := 0;
 OutputStreamA.Seek(0,soBeginning);

 case AlphaPosition of
  apLeft   : for k := 1 to Height do begin
              for i := 1 to (Width div 2) do begin
               TempoStream.Read(RGB,3);
               j := ARGBtoGrayScale(RGBtoARGB(RGB));
               if Inverted then j := j xor $FF;
               OutputStreamA.Write(j,1);
              end;
            { Skipping the right side of image }
              TempoStream.Seek((Width * 3) div 2,soCurrent);
             end;

  apRight  : for k := 1 to Height do begin
            { Skipping the left side of image }
              TempoStream.Seek((Width * 3) div 2,soCurrent);
              for i := 1 to (Width div 2) do begin
               TempoStream.Read(RGB,3);
               j := ARGBtoGrayScale(RGBtoARGB(RGB));
               if Inverted then j := j xor $FF;
               OutputStreamA.Write(j,1);
              end;
             end;

  apTop    : for k := 1 to (Height div 2) do begin
              for i := 1 to Width do begin
               TempoStream.Read(RGB,3);
               j := ARGBtoGrayScale(RGBtoARGB(RGB));
               if Inverted then j := j xor $FF;
               OutputStreamA.Write(j,1);
              end;
             end;

  apBottom : begin
            { Skipping the top side of image }
              TempoStream.Seek(TempoStream.Size div 2,soCurrent);
              for k := 1 to Height div 2 do begin
               for i := 1 to Width do begin
                TempoStream.Read(RGB,3);
                j := ARGBtoGrayScale(RGBtoARGB(RGB));
                if Inverted then j := j xor $FF;
                OutputStreamA.Write(j,1);
               end;
              end;
             end;
 end;
 FreeAndNil(TempoStream);
end;

{ ��������� ����� � ���� 24-�������� �����������, ���������� ������ ����� }
procedure AppendAlpha2(var InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; BitDepth, AlphaPosition : byte; Inverted : boolean = False);
var i, k : integer; j : byte;
    RGB : TRGB;
    TempoStream : TStream;
    TempoStreamA : TStream;
    TempoPalette : TPalette;
begin
 InputStream.Seek(0,soBeginning);
 InputStreamA.Seek(0,soBeginning);
 OutputStream.Size := 0;

 TempoStream := TMemoryStream.Create;
 TempoStreamA := TMemoryStream.Create;
 TempoPalette := GrayscalePalette;
 if InputStream.Size <> Width*Height*3 then RAW_AnyToTrueColor(InputStream,nil,TempoStream,Width,Height,BitDepth,TempoPalette,False)
 else TempoStream.CopyFrom(InputStream,InputStream.Size);

 TempoStreamA.CopyFrom(InputStreamA,InputStreamA.Size);

 TempoStream.Seek(0,soBeginning);
 TempoStreamA.Seek(0,soBeginning);

 case AlphaPosition of
  apLeft   : for k := 1 to Height do begin
              for i := 1 to Width do begin
               TempoStreamA.Read(j,1);
               if Inverted then j := j xor $FF;
               RGB := ARGBtoRGB(GrayscaletoARGB(j));
               OutputStream.Write(RGB,3);
              end;
              OutputStream.CopyFrom(TempoStream,Width*3);
             end;
  apRight  : for k := 1 to Height do begin
              OutputStream.CopyFrom(TempoStream,Width*3);
              for i := 1 to Width do begin
               TempoStreamA.Read(j,1);
               if Inverted then j := j xor $FF;
               RGB := ARGBtoRGB(GrayscaletoARGB(j));
               OutputStream.Write(RGB,3);
              end;
             end;
  apTop    : begin
              for k := 1 to Height do begin
               for i := 1 to Width do begin
                TempoStreamA.Read(j,1);
                if Inverted then j := j xor $FF;
                RGB := ARGBtoRGB(GrayscaletoARGB(j));
                OutputStream.Write(RGB,3);
               end;
              end;
              OutputStream.CopyFrom(TempoStream,Width*Height*3);
             end;
  apBottom : begin
              OutputStream.CopyFrom(TempoStream,Width*Height*3);
              for k := 1 to Height do begin
               for i := 1 to Width do begin
                TempoStreamA.Read(j,1);
                if Inverted then j := j xor $FF;
                RGB := ARGBtoRGB(GrayscaletoARGB(j));
                OutputStream.Write(RGB,3);
               end;
              end;
             end;
 end;
 FreeAndNil(TempoStream);
 FreeAndNil(TempoStreamA);
end;

{ ���������� ����������� ��� �������� ������� �����, ��������� 2 24-������ ����������� }
procedure GenerateAlpha2(var InputStream1,InputStream2,OutputStreamA : TStream; Width, Height : integer);
var i : integer; j : byte;
    RGB1, RGB2 : TRGB; ARGB : TARGB;
begin
 if InputStream1.Size <> InputStream2.Size then raise Exception.Create('GenerateAlpha2 : Different image structures.');
 InputStream1.Seek(0,soBeginning);
 InputStream2.Seek(0,soBeginning);

 for i := 1 to Width*Height do begin
  InputStream1.Read(RGB1,3);
  InputStream2.Read(RGB2,3);

{ Makes normal (back-inverted) alpha }
  ARGB.B := (RGB1.B xor RGB2.B) xor $FF;
  ARGB.G := (RGB1.G xor RGB2.G) xor $FF;
  ARGB.R := (RGB1.R xor RGB2.R) xor $FF;
  ARGB.A := 0;

  j := ARGBtoGrayScale(ARGB);
  OutputStreamA.Write(j,1);
 end;
end;

{ ���������� ����� ������� � �������� }
function GetPaletteColors(BitDepth : byte) : integer;
begin
 Result := 0;
 case BitDepth of
     1,4,8 : Result := round(Involution(2,BitDepth));
  16,24,32 : Result := 0;
 end;
end;

{ ���������� ����� ������� � ������ }
function GetPaletteSize(BitDepth : byte) : integer;
begin
 Result := 4 * GetPaletteColors(BitDepth);
end;

{ ���������� ����������� ������ �� ����� Windows Bitmap }
procedure InterleaveStream(InputStream, OutputStream : TStream; Width, Height, BitDepth : integer);
var i, k, Gap : integer;
begin
  k := 0;
  if InputStream.Size < ((Width*Height*BitDepth) div 8) then raise Exception.Create('InterleaveStream : Invalid image stream.');

{ Calculating the interleaved scanline length and gap }
  Gap := GetScanLineGap(Width, BitDepth);

  InputStream.Seek(0,soBeginning);
  OutputStream.Seek(0,soBeginning);

{ Speeds up the copying procedure if Gap = 0 }
  if Gap > 0 then begin
   for i := 1 to Height do begin
    OutputStream.CopyFrom(InputStream,Width*BitDepth div 8);
    OutputStream.Write(k,Gap);
   end;
  end else OutputStream.CopyFrom(InputStream,InputStream.Size);
end;

{ ������ ����������� ����� :) }
procedure DeInterleaveStream(InputStream, OutputStream : TStream; ScanlineLen, Gap, Height : integer);
var i : integer;
begin
 if InputStream.Size < Scanlinelen*Height then raise Exception.Create('DeInterleaveStream : Invalid image stream.');

 InputStream.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);

{ Speeds up the copying procedure if Gap = 0 }
 if Gap > 0 then begin
  for i := 1 to Height do begin
   OutputStream.CopyFrom(InputStream,ScanlineLen-Gap);
   InputStream.Seek(Gap,soCurrent);
  end;
 end else OutputStream.CopyFrom(InputStream,InputStream.Size);
end;

{ ���������� GrayScale-������� ������� ARGB }
function GrayscalePalette : TPalette;
var i : integer; Palette : TPalette; ARGB : TARGB;
begin
 for i := 0 to 255 do begin
  with ARGB do begin
   B := i;
   G := i;
   R := i;
   A := 0;
  end;
  Palette.Palette[i] := ARGB;
 end;
 Result := Palette;
end;

{ ���������� ������ (����������� ������) ������� ������� ARGB }
function NullPalette : TPalette;
var {i : integer;} Palette : TPalette; {ARGB : TARGB;}
begin
{ with ARGB do begin
  B := 0;
  G := 0;
  R := 0;
  A := 0;
 end;
 for i := 0 to 255 do Palette.Palette[i] := ARGB;}

 FillChar(Palette,SizeOf(Palette),0);
 Result := Palette;
end;

procedure SwapColors(var InputStream : TStream; Width, Height, BitDepth, Operation : integer);
var TempoStream : TStream;
    RGB : TRGB; ARGB : TARGB;
    i : integer;
begin
 InputStream.Seek(0,soBeginning);
 TempoStream := TMemoryStream.Create;
 case BitDepth of
  4,8,16 : ; // to-do: add color swapping for other formats
  24 : for i := 1 to Width*Height do begin
        InputStream.Read(RGB,3);
        RGB := SwapColors24(RGB,Operation);
        TempoStream.Write(RGB,3);
       end;
  32 : for i := 1 to Width*Height do begin
        InputStream.Read(ARGB,4);
        ARGB := SwapColors32(ARGB,Operation);
        TempoStream.Write(ARGB,4);
       end;
 end;
 InputStream.Size := 0;
 TempoStream.Seek(0,soBeginning);
 InputStream.CopyFrom(TempoStream,TempoStream.Size);
 FreeAndNil(TempoStream);
end;

function SwapColors24(RGB : TRGB; Operation : integer) : TRGB;
var Output : TRGB;
begin
 case Operation of
  scNone : Output := RGB;
   scRBG : begin
            Output.R := RGB.R;
            Output.G := RGB.B;
            Output.B := RGB.G;
           end;
   scBGR : begin
            Output.R := RGB.B;
            Output.G := RGB.G;
            Output.B := RGB.R;
           end;
   scBRG : begin
            Output.R := RGB.B;
            Output.G := RGB.R;
            Output.B := RGB.G;
           end;
   scGRB : begin
            Output.R := RGB.G;
            Output.G := RGB.R;
            Output.B := RGB.B;
           end;
   scGBR : begin
            Output.R := RGB.G;
            Output.G := RGB.B;
            Output.B := RGB.R;
           end;
 end;
 Result := Output;
end;

{ Swaps colors of given 32-bit(!!!) pixel by ARGB schemes }
{ ������ ������� �������� ������ 32-������� ������� �� ������ RGB }
function SwapColors32(ARGB : TARGB; Operation : integer) : TARGB;
var Output : TARGB;
begin
 case Operation of
  scNone : Output := ARGB;
   scRBG : begin
            Output.R := ARGB.R;
            Output.G := ARGB.B;
            Output.B := ARGB.G;
           end;
   scBGR : begin
            Output.R := ARGB.B;
            Output.G := ARGB.G;
            Output.B := ARGB.R;
           end;
   scBRG : begin
            Output.R := ARGB.B;
            Output.G := ARGB.R;
            Output.B := ARGB.G;
           end;
   scGRB : begin
            Output.R := ARGB.G;
            Output.G := ARGB.R;
            Output.B := ARGB.B;
           end;
   scGBR : begin
            Output.R := ARGB.G;
            Output.G := ARGB.B;
            Output.B := ARGB.R;
           end;
 end;
 Output.A := ARGB.A;
 Result := Output;
end;

{ �������������� ����� ����� ������ - ���������� ���������� �� ��������� �
  �����������. ��� ���������� ��������� ������ ��� ������� *���* ������������. }
procedure StreamFlip(InputStream : TStream);
var i : integer; j : byte;
    TempoStream : TStream;
begin
 TempoStream := TMemoryStream.Create;
 for i := InputStream.Size-1 downto 0 do begin
  InputStream.Seek(i,soBeginning);
  InputStream.Read(j,1);
  TempoStream.Write(j,1);
 end;
 TempoStream.Seek(0,soBeginning);
 InputStream.Size := 0;
 InputStream.CopyFrom(TempoStream,TempoStream.Size);
 FreeAndNil(TempoStream);
end;

{ ������ ��� ������� VerticalFlipIO. ������� ��� �������������. }
procedure VerticalFlip(InputStream : TStream; ScanlineLen, Height : integer);
var i : integer;
    TempoStream : TStream;
begin
 TempoStream := TMemoryStream.Create;

 VerticalFlipIO(InputStream,TempoStream,ScanlineLen,Height);

 InputStream.Size := 0;
 TempoStream.Seek(0,soBeginning);
 InputStream.CopyFrom(TempoStream,TempoStream.Size);
 FreeAndNil(TempoStream);
end;

{ �������������� ����� ����������� �� ��������� }
procedure VerticalFlipIO(InputStream, OutputStream : TStream; ScanlineLen, Height : integer);
var i : integer;
begin
 for i := Height-1 downto 0 do begin
  InputStream.Seek(i*ScanlineLen,soBeginning);
  OutputStream.CopyFrom(InputStream,ScanLineLen);
 end;
end;


{ ���������� ����� ����-����� � ������������� }
function GetScanlineLen(Width, BitDepth : integer) : integer;
begin
 Result := 0;
 case BitDepth of
{  1: Result := Width;} // to-do : cannot handle 1-bit images properly yet
   4: Result := ((Width + 7) shr 3) shl 2;
   8: Result := ((Width + 3) shr 2) shl 2;
  16: Result := ((Width * 2 + 3) shr 2) shl 2;
  24: Result := ((Width * 3 + 3) shr 2) shl 2;
  32: Result := Width * 4;
 end;
end;

{ ���� �����, �� ��� ������������ }
function GetScanlineLen2(Width, BitDepth : integer) : integer;
begin
 Result := (Width * BitDepth) div 8;
end;

{ ���������� ����� �����������-������� }
function GetScanlineGap(Width, BitDepth : integer) : integer;
begin
 Result := 0;
 case BitDepth of
{  1: Result := 0;} // to-do : cannot handle 1-bit images properly yet
   4: Result := GetScanlineLen(Width, BitDepth) - Width div 2;
   8: Result := GetScanlineLen(Width, BitDepth) - Width;
  16: Result := GetScanlineLen(Width, BitDepth) - Width * 2;
  24: Result := GetScanlineLen(Width, BitDepth) - Width * 3;
  32: Result := 0;
 end;
end;

procedure RAW_1toTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; var Palette : TPalette; Make32 : boolean = True);
var i, j, k, l, m : integer; ARGB : TARGB; RGB : TRGB;
begin
 m := 0;
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);
 if InputStream.Size <> GetScanlineLen2(Width,1)*Height then raise Exception.Create('RAW_1to32 : invalid image stream size.');
 if InputStreamA.Size <> GetScanlineLen2(Width,8)*Height then raise Exception.Create('RAW_1to32 : invalid alpha stream size.');
 for i := 1 to InputStream.Size do begin
  InputStream.Read(j,1);
  for k := 8 downto 1 do begin
   l := j shr k-1;
   l := l and $1;
   ARGB := Palette.Palette[l];
   if InputStreamA <> nil then begin
    inc(m);
    if m >= 3 then begin
     m := 0;
     InputStreamA.Read(ARGB.A,1);
    end;
   if Make32 then OutputStream.Write(ARGB,4)
   else begin
         RGB := ARGBtoRGB(ARGB);
         OutputStream.Write(RGB,3);
        end;
   end;
  end;
 end;
end;

procedure RAW_4toTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; var Palette : TPalette; Make32 : boolean = True);
var i : integer; j, k, l : byte; ARGB : TARGB; RGB : TRGB;
begin
 k := 0;
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);
 if InputStream.Size <> GetScanlineLen2(Width,4)*Height then raise Exception.Create('RAW_4to32 : invalid image stream size.');
 if InputStreamA <> nil then if InputStreamA.Size <> GetScanlineLen2(Width,8)*Height then raise Exception.Create('RAW_4to32 : invalid alpha stream size.');
 for i := 1 to InputStream.Size do begin
  InputStream.Read(j,1);
  for l := 1 to 2 do begin
   case l of
    1 : k := j and $f;
    2 : k := j shr 4;
   end;
   ARGB := Palette.Palette[k];
   if InputStreamA <> nil then InputStreamA.Read(ARGB.A,1);
   if Make32 then OutputStream.Write(ARGB,4)
   else begin
    RGB := ARGBtoRGB(ARGB);
    OutputStream.Write(RGB,3);
   end;
  end;
 end;
end;

procedure RAW_8toTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; var Palette : TPalette; Make32 : boolean = True);
var i : integer; j : byte; ARGB : TARGB; RGB : TRGB;
begin
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);
 if InputStream.Size <> GetScanlineLen2(Width,8)*Height then raise Exception.Create('RAW_8to32 : invalid image stream size.');
 if InputStreamA <> nil then if InputStreamA.Size <> GetScanlineLen2(Width,8)*Height then raise Exception.Create('RAW_8to32 : invalid alpha stream size.');
 for i := 1 to InputStream.Size do begin
  InputStream.Read(j,1);
  ARGB := Palette.Palette[j];
{ Replaces original alpha value with alpha channel }
  if InputStreamA <> nil then InputStreamA.Read(ARGB.A,1);
  if Make32 then OutputStream.Write(ARGB,4)
  else begin
   RGB := ARGBtoRGB(ARGB);
   OutputStream.Write(RGB,3);
  end;
 end;
end;

procedure RAW_16toTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; Make32 : boolean = True);
var i, tw : integer; ARGB : TARGB; RGB : TRGB;
begin
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);
 if InputStream.Size <> GetScanlineLen2(Width,16)*Height then raise Exception.Create('RAW_16to32 : invalid image stream size.');
 if InputStreamA <> nil then if InputStreamA.Size <> GetScanlineLen2(Width,8)*Height then raise Exception.Create('RAW_16to32 : invalid alpha stream size.');
 for i := 1 to InputStream.Size div 2 do begin
  InputStream.Read(tw,2);
// shl 3) + $7 is a conversion to normal value (otherwise the image will have incorrect gamma)  
  ARGB.A := ((tw shr 15) shl 3) + $7;
  ARGB.R := (((tw shr 10) and $1F) shl 3) + $7;
  ARGB.G := (((tw shr 5) and $1F) shl 3) + $7;
  ARGB.B := ((tw and $1F) shl 3) + $7;
{ Replaces original alpha value with alpha channel }
  if InputStreamA <> nil then InputStreamA.Read(ARGB.A,1);
  if Make32 then OutputStream.Write(ARGB,4)
  else begin
   RGB := ARGBtoRGB(ARGB);
   OutputStream.Write(RGB,3);
  end;
 end;
end;

procedure RAW_24toTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; Make32 : boolean = True);
var i : integer; ARGB : TARGB; RGB : TRGB;
begin
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);
 if InputStream.Size <> GetScanlineLen2(Width,24)*Height then raise Exception.Create('RAW_24to32 : invalid image stream size.');
 if InputStreamA <> nil then if InputStreamA.Size <> GetScanlineLen2(Width,8)*Height then raise Exception.Create('RAW_24to32 : invalid alpha stream size.');
 for i := 1 to (InputStream.Size div 3) do begin
  InputStream.Read(ARGB.B,1);
  InputStream.Read(ARGB.G,1);
  InputStream.Read(ARGB.R,1);
  ARGB.A := 0;
{ Replaces original alpha value with alpha channel }
  if InputStreamA <> nil then InputStreamA.Read(ARGB.A,1);
  if Make32 then OutputStream.Write(ARGB,4)
  else begin
   RGB := ARGBtoRGB(ARGB);
   OutputStream.Write(RGB,3);
  end;
 end;
end;

procedure RAW_32toTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; Make32 : boolean = True);
var i : integer; ARGB : TARGB; RGB : TRGB;
begin
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);
 if InputStream.Size <> GetScanlineLen2(Width,32)*Height then raise Exception.Create('RAW_32to32 : invalid image stream size.');
 if InputStreamA <> nil then if InputStreamA.Size <> GetScanlineLen2(Width,8)*Height then raise Exception.Create('RAW_32to32 : invalid alpha stream size.');

 for i := 1 to (InputStream.Size div 4) do begin
  InputStream.Read(ARGB,4);
{ Replaces original alpha channel with new alpha channel }
  if InputStreamA <> nil then InputStreamA.Read(ARGB.A,1);
  if Make32 then OutputStream.Write(ARGB,4)
  else
   begin
    RGB := ARGBtoRGB(ARGB);
    OutputStream.Write(RGB,3);
   end;
 end;
end;

{ Converts to BMP\TGA-compatible 32-bit RAW stream \ combines with external alpha }
procedure RAW_AnyToTrueColor(InputStream, InputStreamA, OutputStream : TStream; Width, Height : integer; BitDepth : byte; var Palette : TPalette; Make32 : boolean = True);
begin
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);
{ Note: Alpha is ALWAYS stored as 8-bit image ONLY and must be at the same sizes
  as base image (WxH), otherwise an runtime error will occur }
 case BitDepth of
  1 : raise Exception.Create('to32 : 1-bit images aren''t supported yet.'); //to-do: implement 1-bit images support
  4 : RAW_4toTrueColor(InputStream,InputStreamA,OutputStream,Width,Height,Palette,Make32);
  8 : RAW_8toTrueColor(InputStream,InputStreamA,OutputStream,Width,Height,Palette,Make32);
  16: RAW_16toTrueColor(InputStream,InputStreamA,OutputStream,Width,Height,Make32);
  24: RAW_24toTrueColor(InputStream,InputStreamA,OutputStream,Width,Height,Make32);
  32: RAW_32toTrueColor(InputStream,InputStreamA,OutputStream,Width,Height,Make32);
 end;
end;

procedure RAW_TrueColorToGrayScale(InputStream, OutputStream : TStream; Width, Height, BitDepth : integer; GrayScaleMode : integer = 0);
var RGB : TRGB; ARGB : TARGB;
    i : integer; j : byte;
begin
 if InputStream.Size <> GetScanlineLen2(Width,BitDepth)*Height then raise Exception.Create('RAW_TrueColorToGrayscale : invalid image stream.');
 InputStream.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);
 case BitDepth of
  24 : for i := 1 to (InputStream.Size div 3) do begin
        InputStream.Read(RGB,3);
        j := ARGBtoGrayscale(RGBtoARGB(RGB),GrayScaleMode);
        OutputStream.Write(j,1);
       end;
  32 : for i := 1 to (InputStream.Size div 4) do begin
        InputStream.Read(ARGB,4);
        j := ARGBtoGrayscale(ARGB,GrayScaleMode);
        OutputStream.Write(j,1);
       end;
 end;
end;

end.