unit OpenJPegBitmap;

interface
uses Classes, Graphics, openjpeg, Windows, SysUtils;
type
  TOpenJpegQualityRange = 1..100;
  TOpenJPegCallback = procedure(Sender : TObject; const AMsg : String) of object;
  TOpenJpegBitmap = class(Graphics.TBitmap)
  protected
    FOnInfoCallback: TOpenJPegCallback;
    FOnWarningCallback: TOpenJPegCallback;
    FOnErrorCallback : TOpenJPegCallback;
    FCodecFormat : OPJ_CODEC_FORMAT;
    procedure ProcessImage(a_param : opj_dparameters_t; a_codec: popj_codec_t; a_stream: popj_stream_t; a_image : popj_image_t);
  public
    constructor Create; override;
    procedure LoadFromStream(Stream: TStream); override;
    property CodecFormat : OPJ_CODEC_FORMAT read FCodecFormat write FCodecFormat;
    property OnInfoCallback: TOpenJPegCallback read FOnInfoCallback write FOnInfoCallback;
    property OnWarningCallback: TOpenJPegCallback read FOnWarningCallback write FOnWarningCallback;
    property OnErrorCallback : TOpenJPegCallback read FOnErrorCallback write FOnErrorCallback;
  end;

const
  SJpeg2000ImageFile = 'JPEG 2000 Image';

implementation
uses Math;

const
  JP2_RFC3745_MAGIC : array [0..11] of byte = ($00,$00,$00,$0c,$6a,$50,$20,$20,$0d,$0a,$87,$0a);
  JP2_MAGIC : array[0..3] of byte = ($0d,$0a,$87,$0a);
//* position 45: "\xff\x52" */
  J2K_CODESTREAM_MAGIC : array [0..3] of byte = ($ff,$4f,$ff,$51);

//0: J2K, 1: JP2, 2: JPT
  J2K_CFMT = 0;
  JP2_CFMT = 1;
  JPT_CFMT = 2;

  PXM_DFMT = 10;
  PGX_DFMT = 11;
  BMP_DFMT = 12;
  YUV_DFMT = 13;
  TIF_DFMT = 14;
  RAW_DFMT = 15; //* MSB / Big Endian */
  TGA_DFMT = 16;
  PNG_DFMT = 17;
  RAWL_DFMT = 18; //* LSB / Little Endian */

{Support routines}

function CalcDimension(const A0, A1 : OPJ_INT32) : OPJ_INT32;
begin
  Result := Max(A0,A1) - Min(A0,A1);
end;

{message callbacks}
procedure info_callback(msg : PAnsiChar;client_data : Pointer) cdecl;
var LSender : TOpenJpegBitmap;
begin
  LSender := TOpenJpegBitmap(client_data);
  if Assigned(LSender.FOnInfoCallback) then begin
    {$ifdef Unicode}
    LSender.FOnInfoCallback(LSender, UTF8ToString(msg));
    {$else}
    LSender.FOnWarningCallback(LSender,msg);
   {$endif}
  end;
end;

procedure warning_callback(msg : PAnsiChar;client_data : Pointer) cdecl;
var LSender : TOpenJpegBitmap;
begin
  LSender := TOpenJpegBitmap(client_data);
  if Assigned(LSender.FOnInfoCallback) then begin
    {$ifdef Unicode}
    LSender.FOnInfoCallback(LSender, UTF8ToString(msg));
    {$else}
    LSender.FOnWarningCallback(LSender,msg);
   {$endif}
  end;
end;

procedure error_callback(msg : PAnsiChar;client_data : Pointer) cdecl;
var LSender : TOpenJpegBitmap;
begin
  LSender := TOpenJpegBitmap(client_data);
  if Assigned(LSender.FOnErrorCallback) then begin
    {$ifdef Unicode}
    LSender.FOnInfoCallback(LSender, UTF8ToString(msg));
    {$else}
    LSender.FOnErrorCallback(LSender,msg);
   {$endif}
  end;
end;

{Use OpenJPeg i_stream wrapper functions around our stream}
function TStream_opj_stream_read_fn (p_buffer : Pointer; p_nb_bytes : OPJ_SIZE_T; p_user_data : Pointer) : OPJ_SIZE_T cdecl;
var LStream : TStream;
begin
  LStream := TStream(p_user_data);
  Result := LStream.Read(p_buffer^,p_nb_bytes);
  if Result = 0 then begin
    Result := OPJ_SIZE_T(-1);
  end;
end;

function TStream_opj_stream_seek_fn( p_nb_bytes : OPJ_OFF_T; p_user_data : Pointer) : OPJ_BOOL cdecl;
var LStream : TStream;
  LRes : Int64;
begin
  LStream := TStream(p_user_data);
  LRes := LStream.Seek(p_nb_bytes, soBeginning );

  if (OPJ_OFF_T(LRes) = p_nb_bytes) then begin
    Result := OPJ_TRUE;
  end else begin
    Result := OPJ_FALSE;
  end;
end;

function TStream_opj_stream_write_fn (p_buffer : Pointer; p_nb_bytes : OPJ_SIZE_T; p_user_data : Pointer) : OPJ_SIZE_T cdecl;
var LStream : TStream;
begin
  LStream := TStream(p_user_data);
  Result := LStream.Write(p_buffer^,p_nb_bytes);
end;



function FileTypeToCodecFormat(AType : Integer) : CODEC_FORMAT;
begin
  Result := OPJ_CODEC_JPT;
  case AType of
    J2K_CFMT : Result := OPJ_CODEC_J2K;
    JP2_CFMT : Result := OPJ_CODEC_JP2;
    JPT_CFMT : Result := OPJ_CODEC_JPT;
  end;
end;
//
function GetFileType(AStream : TStream) : Integer;
var
  SIGBuf : array[0..11] of byte;
  len : Integer;
  LPos : OPJ_SIZE_T;
begin
  LPos := AStream.Position;
//0: J2K, 1: JP2, 2: JPT
  Result := JPT_CFMT;
  len := AStream.Read(SIGBuf,12);
  if (len > 11) and CompareMem(@SIGBuf, @JP2_RFC3745_MAGIC[0],12) then begin
    Result := JP2_CFMT;
  end else begin
    if Len > 3 then begin
      if CompareMem(@SIGBuf,@JP2_MAGIC[0],4) then begin
        Result := JP2_CFMT;
      end else begin
         if CompareMem(@SIGBuf,@J2K_CODESTREAM_MAGIC[0],4) then begin
           Result := J2K_CFMT;
         end;
      end;
    end;
  end;
  AStream.Position := LPos;
end;


{ TOpenJpegBitmap }

constructor TOpenJpegBitmap.Create;
begin
  inherited;

end;

procedure TOpenJpegBitmap.LoadFromStream(Stream: TStream);
var l_param : opj_dparameters_t;
    l_codec : popj_codec_t;
    l_stream : popj_stream_t;
    l_image : popj_image_t;
    LDataSize : OPJ_SIZE_T;
begin
//  inherited;
  //* Set the default decoding parameters */
  opj_set_default_decoder_parameters(l_param);
  l_param.decod_format := GetFileType(Stream);
  l_param.m_verbose := OPJ_TRUE;
  l_param.cod_format := 2;  //indicate bitmap
  LDataSize := Stream.Size - Stream.Position;
  l_stream := opj_stream_create(LDataSize,OPJ_TRUE);
  try
    opj_stream_set_read_function(l_stream, TStream_opj_stream_read_fn);
    opj_stream_set_seek_function(l_stream, TStream_opj_stream_seek_fn);
    opj_stream_set_write_function(l_stream, TStream_opj_stream_write_fn);
    opj_stream_set_user_data(l_stream,Stream,nil);
    opj_stream_set_user_data_length(l_stream,LDataSize);

    FCodecFormat := FileTypeToCodecFormat(l_param.decod_format);
    l_codec := opj_create_decompress(CodecFormat);
    try
      //* catch events using our callbacks and give a local context */
      opj_set_info_handler(l_codec, info_callback,Self);
      opj_set_warning_handler(l_codec, warning_callback,Self);
      opj_set_error_handler(l_codec, error_callback,Self);
      if opj_setup_decoder(l_codec, @l_param) = OPJ_TRUE then begin
        if opj_read_header(l_stream,l_codec,l_image) = OPJ_TRUE then
        try
          Height := CalcDimension(l_image^.x0,l_image^.x1);
          Height := CalcDimension(l_image^.y0,l_image^.y1);
          ProcessImage(l_param, l_codec,l_stream,l_image);
          opj_end_decompress(l_codec,l_stream);
        finally
          opj_image_destroy(l_image);
        end;
      end;
    finally
      if Assigned(l_codec) then begin
        opj_destroy_codec(l_codec);
      end;
    end;
  finally
    opj_stream_destroy(l_stream);
  end;
end;


procedure TOpenJpegBitmap.ProcessImage(a_param: opj_dparameters_t;
  a_codec: popj_codec_t; a_stream: popj_stream_t; a_image: popj_image_t);
begin

end;

initialization
  TPicture.RegisterFileFormat('jp2', SJpeg2000ImageFile, TOpenJpegBitmap);
  TPicture.RegisterFileFormat('j2k', SJpeg2000ImageFile, TOpenJpegBitmap);
  TPicture.RegisterFileFormat('jpc', SJpeg2000ImageFile, TOpenJpegBitmap);
finalization
  TPicture.UnregisterGraphicClass(TOpenJpegBitmap);


end.
