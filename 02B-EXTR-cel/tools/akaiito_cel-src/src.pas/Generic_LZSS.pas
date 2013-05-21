{
  AnimED - Visual Novel Tools
  LZSS library
  Copyright � 2007-2010 WinKiller Studio. Open Source.
  This software is free. Please see License for details.
  
  Contributed by Nik.
}
unit Generic_LZSS;

interface

uses Classes;

//��� cel
//GLZDecode(IStream, OStream, CryptLength, $3EE,$3FF)

//��� Pure Pure
//GLZDecode(IStream, OStream, CryptLength, $FEE,$FFF)

function GLZSSEncode(InputStream, OutputStream : TStream) : boolean;
function GLZSSDecode(InputStream, OutputStream : TStream; CryptLength, SlidWindowIndex, SlidWindowLength : integer) : boolean;

implementation

{ Well, it doesn't really compress anything... ^^' }
function GLZSSEncode;
var Dummy : byte;
    Buffer : int64;
   {lzchar : array[0..1] of char;}
    i : integer;
begin
 Result := False;
 Dummy := $FF;
 for i := 1 to (InputStream.Size div 8) do begin
  OutputStream.Write(Dummy,1);
  InputStream.Read(Buffer,8);
  OutputStream.Write(Buffer,8);
 end;
 InputStream.Read(Buffer,(InputStream.Size mod 8));
 OutputStream.Write(Buffer,(InputStream.Size mod 8));
 Result := True;
end;

function GLZSSDecode;
{IStream - �������� �����, ����� �� ������ ��������������� �������,
CryptLength - ���������� ���� � �������������� �������}
var SlidingWindow : array of byte; {"���������� ����" � ���������� ������}
    Temp1, Temp2, EAX, ECX, EDI : integer;
    AL, DI : byte;
begin
Result := False;
SetLength(SlidingWindow,SlidWindowLength);
//WindowIndex := $3EE; {��������� ������ ����}
Temp1 := 0;
{��� � �����������, ��� OStream ��� ������}
while (CryptLength > 0) do begin
 EAX := Temp1;
 EAX := EAX shr 1;
 Temp1 := EAX;
 if ((EAX and $FF00) and $100) = 0 then begin
 {���� 9-� ��� ����� ����, ������ ����������� ����� ��������� (��� ��
  �����������, ��� ������ �������)}
 {������ ����������� �����}
  AL := 0;
  InputStream.Read(AL,1);
  dec(CryptLength);
  EAX := AL or $FF00;
  Temp1 := EAX;
 end;
 {���� ��������� ��� ������������ ����� ����� 1, ������ ��������� ����
  ������� � �������� ����� ��� ���������}
 if ((Temp1 and $FF) and $1) <> 0 then begin
  InputStream.Read(AL,1);
  dec(CryptLength);
  OutputStream.Write(AL,1);
  SlidingWindow[SlidWindowIndex] := AL;
  inc(SlidWindowIndex);
  SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
 {���� ��������� ��� ������������ ����� ����� 0, ������ �� �����
  "���������� ����" ��� ��������������� ����}
 end else begin
  {
   ������ �����: �������� ��� �����
    1) ������� (���� 0-7)
    2) �����������
       ���� 0-3 - ���������� �������� (����)
       ���� 4-7 - ���� 8-12 �������� ������
    ����� ������� � �������� ������ � ���������� ���� �������� �
    �������� ����� ������� ���� ������� ������� � ���-�� �������� + 2
    ����� ������, ��� ���������� ���� ���������� �������� (�����
    ������� 1023 ����� ���� ������ 0)
  }
  InputStream.Read(DI,1);
  InputStream.Read(AL,1);
  dec(CryptLength,2);
  ECX := (AL and $F0) shl 4;
  EDI := DI or ECX;
  EAX := (AL and $F) + 2;
  Temp2 := EAX;
  ECX := 0;
  if EAX > 0 then begin
   while (ECX <= Temp2) do begin
    EAX := (ECX + EDI) and SlidWindowLength;
    AL := SlidingWindow[EAX];
    OutputStream.Write(AL,1);
    SlidingWindow[SlidWindowIndex] := AL;
    inc(SlidWindowIndex);
    SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
    inc(ECX);
   end;
  end;
 end;
 Result := True;
end;

end;

end.