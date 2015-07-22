unit openjpeg;

interface
{$I OpenJPegDefines.inc}

{$RANGECHECKS OFF}
{$IFNDEF FPC}
  {$IFDEF WIN32}
    {$ALIGN 8}
    {$MINENUMSIZE 4}
  {$ENDIF}
  {$IFDEF WIN64}
    {$ALIGN ON}
     {$MINENUMSIZE 4}
  {$ENDIF}
  {$IFNDEF WIN32_OR_WIN64}
    {$IFNDEF VCL_CROSS_COMPILE}
      {$message error error alignment!}
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$packrecords C}
{$ENDIF}

uses {$IFDEF MSWINDOWS}Windows, {$ENDIF}SysUtils;
{$I Ctypes.inc}

type
  OPJ_BOOL = TIdC_INT;
  POPJ_BOOL = ^OPJ_BOOL;
  OPJ_CHAR = Byte;
  POPJ_CHAR = ^OPJ_CHAR;
  OPJ_FLOAT32 = TIdC_Float;
  POPJ_FLOAT32 = ^OPJ_FLOAT32;
  OPJ_FLOAT64 = TIdC_Double;
  OPJ_BYTE = Byte;
  POPJ_BYTE = ^OPJ_BYTE;

  OPJ_INT8 = TIdC_INT8;
  OPJ_UINT8 = TIdC_UInt8;
  OPJ_INT16 = TIdC_Int16;
  OPJ_UINT16 = TIdC_UINT16;
  OPJ_INT32 = TIdC_INT32;
  POPJ_INT32 = ^OPJ_INT32;
  OPJ_UINT32 = TIdC_UINT32;
  POPJ_UINT32 = ^OPJ_UINT32;
  OPJ_INT64 = TIdC_INT64;
  OPJ_UINT64 = TIdC_UINT64;
  OPJ_OFF_T = TIdC_INT64; //* 64-bit file offset type */
  OPJ_SIZE_T = size_t;

const
   OPJ_TRUE = 1;
   OPJ_FALSE = 0;

 {*
==========================================================
   Useful constant definitions
==========================================================
*}

  OPJ_PATH_LEN = 4096; //**< Maximum allowed size for filenames */

  OPJ_J2K_MAXRLVLS = 33;					//**< Number of maximum resolution level authorized */
  OPJ_J2K_MAXBANDS = (3* OPJ_J2K_MAXRLVLS - 2);	//**< Number of maximum sub-band linked to number of resolution level */


  OPJ_J2K_DEFAULT_NB_SEGS				= 10;
  OPJ_J2K_STREAM_CHUNK_SIZE			= $100000; //** 1 mega by default */
  OPJ_J2K_DEFAULT_HEADER_SIZE			= 1000;
  OPJ_J2K_MCC_DEFAULT_NB_RECORDS	 = 10;
  OPJ_J2K_MCT_DEFAULT_NB_RECORDS	 = 10;

 //* UniPG>> */ /* NOT YET USED IN THE V2 VERSION OF OPENJPEG */
  JPWL_MAX_NO_TILESPECS	= 16; //**< Maximum number of tile parts expected by JPWL: increase at your will */
  JPWL_MAX_NO_PACKSPECS	= 16; //**< Maximum number of packet parts expected by JPWL: increase at your will */
  JPWL_MAX_NO_MARKERS	= 512; //**< Maximum number of JPWL markers: increase at your will */
  JPWL_PRIVATEINDEX_NAME = 'jpwl_index_privatefilename'; //**< index file name used when JPWL is on */
  JPWL_EXPECTED_COMPONENTS = 3; //**< Expect this number of components, so you'll find better the first EPB */
  JPWL_MAXIMUM_TILES = 8192; //**< Expect this maximum number of tiles, to avoid some crashes */
  JPWL_MAXIMUM_HAMMING = 2; //**< Expect this maximum number of bit errors in marker id's */
  JPWL_MAXIMUM_EPB_ROOM = 65450; //**< Expect this maximum number of bytes for composition of EPBs */
//* <<UniPG */


{**
 * EXPERIMENTAL FOR THE MOMENT
 * Supported options about file information used only in j2k_dump
*}
  OPJ_IMG_INFO		= 1;	//**< Basic image information provided to the user */
  OPJ_J2K_MH_INFO	 = 2;	//**< Codestream information based only on the main header */
  OPJ_J2K_TH_INFO	 = 4;	//**< Tile information based on the current tile header */
  OPJ_J2K_TCH_INFO = 8;	//**< Tile/Component information of all tiles */
  OPJ_J2K_MH_IND	 = 16;	//**< Codestream index based only on the main header */
  OPJ_J2K_TH_IND	 = 32;	//**< Tile index based on the current tile */
//*FIXME #define OPJ_J2K_CSTR_IND	48*/	/**<  */
  OPJ_JP2_INFO		= 128;	//**< JP2 file information */
  OPJ_JP2_IND			= 256;	//**< JP2 file index */


{**
 * JPEG 2000 Profiles, see Table A.10 from 15444-1 (updated in various AMD)
 * These values help chosing the RSIZ value for the J2K codestream.
 * The RSIZ value triggers various encoding options, as detailed in Table A.10.
 * If OPJ_PROFILE_PART2 is chosen, it has to be combined with one or more extensions
 * described hereunder.
 *   Example: rsiz = OPJ_PROFILE_PART2 | OPJ_EXTENSION_MCT;
 * For broadcast profiles, the OPJ_PROFILE value has to be combined with the targeted
 * mainlevel (3-0 LSB, value between 0 and 11):
 *   Example: rsiz = OPJ_PROFILE_BC_MULTI | 0x0005; (here mainlevel 5)
 * For IMF profiles, the OPJ_PROFILE value has to be combined with the targeted mainlevel
 * (3-0 LSB, value between 0 and 11) and sublevel (7-4 LSB, value between 0 and 9):
 *   Example: rsiz = OPJ_PROFILE_IMF_2K | 0x0040 | 0x0005; (here main 5 and sublevel 4)
 * *}
  OPJ_PROFILE_NONE        = $0000; //** no profile, conform to 15444-1 */
  OPJ_PROFILE_0           = $0001; //** Profile 0 as described in 15444-1,Table A.45 */
  OPJ_PROFILE_1           = $0002; //** Profile 1 as described in 15444-1,Table A.45 */
  OPJ_PROFILE_PART2       = $8000; //** At least 1 extension defined in 15444-2 (Part-2) */
  OPJ_PROFILE_CINEMA_2K   = $0003; //** 2K cinema profile defined in 15444-1 AMD1 */
  OPJ_PROFILE_CINEMA_4K   = $0004; //** 4K cinema profile defined in 15444-1 AMD1 */
  OPJ_PROFILE_CINEMA_S2K  = $0005; //** Scalable 2K cinema profile defined in 15444-1 AMD2 */
  OPJ_PROFILE_CINEMA_S4K  = $0006; //** Scalable 4K cinema profile defined in 15444-1 AMD2 */
  OPJ_PROFILE_CINEMA_LTS  = $0007; //** Long term storage cinema profile defined in 15444-1 AMD2 */
  OPJ_PROFILE_BC_SINGLE   = $0100; //** Single Tile Broadcast profile defined in 15444-1 AMD3 */
  OPJ_PROFILE_BC_MULTI    = $0200; //** Multi Tile Broadcast profile defined in 15444-1 AMD3 */
  OPJ_PROFILE_BC_MULTI_R  = $0300; //** Multi Tile Reversible Broadcast profile defined in 15444-1 AMD3 */
  OPJ_PROFILE_IMF_2K      = $0400; //** 2K Single Tile Lossy IMF profile defined in 15444-1 AMD 8 */
  OPJ_PROFILE_IMF_4K      = $0401; //** 4K Single Tile Lossy IMF profile defined in 15444-1 AMD 8 */
  OPJ_PROFILE_IMF_8K      = $0402; //** 8K Single Tile Lossy IMF profile defined in 15444-1 AMD 8 */
  OPJ_PROFILE_IMF_2K_R    = $0403; //** 2K Single/Multi Tile Reversible IMF profile defined in 15444-1 AMD 8 */
  OPJ_PROFILE_IMF_4K_R    = $0800; //** 4K Single/Multi Tile Reversible IMF profile defined in 15444-1 AMD 8 */
  OPJ_PROFILE_IMF_8K_R    = $0801; //** 8K Single/Multi Tile Reversible IMF profile defined in 15444-1 AMD 8 */

{**
 * JPEG 2000 Part-2 extensions
 * *}
  OPJ_EXTENSION_NONE      = $0000; //** No Part-2 extension */
  OPJ_EXTENSION_MCT       = $0100;  //** Custom MCT support */

{**
 * JPEG 2000 profile macros
 * *}

function OPJ_IS_CINEMA(v : Integer)  : Boolean; inline;
function OPJ_IS_STORAGE(v : Integer) : Boolean; inline;
function OPJ_IS_BROADCAST(v : Integer) : Boolean; inline;
function OPJ_IS_IMF(v : Integer) : Boolean; inline;
function OPJ_IS_PART2(v : Integer) : Integer; inline;

const
{**
 * JPEG 2000 codestream and component size limits in cinema profiles
 * *}
  OPJ_CINEMA_24_CS    = 1302083;  	//** Maximum codestream length for 24fps */
  OPJ_CINEMA_48_CS    = 651041;    //** Maximum codestream length for 48fps */
  OPJ_CINEMA_24_COMP  = 1041666;   //** Maximum size per color component for 2K & 4K @ 24fps */
  OPJ_CINEMA_48_COMP  = 520833;		//** Maximum size per color component for 2K @ 48fps */

{*
==========================================================
   enum definitions
==========================================================
*}

type
{**
 * DEPRECATED: use RSIZ, OPJ_PROFILE_* and OPJ_EXTENSION_* instead
 * Rsiz Capabilities
 * *}
  RSIZ_CAPABILITIES = (
    OPJ_STD_RSIZ = 0,		//** Standard JPEG2000 profile*/
    OPJ_CINEMA2K = 3,		//** Profile name for a 2K image*/
    OPJ_CINEMA4K = 4,		//** Profile name for a 4K image*/
    OPJ_MCT = $8100);

  OPJ_RSIZ_CAPABILITIES = RSIZ_CAPABILITIES;

{**
 * DEPRECATED: use RSIZ, OPJ_PROFILE_* and OPJ_EXTENSION_* instead
 * Digital cinema operation mode
 * *}
  CINEMA_MODE = (
    OPJ_OFF = 0,			//** Not Digital Cinema*/
    OPJ_CINEMA2K_24 = 1,	//** 2K Digital Cinema at 24 fps*/
    OPJ_CINEMA2K_48 = 2,	//** 2K Digital Cinema at 48 fps*/
    OPJ_CINEMA4K_24 = 3		//** 4K Digital Cinema at 24 fps*/
  );
  OPJ_CINEMA_MODE = CINEMA_MODE;

{**
 * Progression order
 * *}
  PROG_ORDER = (
  	OPJ_PROG_UNKNOWN = -1,	//**< place-holder */
   	OPJ_LRCP = 0,			//**< layer-resolution-component-precinct order */
	  OPJ_RLCP = 1,			//**< resolution-layer-component-precinct order */
	  OPJ_RPCL = 2,			//**< resolution-precinct-component-layer order */
	  OPJ_PCRL = 3,			//**< precinct-component-resolution-layer order */
	  OPJ_CPRL = 4			//**< component-precinct-resolution-layer order */
  );
  OPJ_PROG_ORDER = PROG_ORDER;

{**
 * Supported image color spaces
*}
  COLOR_SPACE = (
    OPJ_CLRSPC_UNKNOWN = -1,	//**< not supported by the library */
    OPJ_CLRSPC_UNSPECIFIED = 0,	//**< not specified in the codestream */
    OPJ_CLRSPC_SRGB = 1,		//**< sRGB */
    OPJ_CLRSPC_GRAY = 2,		//**< grayscale */
    OPJ_CLRSPC_SYCC = 3,		//**< YUV */
    OPJ_CLRSPC_EYCC = 4,        //**< e-YCC */
    OPJ_CLRSPC_CMYK = 5         //**< CMYK */
  );
  OPJ_COLOR_SPACE = COLOR_SPACE;

{**
 * Supported codec
*}
  CODEC_FORMAT = (
    OPJ_CODEC_UNKNOWN = -1,	//**< place-holder */
    OPJ_CODEC_J2K  = 0,		//**< JPEG-2000 codestream : read/write */
	  OPJ_CODEC_JPT  = 1,		//**< JPT-stream (JPEG 2000, JPIP) : read only */
    OPJ_CODEC_JP2  = 2,		//**< JP2 file format : read/write */
    OPJ_CODEC_JPP  = 3,		//**< JPP-stream (JPEG 2000, JPIP) : to be coded */
    OPJ_CODEC_JPX  = 4		//**< JPX file format (JPEG 2000 Part-2) : to be coded */
  );
  OPJ_CODEC_FORMAT = CODEC_FORMAT;


{*
==========================================================
   event manager typedef definitions
==========================================================
*}

{**
 * Callback function prototype for events
 * @param msg               Event message
 * @param client_data       Client object where will be return the event message
 * *}

  opj_msg_callback = procedure(msg : PAnsiChar; client_data : Pointer) cdecl;

{*
==========================================================
   codec typedef definitions
==========================================================
*}

{**
 * Progression order changes
 *
 *}
  opj_poc = packed record
	//** Resolution num start, Component num start, given by POC */
	  resno0, compno0 : OPJ_UINT32;
	//** Layer num end,Resolution num end, Component num end, given by POC */
	  layno1, resno1, compno1 : OPJ_UINT32;
	//** Layer num start,Precinct num start, Precinct num end */
	 layno0, precno0, precno1 : OPJ_UINT32;
	//** Progression order enum*/
	  prg1,prg : OPJ_PROG_ORDER;
	//** Progression order string*/
	 progorder : array [0..4] of OPJ_CHAR;
	//** Tile number */
	 tile :OPJ_UINT32;
	//** Start and end values for Tile width and height*/
	 tx0,tx1,ty0,ty1 : OPJ_INT32;
	//** Start value, initialised in pi_initialise_encode*/
	 layS, resS, compS, prcS : OPJ_UINT32;
	//** End value, initialised in pi_initialise_encode */
	 layE, resE, compE, prcE : OPJ_UINT32;
	//** Start and end values of Tile width and height, initialised in pi_initialise_encode*/
	 txS,txE,tyS,tyE,dx,dy : OPJ_UINT32;
	//** Temporary values for Tile parts, initialised in pi_create_encode */
	 lay_t, res_t, comp_t, prc_t,tx0_t,ty0_t : OPJ_UINT32;
  end;
  opj_poc_t = opj_poc;

{**
 * Compression parameters
 * *}
  opj_cparameters = record
	  //** size of tile: tile_size_on = false (not in argument) or = true (in argument) */
    tile_size_on :OPJ_BOOL;
    //** XTOsiz */
    cp_tx0 : TIdC_INT;
	  //** YTOsiz */
	  cp_ty0 : TIdC_INT;
	  //** XTsiz */
    cp_tdx : TIdC_INT;
	  //** YTsiz */
    cp_tdy : TIdC_INT;
	  //** allocation by rate/distortion */
    cp_disto_alloc : TIdC_INT;
   	//** allocation by fixed layer */
    cp_fixed_alloc : TIdC_INT;
   	//** add fixed_quality */
    cp_fixed_quality : TIdC_INT;
    //** fixed layer */
    cp_matrice : PIdC_INT;
    //** comment for coding */
    cp_comment : PAnsiChar;
    //** csty : coding style */
    csty : TIdC_INT;
    //** progression order (default OPJ_LRCP) */
    prog_order : OPJ_PROG_ORDER;
    //** progression order changes */
	  POC : array [0..31] of opj_poc_t;
    //** number of progression order changes (POC), default to 0 */
    numpocs : OPJ_UINT32;
    //** number of layers */
    tcp_numlayers : TIdC_INT;
    //** rates of layers - might be subsequently limited by the max_cs_size field */
    tcp_rates : array [0..99] of TIdC_FLOAT;
	  //** different psnr for successive layers */
    tcp_distoratio : array[0..99] of TIdC_FLOAT;
    //** number of resolutions */
    numresolution : TIdC_INT;
    //** initial code block width, default to 64 */
    cblockw_init : TIdC_INT;
	  //** initial code block height, default to 64 */
    cblockh_init : TIdC_INT;
	  //** mode switch (cblk_style) */
    mode : TIdC_INT;
    //** 1 : use the irreversible DWT 9-7, 0 : use lossless compression (default) */
   	irreversible : TIdC_INT;
    //** region of interest: affected component in [0..3], -1 means no ROI */
	  roi_compno : TIdC_INT;
    //** region of interest: upshift value */
    roi_shift : TIdC_INT;
    //* number of precinct size specifications */
    res_spec : TIdC_INT;
    //** initial precinct width */
    prcw_init : array[0..(OPJ_J2K_MAXRLVLS - 1)] of TIdC_INT;
   	//** initial precinct height */
    prch_init: array[0..(OPJ_J2K_MAXRLVLS - 1)] of TIdC_INT;

  	//**@name command line encoder parameters (not used inside the library) */
  	//*@{*/
  	//** input file name */
    infile : array[0..(OPJ_PATH_LEN - 1)] of Byte;
    //** output file name */
    outfile: array[0..(OPJ_PATH_LEN - 1)] of Byte;
	  //** DEPRECATED. Index generation is now handeld with the opj_encode_with_info() function. Set to NULL */
    index_on : TIdC_INT;
	  //** DEPRECATED. Index generation is now handeld with the opj_encode_with_info() function. Set to NULL */
   	index: array [0..(OPJ_PATH_LEN - 1)] of byte;
   	//** subimage encoding: origin image offset in x direction */
    image_offset_x0 : TIdC_INT;
    //** subimage encoding: origin image offset in y direction */
    image_offset_y0 : TIdC_INT;
  	//** subsampling value for dx */
    subsampling_dx : TIdC_INT;
    //** subsampling value for dy */
    subsampling_dy : TIdC_INT;
    //** input file format 0: PGX, 1: PxM, 2: BMP 3:TIF*/
    decod_format : TIdC_INT;
    //** output file format 0: J2K, 1: JP2, 2: JPT */
    cod_format : TIdC_INT;
    //*@}*/

    //* UniPG>> */ /* NOT YET USED IN THE V2 VERSION OF OPENJPEG */
	  //**@name JPWL encoding parameters */
	  //*@{*/
	  //** enables writing of EPC in MH, thus activating JPWL */
    jpwl_epc_on : OPJ_BOOL;
    //** error protection method for MH (0,1,16,32,37-128) */
	  jpwl_hprot_MH : TIdC_INT;
    //** tile number of header protection specification (>=0) */
	  jpwl_hprot_TPH_tileno: array[0..(JPWL_MAX_NO_TILESPECS - 1)] of TIdC_INT;
    //** error protection methods for TPHs (0,1,16,32,37-128) */
    jpwl_hprot_TPH : array[0..(JPWL_MAX_NO_TILESPECS - 1)] of TIdC_INT;
    //** tile number of packet protection specification (>=0) */
    jpwl_pprot_tileno:array[0..(JPWL_MAX_NO_PACKSPECS - 1)] of TIdC_INT;
   	//** packet number of packet protection specification (>=0) */
    jpwl_pprot_packno:array[0..(JPWL_MAX_NO_PACKSPECS - 1)] of TIdC_INT;
    //** error protection methods for packets (0,1,16,32,37-128) */
    jpwl_pprot: array[0..(JPWL_MAX_NO_PACKSPECS - 1)] of TIdC_INT;
    //** enables writing of ESD, (0=no/1/2 bytes) */
    jpwl_sens_size : TIdC_INT;
    //** sensitivity addressing size (0=auto/2/4 bytes) */
    jpwl_sens_addr : TIdC_INT;
	  //** sensitivity range (0-3) */
    jpwl_sens_range : TIdC_INT;
    //** sensitivity method for MH (-1=no,0-7) */
    jpwl_sens_MH : TIdC_INT;
    //** tile number of sensitivity specification (>=0) */
    jpwl_sens_TPH_tileno : array[0..(JPWL_MAX_NO_TILESPECS - 1)] of  TIdC_INT;
   	//** sensitivity methods for TPHs (-1=no,0-7) */
    jpwl_sens_TPH : array[0..(JPWL_MAX_NO_TILESPECS -1)] of  TIdC_INT;
   	//*@}*/
    {* <<UniPG *}

    {**
     * DEPRECATED: use RSIZ, OPJ_PROFILE_* and MAX_COMP_SIZE instead
     * Digital Cinema compliance 0-not compliant, 1-compliant
     * *}
    cp_cinema : OPJ_CINEMA_MODE;
    {**
     * Maximum size (in bytes) for each component.
     * If == 0, component size limitation is not considered
     * *}
	  max_comp_size : TIdC_INT;
    {**
     * DEPRECATED: use RSIZ, OPJ_PROFILE_* and OPJ_EXTENSION_* instead
     * Profile name
     * *}
    cp_rsiz : OPJ_RSIZ_CAPABILITIES;
    //** Tile part generation*/
    tp_on : Byte;
    //** Flag for Tile part generation*/
    tp_flag : Byte;
    //** MCT (multiple component transform) */
    tcp_mct : Byte;
    //** Enable JPIP indexing*/
	  jpip_on : OPJ_BOOL;
    {** Naive implementation of MCT restricted to a single reversible array based
        encoding without offset concerning all the components. *}
    mct_data : Pointer;
    {**
     * Maximum size (in bytes) for the whole codestream.
     * If == 0, codestream size limitation is not considered
     * If it does not comply with tcp_rates, max_cs_size prevails
     * and a warning is issued.
     * *}
    max_cs_size : TIdC_INT;
    {** RSIZ value
        To be used to combine OPJ_PROFILE_*, OPJ_EXTENSION_* and (sub)levels values. *}
     rsiz : OPJ_UINT16;
  end;
  popj_cparameters = ^opj_cparameters;
  opj_cparameters_t = opj_cparameters;
  popj_cparameters_t = ^opj_cparameters_t;

const
  OPJ_DPARAMETERS_IGNORE_PCLR_CMAP_CDEF_FLAG = $0001;

type
{**
 * Decompression parameters
 * *}
  opj_dparameters = record
	{**
	Set the number of highest resolution levels to be discarded.
	The image resolution is effectively divided by 2 to the power of the number of discarded levels.
	The reduce factor is limited by the smallest total number of decomposition levels among tiles.
	if != 0, then original dimension divided by 2^(reduce);
	if == 0 or not used, image is decoded to the full resolution
	*}
    cp_reduce : OPJ_UINT32;
	{**
	Set the maximum number of quality layers to decode.
	If there are less quality layers than the specified number, all the quality layers are decoded.
	if != 0, then only the first "layer" layers are decoded;
	if == 0 or not used, all the quality layers are decoded
	*}
    cp_layer : OPJ_UINT32;

    //**@name command line decoder parameters (not used inside the library) */
    //*@{*/
    //** input file name */
	  infile : array [0..(OPJ_PATH_LEN - 1)] of byte;
   	//** output file name */
	  outfile : array [0..(OPJ_PATH_LEN - 1)] of byte;
    //** input file format 0: J2K, 1: JP2, 2: JPT */
    decod_format : TIdC_INT;
    //** output file format 0: PGX, 1: PxM, 2: BMP */
    cod_format : TIdC_INT;

    //** Decoding area left boundary */
    DA_x0 : OPJ_UINT32;
	  //** Decoding area right boundary */
	  DA_x1 : OPJ_UINT32;
    //** Decoding area up boundary */
    DA_y0 : OPJ_UINT32;
    //** Decoding area bottom boundary */
    DA_y1 : OPJ_UINT32;
    //** Verbose mode */
    m_verbose : OPJ_BOOL;

    //** tile number ot the decoded tile*/
    tile_index : OPJ_UINT32;
    //** Nb of tile to decode */
    nb_tile_to_decode : OPJ_UINT32;

    //*@}*/

    //* UniPG>> */ /* NOT YET USED IN THE V2 VERSION OF OPENJPEG */
    //**@name JPWL decoding parameters */
    //*@{*/
    //** activates the JPWL correction capabilities */
    jpwl_correct : OPJ_BOOL;
    //** expected number of components */
    jpwl_exp_comps : TIdC_INT;
    //** maximum number of tiles */
    jpwl_max_tiles : TIdC_INT;
    //*@}*/
    //* <<UniPG */

    flags : TIdC_UINT;

  end;
  popj_dparameters = ^opj_dparameters;
  opj_dparameters_t = opj_dparameters;
  popj_dparameters_t = ^opj_dparameters_t;

{**
 * JPEG2000 codec V2.
 * *}
  opj_codec_t = Pointer;
  popj_codec_t = ^opj_codec_t;

{*
==========================================================
   I/O stream typedef definitions
==========================================================
*}
const
{**
 * Stream open flags.
 * *}
//** The stream was opened for reading. */
  OPJ_STREAM_READ	= OPJ_TRUE;
//** The stream was opened for writing. */
  OPJ_STREAM_WRITE = OPJ_FALSE;

type
{*
 * Callback function prototype for read function
 *}
  opj_stream_read_fn = function (p_buffer : Pointer; p_nb_bytes : OPJ_SIZE_T; p_user_data : Pointer) : OPJ_SIZE_T cdecl;

{*
 * Callback function prototype for write function
 *}
  opj_stream_write_fn = function (p_buffer : Pointer;  p_nb_bytes : OPJ_SIZE_T; p_user_data : Pointer) : OPJ_SIZE_T cdecl;

{*
 * Callback function prototype for skip function
 *}
  opj_stream_skip_fn = function ( p_nb_bytes : OPJ_OFF_T; p_user_data : Pointer) : OPJ_OFF_T cdecl;

{*
 * Callback function prototype for seek function
 *}
  opj_stream_seek_fn = function ( p_nb_bytes : OPJ_OFF_T; p_user_data : Pointer) : OPJ_BOOL cdecl;

{*
 * Callback function prototype for free user data function
 *}
  opj_stream_free_user_data_fn = procedure (p_user_data : Pointer) cdecl;

{*
 * JPEG2000 Stream.
 *}
  opj_stream_t = Pointer;
  popj_stream_t = ^opj_stream_t;

{*
==========================================================
   image typedef definitions
==========================================================
*}

{**
 * Defines a single image component
 * *}
  obj_image_comp_data = array [0..255] of  OPJ_INT32;
  pobj_image_comp_data = ^obj_image_comp_data;
  opj_image_comp = record
    //** XRsiz: horizontal separation of a sample of ith component with respect to the reference grid */
	  dx : OPJ_UINT32;
    //** YRsiz: vertical separation of a sample of ith component with respect to the reference grid */
	  dy : OPJ_UINT32;
	  //** data width */
    w : OPJ_UINT32;
    //** data height */
    h : OPJ_UINT32;
    //** x component offset compared to the whole image */
    x0 : OPJ_UINT32;
    //** y component offset compared to the whole image */
    y0 : OPJ_UINT32;
    //** precision */
    prec : OPJ_UINT32;
    //** image depth in bits */
    bpp : OPJ_UINT32;
	  //** signed (1) / unsigned (0) */
    sgnd : OPJ_UINT32;
    //** number of decoded resolution */
    resno_decoded : OPJ_UINT32;
    //** number of division by 2 of the out image compared to the original size of image */
    factor : OPJ_UINT32;
    //** image component data */
    data : pobj_image_comp_data; //POPJ_INT32;
    //** alpha channel */
    alpha : OPJ_UINT16;
  end;
  popj_image_comp = ^opj_image_comp;
  opj_image_comp_t = opj_image_comp;
  popj_image_comp_t = ^opj_image_comp_t;
  opj_image_comp_array = array[0..255] of opj_image_comp_t;
  popj_image_comp_array = ^opj_image_comp_array;
{**
 * Defines image data and characteristics
 * *}
  opj_image = record
    //** XOsiz: horizontal offset from the origin of the reference grid to the left side of the image area */
	  x0 : OPJ_UINT32;
    //** YOsiz: vertical offset from the origin of the reference grid to the top side of the image area */
    y0 : OPJ_UINT32;
	  //** Xsiz: width of the reference grid */
	  x1 : OPJ_UINT32;
    //** Ysiz: height of the reference grid */
	  y1 : OPJ_UINT32;
    //** number of components in the image */
	  numcomps : OPJ_UINT32;
	  //** color space: sRGB, Greyscale or YUV */
	  color_space : OPJ_COLOR_SPACE;
	  //** image components */
	  comps : Popj_image_comp_array; //Popj_image_comp_t;
	  //** 'restricted' ICC profile */
	  icc_profile_buf : POPJ_BYTE;
	  //** size of ICC profile */
	  icc_profile_len : OPJ_UINT32;
  end;
  popj_image = ^opj_image;
  opj_image_t = opj_image;
  popj_image_t = ^opj_image_t;
{**
 * Component parameters structure used by the opj_image_create function
 * *}
  opj_image_comptparm = record
    //** XRsiz: horizontal separation of a sample of ith component with respect to the reference grid */
   	dx : OPJ_UINT32;
  	//** YRsiz: vertical separation of a sample of ith component with respect to the reference grid */
    dy : OPJ_UINT32;
   	//** data width */
	  w : OPJ_UINT32;
    //** data height */
    h : OPJ_UINT32;
	  //** x component offset compared to the whole image */
    x0 : OPJ_UINT32;
    //** y component offset compared to the whole image */
    y0 : OPJ_UINT32;
    //** precision */
    prec : OPJ_UINT32;
	  //** image depth in bits */
    bpp : OPJ_UINT32;
    //** signed (1) / unsigned (0) */
    sgnd : OPJ_UINT32;
  end;
  popj_image_comptparm = ^opj_image_comptparm;
  opj_image_cmptparm_t = opj_image_comptparm;
  popj_image_cmptparm_t = ^opj_image_cmptparm_t;


{*
==========================================================
   Information on the JPEG 2000 codestream
==========================================================
*}
//* QUITE EXPERIMENTAL FOR THE MOMENT */

{**
 * Index structure : Information concerning a packet inside tile
 * *}
  opj_packet_info = record
    //** packet start position (including SOP marker if it exists) */
    start_pos : OPJ_OFF_T;
    //** end of packet header position (including EPH marker if it exists)*/
    end_ph_pos : OPJ_OFF_T;
    //** packet end position */
    end_pos : OPJ_OFF_T;
    //** packet distorsion */
    disto : TIdC_Double;
  end;
  popj_packet_info = ^opj_packet_info;
  opj_packet_info_t = opj_packet_info;
  popj_packet_info_t = ^opj_packet_info_t;


//* UniPG>> */
{**
 * Marker structure
 * *}
  opj_marker_info = record
	  //** marker type */
	  _type : TIdC_USHORT;
	  //** position in codestream */
    pos : OPJ_OFF_T;
	//** length, marker val included */
	  len : TIdC_INT;
  end;
  popj_marker_info = ^opj_marker_info;
  opj_marker_info_t = opj_marker_info;
  popj_marker_info_t = ^opj_marker_info_t;
//* <<UniPG */

{**
 * Index structure : Information concerning tile-parts
*}
  opj_tp_info = record
	  //** start position of tile part */
	  tp_start_pos : TIdC_INT;
	  //** end position of tile part header */
	  tp_end_header : TIdC_INT;
	  //** end position of tile part */
	  tp_end_pos : TIdC_INT;
   	//** start packet of tile part */
	  tp_start_pack : TIdC_INT;
	  //** number of packets of tile part */
    tp_numpacks : TIdC_INT;
  end;
  popj_tp_info = ^opj_tp_info;
  opj_tp_info_t = opj_tp_info;
  popj_tp_info_t = ^opj_tp_info_t;
{**
 * Index structure : information regarding tiles
*}
  opj_tile_info = record
    //** value of thresh for each layer by tile cfr. Marcela   */
	  thresh : ^TIdC_Double;
    //** number of tile */
    tileno : TIdC_INT;
    //** start position */
    start_pos : TIdC_INT;
    //** end position of the header */
    end_header : TIdC_INT;
    //** end position */
    end_pos : TIdC_INT;
    //** precinct number for each resolution level (width) */
    pw : array[0..32] of TIdC_INT;
    //** precinct number for each resolution level (height) */
    ph: array[0..32] of TIdC_INT;
    //** precinct size (in power of 2), in X for each resolution level */
    pdx : array[0..32] of TIdC_INT;
    //** precinct size (in power of 2), in Y for each resolution level */
    pdy : array[0..32] of TIdC_INT;
    //** information concerning packets inside tile */
    packet : popj_packet_info_t;
    //** add fixed_quality */
    numpix : TIdC_INT;
    //** add fixed_quality */
    distotile : TIdC_Double;
    //** number of markers */
    marknum: TIdC_INT;
    //** list of markers */
    marker : popj_marker_info_t;
    //** actual size of markers array */
    maxmarknum: TIdC_INT;
	  //** number of tile parts */
    num_tps: TIdC_INT;
    //** information concerning tile parts */
    tp : popj_tp_info_t;
  end;
  popj_tile_info = ^opj_tile_info;
  opj_tile_info_t = opj_tile_info;
  popj_tile_info_t = ^opj_tile_info_t;

{**
 * Index structure of the codestream
*}
  opj_codestream_info = record
    //** maximum distortion reduction on the whole image (add for Marcela) */
    D_max : TIdC_Double;
    //** packet number */
    packno : TIdC_INT;
    //** writing the packet in the index with t2_encode_packets */
    index_write : TIdC_INT;
    //** image width */
    image_w : TIdC_INT;
    //** image height */
    image_h : TIdC_INT;
    //** progression order */
    prog : OPJ_PROG_ORDER;
    //** tile size in x */
    tile_x : TIdC_INT;
    //** tile size in y */
    tile_y : TIdC_INT;
    //** */
    tile_Ox : TIdC_INT;
    //** */
    tile_Oy : TIdC_INT;
    //** number of tiles in X */
    tw : TIdC_INT;
	  //** number of tiles in Y */
    th : TIdC_INT;
    //** component numbers */
    numcomps : TIdC_INT;
    //** number of layer */
    numlayers : TIdC_INT;
    //** number of decomposition for each component */
    numdecompos : PIdC_INT;
    //* UniPG>> */
    //** number of markers */
    marknum : TIdC_INT;
    //** list of markers */
    marker : popj_marker_info_t;
    //** actual size of markers array */
    maxmarknum : TIdC_INT;
    //* <<UniPG */
    //** main header position */
    main_head_start : TIdC_INT;
    //** main header position */
    main_head_end : TIdC_INT;
    //** codestream's size */
    codestream_size : TIdC_INT;
    //** information regarding tiles inside image */
    tile : popj_tile_info_t;
  end;
  popj_codestream_info = ^opj_codestream_info;
  opj_codestream_info_t = opj_codestream_info;
  popj_codestream_info_t = ^opj_codestream_info_t;

//* <----------------------------------------------------------- */
//* new output managment of the codestream information and index */

{**
 * Tile-component coding parameters information
 *}
  opj_tccp_info = record
	  //** component index */
    compno : OPJ_UINT32;
	  //** coding style */
    csty : OPJ_UINT32;
    //** number of resolutions */
    numresolutions : OPJ_UINT32;
    //** code-blocks width */
    cblkw : OPJ_UINT32;
    //** code-blocks height */
    cblkh : OPJ_UINT32;
    //** code-block coding style */
    cblksty : OPJ_UINT32;
    //** discrete wavelet transform identifier */
    qmfbid : OPJ_UINT32;
    //** quantisation style */
    qntsty : OPJ_UINT32;
    //** stepsizes used for quantization */
    stepsizes_mant : array[0..(OPJ_J2K_MAXBANDS-1)] of OPJ_UINT32;
    //** stepsizes used for quantization */
    stepsizes_expn : array[0..(OPJ_J2K_MAXBANDS-1)] of OPJ_UINT32;
    //** number of guard bits */
    numgbits : OPJ_UINT32;
    //** Region Of Interest shift */
    roishift : OPJ_UINT32;
    //** precinct width */
    prcw : array[0..(OPJ_J2K_MAXRLVLS-1)] of OPJ_UINT32;
    //** precinct height */
    prch : array[0..(OPJ_J2K_MAXRLVLS -1)] of OPJ_UINT32;
  end;
  popj_tccp_info = ^opj_tccp_info;
  opj_tccp_info_t = opj_tccp_info;
  popj_tccp_info_t = ^opj_tccp_info_t;

{**
 * Tile coding parameters information
 *}
  opj_tile_v2_info = record

    //** number (index) of tile */
    tileno : TIdC_INT;
    //** coding style */
    csty : OPJ_UINT32;
    //** progression order */
    prg : OPJ_PROG_ORDER;
    //** number of layers */
    numlayers : OPJ_UINT32;
    //** multi-component transform identifier */
    mct :OPJ_UINT32;
    //** information concerning tile component parameters*/
    tccp_info : popj_tccp_info_t;
  end;
  popj_tile_v2_info = ^opj_tile_v2_info;
  opj_tile_info_v2_t = opj_tile_v2_info;
  popj_tile_info_v2_t = ^opj_tile_info_v2_t;
{**
 * Information structure about the codestream (FIXME should be expand and enhance)
 *}
  opj_codestream_info_v2 = record
    //* Tile info */
    //** tile origin in x = XTOsiz */
    tx0 : OPJ_UINT32;
    //** tile origin in y = YTOsiz */
    ty0 : OPJ_UINT32;
    //** tile size in x = XTsiz */
    tdx : OPJ_UINT32;
    //** tile size in y = YTsiz */
    tdy : OPJ_UINT32;
    //** number of tiles in X */
    tw : OPJ_UINT32;
    //** number of tiles in Y */
    th : OPJ_UINT32;

    //** number of components*/
    nbcomps : OPJ_UINT32;

    //** Default information regarding tiles inside image */
    m_default_tile_info : opj_tile_info_v2_t;

    //** information regarding tiles inside image */
    tile_info : popj_tile_info_v2_t; //* FIXME not used for the moment */

  end;
  popj_codestream_info_v2 = ^opj_codestream_info_v2;
  opj_codestream_info_v2_t = opj_codestream_info_v2;
  popj_codestream_info_v2_t = ^opj_codestream_info_v2_t;

{**
 * Index structure about a tile part
 *}
  opj_tp_index = record
    //** start position */
    start_pos : OPJ_OFF_T;
	  //** end position of the header */
    end_header : OPJ_OFF_T;
	  //** end position */
    end_pos : OPJ_OFF_T;
  end;
  popj_tp_index = ^opj_tp_index;
  opj_tp_index_t = opj_tp_index;
  popj_tp_index_t = ^opj_tp_index_t;

{**
 * Index structure about a tile
 *}
  opj_tile_index = record
	  //** tile index */
    tileno : OPJ_UINT32;

	  //** number of tile parts */
    nb_tps : OPJ_UINT32;
	  //** current nb of tile part (allocated)*/
    current_nb_tps : OPJ_UINT32;
	  //** current tile-part index */
    current_tpsno : OPJ_UINT32;
    //** information concerning tile parts */
    tp_index : popj_tp_index_t;

    //* UniPG>> */ /* NOT USED FOR THE MOMENT IN THE V2 VERSION */
		//** number of markers */
    marknum : OPJ_UINT32;
		//** list of markers */
   	marker : popj_marker_info_t;
		//** actual size of markers array */
    maxmarknum : OPJ_UINT32;
    //* <<UniPG */

    //** packet number */
    nb_packet : OPJ_UINT32;
    //** information concerning packets inside tile */
    packet_index : popj_packet_info_t;
  end;
  popj_tile_index = ^opj_tile_index;
  opj_tile_index_t = opj_tile_index;
  popj_tile_index_t = ^opj_tile_index_t;

{**
 * Index structure of the codestream (FIXME should be expand and enhance)
 *}
  opj_codestream_index = record
	  //** main header start position (SOC position) */
    main_head_start : OPJ_OFF_T;
    //** main header end position (first SOT position) */
    main_head_end : OPJ_OFF_T;

	  //** codestream's size */
    codestream_size : OPJ_UINT64;

    //* UniPG>> */ /* NOT USED FOR THE MOMENT IN THE V2 VERSION */
	  //** number of markers */
	  marknum : OPJ_UINT32;
  	//** list of markers */
    marker : popj_marker_info_t;
    //** actual size of markers array */
    maxmarknum : OPJ_UINT32;
    //* <<UniPG */

    //** */
    nb_of_tiles : OPJ_UINT32;
    //** */
    tile_index : popj_tile_index_t; //* FIXME not used for the moment */

  end;
  popj_codestream_index = ^opj_codestream_index;
  opj_codestream_index_t = opj_codestream_index;
  popj_codestream_index_t = ^opj_codestream_index_t;

//* -----------------------------------------------------------> */

{*
==========================================================
   Metadata from the JP2file
==========================================================
*}

{**
 * Info structure of the JP2 file
 * EXPERIMENTAL FOR THE MOMENT
 *}
  opj_jp2_metadata = record
	//** */
		not_used :OPJ_INT32;

  end;
  popj_jp2_metadata = ^opj_jp2_metadata;
  opj_jp2_metadata_t = opj_jp2_metadata;
  popj_jp2_metadata_t = ^opj_jp2_metadata_t;

{**
 * Index structure of the JP2 file
 * EXPERIMENTAL FOR THE MOMENT
 *}
  opj_jp2_index = record
    //** */
    not_used : OPJ_INT32;
  end;
  popj_jp2_index = ^opj_jp2_index;
  opj_jp2_index_t = opj_jp2_index;
  popj_jp2_index_t = ^opj_jp2_index_t;

  //* Get the version of the openjpeg library*/
  LPFN_opj_version = function : PAnsiChar stdcall;
{*
==========================================================
   image functions definitions
==========================================================
*}

{**
 * Create an image
 *
 * @param numcmpts      number of components
 * @param cmptparms     components parameters
 * @param clrspc        image color space
 * @return returns      a new image structure if successful, returns NULL otherwise
 * *}
  LPFN_opj_image_create = function( numcmpts : OPJ_UINT32; cmptparms : opj_image_cmptparm_t; clrspc : OPJ_COLOR_SPACE) : popj_image_t stdcall;
{**
 * Deallocate any resources associated with an image
 *
 * @param image         image to be destroyed
 *}
  LPFN_opj_image_destroy = procedure(image : popj_image_t) stdcall;

{**
 * Creates an image without allocating memory for the image (used in the new version of the library).
 *
 * @param	numcmpts    the number of components
 * @param	cmptparms   the components parameters
 * @param	clrspc      the image color space
 *
 * @return	a new image structure if successful, NULL otherwise.
*}
  LPFN_opj_image_tile_create = function( numcmpts : OPJ_UINT32; cmptparms : popj_image_cmptparm_t;  clrspc : OPJ_COLOR_SPACE) : popj_image_t stdcall;

{*
==========================================================
   stream functions definitions
==========================================================
*}

{**
 * Creates an abstract stream. This function does nothing except allocating memory and initializing the abstract stream.
 *
 * @param	p_is_input		if set to true then the stream will be an input stream, an output stream else.
 *
 * @return	a stream object.
*}

  LPFN_opj_stream_default_create = function( p_is_input : OPJ_BOOL) : popj_stream_t stdcall;

{**
 * Creates an abstract stream. This function does nothing except allocating memory and initializing the abstract stream.
 *
 * @param	p_buffer_size  FIXME DOC
 * @param	p_is_input		if set to true then the stream will be an input stream, an output stream else.
 *
 * @return	a stream object.
*}
  LPFN_opj_stream_create = function( p_buffer_size :OPJ_SIZE_T;  p_is_input : OPJ_BOOL) : popj_stream_t stdcall;

{**
 * Destroys a stream created by opj_create_stream. This function does NOT close the abstract stream. If needed the user must
 * close its own implementation of the stream.
 *
 * @param	p_stream	the stream to destroy.
 *}
  LPFN_opj_stream_destroy = procedure(p_stream : popj_stream_t) stdcall;

{**
 * Sets the given function to be used as a read function.
 * @param		p_stream	the stream to modify
 * @param		p_function	the function to use a read function.
*}
  LPFN_opj_stream_set_read_function = procedure(p_stream : popj_stream_t; p_function : opj_stream_read_fn) stdcall;

{**
 * Sets the given function to be used as a write function.
 * @param		p_stream	the stream to modify
 * @param		p_function	the function to use a write function.
*}
  LPFN_opj_stream_set_write_function = procedure(p_stream : popj_stream_t;  p_function : opj_stream_write_fn) stdcall;

{**
 * Sets the given function to be used as a skip function.
 * @param		p_stream	the stream to modify
 * @param		p_function	the function to use a skip function.
*}
  LPFN_opj_stream_set_skip_function = procedure(p_stream : popj_stream_t;  p_function : opj_stream_skip_fn) stdcall;

{**
 * Sets the given function to be used as a seek function, the stream is then seekable.
 * @param		p_stream	the stream to modify
 * @param		p_function	the function to use a skip function.
*}
  LPFN_opj_stream_set_seek_function = procedure(p_stream : popj_stream_t;  p_function : opj_stream_seek_fn) stdcall;

{**
 * Sets the given data to be used as a user data for the stream.
 * @param		p_stream	the stream to modify
 * @param		p_data		the data to set.
 * @param		p_function	the function to free p_data when opj_stream_destroy() is called.
*}
  LPFN_opj_stream_set_user_data =procedure(p_stream : popj_stream_t; p_data : Pointer; p_function : opj_stream_free_user_data_fn) stdcall;

{**
 * Sets the length of the user data for the stream.
 *
 * @param p_stream    the stream to modify
 * @param data_length length of the user_data.
*}
  LPFN_opj_stream_set_user_data_length = procedure(p_stream : popj_stream_t;  data_length : OPJ_UINT64) stdcall;

{**
 * Create a stream from a file identified with its filename with default parameters (helper function)
 * @param fname             the filename of the file to stream
 * @param p_is_read_stream  whether the stream is a read stream (true) or not (false)
*}
 LPFN_opj_stream_create_default_file_stream = function(fname : PByte;  p_is_read_stream : OPJ_BOOL) : popj_stream_t stdcall;

{** Create a stream from a file identified with its filename with a specific buffer size
 * @param fname             the filename of the file to stream
 * @param p_buffer_size     size of the chunk used to stream
 * @param p_is_read_stream  whether the stream is a read stream (true) or not (false)
*}
  LPFN_opj_stream_create_file_stream = function(fname : PByte;
                                               p_buffer_size : OPJ_SIZE_T;
                                               p_is_read_stream : OPJ_BOOL) : popj_stream_t stdcall;

{*
==========================================================
   event manager functions definitions
==========================================================
*}
{**
 * Set the info handler use by openjpeg.
 * @param p_codec       the codec previously initialise
 * @param p_callback    the callback function which will be used
 * @param p_user_data   client object where will be returned the message
*}
  LPFN_opj_set_info_handler = function(p_codec : popj_codec_t;
                                       p_callback : opj_msg_callback;
                                       p_user_data : Pointer) : OPJ_BOOL stdcall;
{**
 * Set the warning handler use by openjpeg.
 * @param p_codec       the codec previously initialise
 * @param p_callback    the callback function which will be used
 * @param p_user_data   client object where will be returned the message
*}
  LPFN_opj_set_warning_handler = function( p_codec : popj_codec_t;
                          p_callback : opj_msg_callback;
                          p_user_data : Pointer) : OPJ_BOOL stdcall;
{**
 * Set the error handler use by openjpeg.
 * @param p_codec       the codec previously initialise
 * @param p_callback    the callback function which will be used
 * @param p_user_data   client object where will be returned the message
*}
  LPFN_opj_set_error_handler = function(p_codec : popj_codec_t;
                                       p_callback : opj_msg_callback;
                                       p_user_data : Pointer) : OPJ_BOOL stdcall;

{*
==========================================================
   codec functions definitions
==========================================================
*}

{**
 * Creates a J2K/JP2 decompression structure
 * @param format 		Decoder to select
 *
 * @return Returns a handle to a decompressor if successful, returns NULL otherwise
 * *}
  LPFN_opj_create_decompress = function( format : OPJ_CODEC_FORMAT) : popj_codec_t stdcall;

{**
 * Destroy a decompressor handle
 *
 * @param	p_codec			decompressor handle to destroy
 *}
  LPFN_opj_destroy_codec = procedure(p_codec : popj_codec_t) stdcall;

{**
 * Read after the codestream if necessary
 * @param	p_codec			the JPEG2000 codec to read.
 * @param	p_stream		the JPEG2000 stream.
 *}
  LPFN_opj_end_decompress = function(p_codec : popj_codec_t;
													 p_stream : popj_stream_t) : OPJ_BOOL stdcall;


{**
 * Set decoding parameters to default values
 * @param parameters Decompression parameters
 *}
  LPFN_opj_set_default_decoder_parameters = procedure(var parameters : opj_dparameters_t) stdcall;

{**
 * Setup the decoder with decompression parameters provided by the user and with the message handler
 * provided by the user.
 *
 * @param p_codec 		decompressor handler
 * @param parameters 	decompression parameters
 *
 * @return true			if the decoder is correctly set
 *}
  LPFN_opj_setup_decoder = function(p_codec : popj_codec_t;
												 parameters : popj_dparameters_t) : OPJ_BOOL stdcall;

{**
 * Decodes an image header.
 *
 * @param	p_stream		the jpeg2000 stream.
 * @param	p_codec			the jpeg2000 codec to read.
 * @param	p_image			the image structure initialized with the characteristics of encoded image.
 *
 * @return true				if the main header of the codestream and the JP2 header is correctly read.
 *}
  LPFN_opj_read_header =function(p_stream : popj_stream_t;
												p_codec :popj_codec_t;
												var p_image : popj_image_t) : OPJ_BOOL stdcall;

{**
 * Sets the given area to be decoded. This function should be called right after opj_read_header and before any tile header reading.
 *
 * @param	p_codec			the jpeg2000 codec.
 * @param	p_image         the decoded image previously setted by opj_read_header
 * @param	p_start_x		the left position of the rectangle to decode (in image coordinates).
 * @param	p_end_x			the right position of the rectangle to decode (in image coordinates).
 * @param	p_start_y		the up position of the rectangle to decode (in image coordinates).
 * @param	p_end_y			the bottom position of the rectangle to decode (in image coordinates).
 *
 * @return	true			if the area could be set.
 *}
  LPFN_opj_set_decode_area = function(p_codec : popj_codec_t;
				p_image : popj_image_t;
				p_start_x : OPJ_INT32;  p_start_y :OPJ_INT32;
				p_end_x : OPJ_INT32; p_end_y : OPJ_INT32 ) : OPJ_BOOL stdcall;

{**
 * Decode an image from a JPEG-2000 codestream
 *
 * @param p_decompressor 	decompressor handle
 * @param p_stream			Input buffer stream
 * @param p_image 			the decoded image
 * @return 					true if success, otherwise false
 * *}
  LPFN_opj_decode = function(p_decompressor : popj_codec_t;
                             p_stream : popj_stream_t;
                             p_image : popj_image_t) : OPJ_BOOL stdcall;

{**
 * Get the decoded tile from the codec
 *
 * @param	p_codec			the jpeg2000 codec.
 * @param	p_stream		input streamm
 * @param	p_image			output image
 * @param	tile_index		index of the tile which will be decode
 *
 * @return					true if success, otherwise false
 *}
  LPFN_opj_get_decoded_tile = function(p_codec :popj_codec_t;
													p_stream : popj_stream_t;
													p_image : popj_image_t;
													tile_index : OPJ_UINT32) : OPJ_BOOL stdcall;

{**
 * Set the resolution factor of the decoded image
 * @param	p_codec			the jpeg2000 codec.
 * @param	res_factor		resolution factor to set
 *
 * @return					true if success, otherwise false
 *}
  LPFN_opj_set_decoded_resolution_factor = function(p_codec : popj_codec_t; res_factor : OPJ_UINT32) : OPJ_BOOL stdcall;

{**
 * Writes a tile with the given data.
 *
 * @param	p_codec		        the jpeg2000 codec.
 * @param	p_tile_index		the index of the tile to write. At the moment, the tiles must be written from 0 to n-1 in sequence.
 * @param	p_data				pointer to the data to write. Data is arranged in sequence, data_comp0, then data_comp1, then ... NO INTERLEAVING should be set.
 * @param	p_data_size			this value os used to make sure the data being written is correct. The size must be equal to the sum for each component of
 *                              tile_width * tile_height * component_size. component_size can be 1,2 or 4 bytes, depending on the precision of the given component.
 * @param	p_stream			the stream to write data to.
 *
 * @return	true if the data could be written.
 *}
  LPFN_opj_write_tile = function(p_codec : popj_codec_t;
												 p_tile_index : OPJ_UINT32;
												 p_data : POPJ_BYTE;
												 p_data_size : OPJ_UINT32;
												 p_stream : popj_stream_t) : OPJ_BOOL stdcall;

{**
 * Reads a tile header. This function is compulsory and allows one to know the size of the tile thta will be decoded.
 * The user may need to refer to the image got by opj_read_header to understand the size being taken by the tile.
 *
 * @param	p_codec			the jpeg2000 codec.
 * @param	p_tile_index	pointer to a value that will hold the index of the tile being decoded, in case of success.
 * @param	p_data_size		pointer to a value that will hold the maximum size of the decoded data, in case of success. In case
 *							of truncated codestreams, the actual number of bytes decoded may be lower. The computation of the size is the same
 *							as depicted in opj_write_tile.
 * @param	p_tile_x0		pointer to a value that will hold the x0 pos of the tile (in the image).
 * @param	p_tile_y0		pointer to a value that will hold the y0 pos of the tile (in the image).
 * @param	p_tile_x1		pointer to a value that will hold the x1 pos of the tile (in the image).
 * @param	p_tile_y1		pointer to a value that will hold the y1 pos of the tile (in the image).
 * @param	p_nb_comps		pointer to a value that will hold the number of components in the tile.
 * @param	p_should_go_on	pointer to a boolean that will hold the fact that the decoding should go on. In case the
 *							codestream is over at the time of the call, the value will be set to false. The user should then stop
 *							the decoding.
 * @param	p_stream		the stream to decode.
 * @return	true			if the tile header could be decoded. In case the decoding should end, the returned value is still true.
 *							returning false may be the result of a shortage of memory or an internal error.
 *}
  LPFN_opj_read_tile_header = function(p_codec : popj_codec_t;
												p_stream : popj_stream_t;
												var p_tile_index : OPJ_UINT32;
												var p_data_size : OPJ_UINT32;
												var p_tile_x0 : OPJ_INT32;
                        var p_tile_y0 : OPJ_INT32;
												var p_tile_x1 : OPJ_INT32;
                        var p_tile_y1 : OPJ_INT32;
												var p_nb_comps : OPJ_UINT32;
												var p_should_go_on : OPJ_BOOL ) : OPJ_BOOL stdcall;

{**
 * Reads a tile data. This function is compulsory and allows one to decode tile data. opj_read_tile_header should be called before.
 * The user may need to refer to the image got by opj_read_header to understand the size being taken by the tile.
 *
 * @param	p_codec			the jpeg2000 codec.
 * @param	p_tile_index	the index of the tile being decoded, this should be the value set by opj_read_tile_header.
 * @param	p_data			pointer to a memory block that will hold the decoded data.
 * @param	p_data_size		size of p_data. p_data_size should be bigger or equal to the value set by opj_read_tile_header.
 * @param	p_stream		the stream to decode.
 *
 * @return	true			if the data could be decoded.
 *}
  LPFN_opj_decode_tile_data = function(p_codec : popj_codec_t;
			                  p_tile_index : OPJ_UINT32;
			 									p_data : POPJ_BYTE;
			 									p_data_size : OPJ_UINT32;
			 									p_stream : popj_stream_t ) : OPJ_BOOL stdcall;

//* COMPRESSION FUNCTIONS*/

{**
 * Creates a J2K/JP2 compression structure
 * @param 	format 		Coder to select
 * @return 				Returns a handle to a compressor if successful, returns NULL otherwise
 *}
  LPFN_opj_create_compress = function( format : OPJ_CODEC_FORMAT) : popj_codec_t stdcall;

{**
Set encoding parameters to default values, that means :
<ul>
<li>Lossless
<li>1 tile
<li>Size of precinct : 2^15 x 2^15 (means 1 precinct)
<li>Size of code-block : 64 x 64
<li>Number of resolutions: 6
<li>No SOP marker in the codestream
<li>No EPH marker in the codestream
<li>No sub-sampling in x or y direction
<li>No mode switch activated
<li>Progression order: LRCP
<li>No index file
<li>No ROI upshifted
<li>No offset of the origin of the image
<li>No offset of the origin of the tiles
<li>Reversible DWT 5-3
</ul>
@param parameters Compression parameters
*}
  LPFN_opj_set_default_encoder_parameters = procedure(parameters : popj_cparameters_t) stdcall;

{**
 * Setup the encoder parameters using the current image and using user parameters.
 * @param p_codec 		Compressor handle
 * @param parameters 	Compression parameters
 * @param image 		Input filled image
 *}
  LPFN_opj_setup_encoder = function(p_codec : opj_codec_t;
												 parameters : popj_cparameters_t;
												 image : popj_image_t) : OPJ_BOOL stdcall;

{**
 * Start to compress the current image.
 * @param p_codec 		Compressor handle
 * @param image 	    Input filled image
 * @param p_stream 		Input stgream
 *}
  LPFN_opj_start_compress =function (p_codec : popj_codec_t;
													 p_image : popj_image_t;
													 p_stream : popj_stream_t) : OPJ_BOOL stdcall;

{**
 * End to compress the current image.
 * @param p_codec 		Compressor handle
 * @param p_stream 		Input stgream
 *}
  LPFN_opj_end_compress = function(p_codec : popj_codec_t;
												  p_stream : popj_stream_t) : OPJ_BOOL stdcall;

{**
 * Encode an image into a JPEG-2000 codestream
 * @param p_codec 		compressor handle
 * @param p_stream 		Output buffer stream
 *
 * @return 				Returns true if successful, returns false otherwise
 *}
  LPFN_opj_encode = function(p_codec : popj_codec_t;
                             p_stream : popj_stream_t) : OPJ_BOOL stdcall;
{*
==========================================================
   codec output functions definitions
==========================================================
*}
//* EXPERIMENTAL FUNCTIONS FOR NOW, USED ONLY IN J2K_DUMP*/

{**
Destroy Codestream information after compression or decompression
@param cstr_info Codestream information structure
*}
  LPFN_opj_destroy_cstr_info = procedure(var cstr_info : popj_codestream_info_v2_t) stdcall;


{**
 * Dump the codec information into the output stream
 *
 * @param	p_codec			the jpeg2000 codec.
 * @param	info_flag		type of information dump.
 * @param	output_stream	output stream where dump the informations get from the codec.
 *
 *}
  LPFN_opj_dump_codec = procedure(	p_codec : opj_codec_t;
											info_flag : OPJ_INT32;
                      //Todo: figure out what to do about *FILE
											output_stream : Pointer) stdcall;

{**
 * Get the codestream information from the codec
 *
 * @param	p_codec			the jpeg2000 codec.
 *
 * @return					a pointer to a codestream information structure.
 *
 *}
  LPFN_opj_get_cstr_info = function(p_codec : popj_codec_t) : popj_codestream_info_v2_t stdcall;

{**
 * Get the codestream index from the codec
 *
 * @param	p_codec			the jpeg2000 codec.
 *
 * @return					a pointer to a codestream index structure.
 *
 *}
  LPFN_opj_get_cstr_index =function(p_codec : popj_codec_t) : popj_codestream_index_t stdcall;

  LPFN_opj_destroy_cstr_index = procedure(var p_cstr_index : popj_codestream_index_t) stdcall;


{**
 * Get the JP2 file information from the codec FIXME
 *
 * @param	p_codec			the jpeg2000 codec.
 *
 * @return					a pointer to a JP2 metadata structure.
 *
 *}
//  LPFN_opj_get_jp2_metadata = function(p_codec : popj_codec_t) : opj_jp2_metadata_t stdcall;

{**
 * Get the JP2 file index from the codec FIXME
 *
 * @param	p_codec			the jpeg2000 codec.
 *
 * @return					a pointer to a JP2 index structure.
 *
 *}
//  LPFN_opj_get_jp2_index = function(p_codec : popj_codec_t) : popj_jp2_index_t;


{*
==========================================================
   MCT functions
==========================================================
*}

{**
 * Sets the MCT matrix to use.
 *
 * @param	parameters		the parameters to change.
 * @param	pEncodingMatrix	the encoding matrix.
 * @param	p_dc_shift		the dc shift coefficients to use.
 * @param	pNbComp			the number of components of the image.
 *
 * @return	true if the parameters could be set.
 *}
  LPFN_opj_set_MCT = function(parameters : popj_cparameters_t;
		                          pEncodingMatrix : POPJ_FLOAT32;
                              p_dc_shift : POPJ_INT32;
		                          pNbComp : OPJ_UINT32) : OPJ_BOOL stdcall;


var
  opj_version : LPFN_opj_version = nil;
  opj_image_create : LPFN_opj_image_create = nil;
  opj_image_destroy : LPFN_opj_image_destroy = nil;
  opj_image_tile_create : LPFN_opj_image_tile_create = nil;
  opj_stream_default_create : LPFN_opj_stream_default_create = nil;
  opj_stream_create : LPFN_opj_stream_create = nil;
  opj_stream_destroy : LPFN_opj_stream_destroy = nil;
  opj_stream_set_read_function : LPFN_opj_stream_set_read_function = nil;
  opj_stream_set_write_function : LPFN_opj_stream_set_write_function = nil;
  opj_stream_set_skip_function : LPFN_opj_stream_set_skip_function = nil;
  opj_stream_set_seek_function : LPFN_opj_stream_set_seek_function = nil;
  opj_stream_set_user_data : LPFN_opj_stream_set_user_data = nil;
  opj_stream_set_user_data_length : LPFN_opj_stream_set_user_data_length = nil;
  opj_stream_create_default_file_stream : LPFN_opj_stream_create_default_file_stream = nil;
  opj_stream_create_file_stream : LPFN_opj_stream_create_file_stream = nil;
  opj_set_info_handler : LPFN_opj_set_info_handler = nil;
  opj_set_warning_handler : LPFN_opj_set_warning_handler = nil;
  opj_set_error_handler : LPFN_opj_set_error_handler = nil;
  opj_create_decompress : LPFN_opj_create_decompress = nil;
  opj_destroy_codec : LPFN_opj_destroy_codec = nil;
  opj_end_decompress : LPFN_opj_end_decompress = nil;
  opj_set_default_decoder_parameters : LPFN_opj_set_default_decoder_parameters = nil;
  opj_setup_decoder : LPFN_opj_setup_decoder = nil;
  opj_read_header : LPFN_opj_read_header = nil;
  opj_set_decode_area : LPFN_opj_set_decode_area = nil;
  opj_decode : LPFN_opj_decode = nil;
  opj_get_decoded_tile : LPFN_opj_get_decoded_tile = nil;
  opj_set_decoded_resolution_factor : LPFN_opj_set_decoded_resolution_factor = nil;
  opj_write_tile : LPFN_opj_write_tile = nil;
  opj_read_tile_header : LPFN_opj_read_tile_header  = nil;
  opj_decode_tile_data : LPFN_opj_decode_tile_data = nil;
  opj_create_compress : LPFN_opj_create_compress = nil;
  opj_set_default_encoder_parameters : LPFN_opj_set_default_encoder_parameters =nil;
  opj_setup_encoder : LPFN_opj_setup_encoder = nil;
  opj_start_compress : LPFN_opj_start_compress = nil;
  opj_end_compress : LPFN_opj_end_compress =nil;
  opj_encode : LPFN_opj_encode = nil;
  opj_destroy_cstr_info : LPFN_opj_destroy_cstr_info = nil;
  opj_dump_codec : LPFN_opj_dump_codec = nil;
  opj_get_cstr_info : LPFN_opj_get_cstr_info = nil;
  opj_get_cstr_index : LPFN_opj_get_cstr_index = nil;
  opj_destroy_cstr_index : LPFN_opj_destroy_cstr_index = nil;
//  opj_get_jp2_metadata : LPFN_opj_get_jp2_metadata =nil;
 // opj_get_jp2_index : LPFN_opj_get_jp2_index = nil;
  opj_set_MCT : LPFN_opj_set_MCT = nil;

function Load : Boolean;
function Loaded : Boolean;

type
  EOpenJPegStubError = class(Exception)
  protected
    FError : UInt32;
    FErrorMessage : String;
    FTitle : String;
  public
    constructor Build(const ATitle : String; AError : UInt32);
    property Error : UInt32 read FError;
    property ErrorMessage : String read FErrorMessage;
    property Title : String read FTitle;
  end;


implementation

function OPJ_IS_CINEMA(v : Integer)  : Boolean;
begin
  Result := (((v) >= OPJ_PROFILE_CINEMA_2K) and
             ((v) <= OPJ_PROFILE_CINEMA_S4K));
end;

function OPJ_IS_STORAGE(v : Integer) : Boolean;
begin
  Result := ((v) = OPJ_PROFILE_CINEMA_LTS);
end;

function OPJ_IS_BROADCAST(v : Integer)  : Boolean;
begin
  Result := (((v) >= OPJ_PROFILE_BC_SINGLE) and ((v) <= ((OPJ_PROFILE_BC_MULTI_R) or ($000b))));
end;

function OPJ_IS_IMF(v : Integer) : Boolean;
begin
  Result := (((v) >= OPJ_PROFILE_IMF_2K) and ((v) <= ((OPJ_PROFILE_IMF_8K_R) or ($009b))));
end;

function OPJ_IS_PART2(v : Integer) : Integer;
begin
  Result := ((v) and OPJ_PROFILE_PART2);
end;

{support functions for dynamic loading}

const
{$IFDEF MSVC_DECORATION}
  fn_opj_version = '_opj_version@0';
  fn_opj_image_create = '_opj_image_create@12';
  fn_opj_image_destroy = '_opj_image_destroy@4';
  fn_opj_image_tile_create = '_opj_image_tile_create@12';
  fn_opj_stream_default_create = '_opj_stream_default_create@4';
  fn_opj_stream_create = '_opj_stream_create@8';
  fn_opj_stream_destroy =  '_opj_stream_destroy@4';
  fn_opj_stream_set_read_function = '_opj_stream_set_read_function@8';
  fn_opj_stream_set_write_function = '_opj_stream_set_write_function@8';
  fn_opj_stream_set_skip_function = '_opj_stream_set_skip_function@8';

  fn_opj_stream_set_seek_function = '_opj_stream_set_seek_function@8';
  fn_opj_stream_set_user_data = '_opj_stream_set_user_data@12';
  fn_opj_stream_set_user_data_length = '_opj_stream_set_user_data_length@12';
  fn_opj_stream_create_default_file_stream = '_opj_stream_create_default_file_stream@8';
  fn_opj_stream_create_file_stream = '_opj_stream_create_file_stream@12';
  fn_opj_set_info_handler = '_opj_set_info_handler@12';
  fn_opj_set_warning_handler = '_opj_set_warning_handler@12';
  fn_opj_set_error_handler = '_opj_set_error_handler@12';
  fn_opj_create_decompress = '_opj_create_decompress@4';
  fn_opj_destroy_codec = '_opj_destroy_codec@4';

  fn_opj_end_decompress = '_opj_end_decompress@8';
  fn_opj_set_default_decoder_parameters = '_opj_set_default_decoder_parameters@4';
  fn_opj_setup_decoder = '_opj_setup_decoder@8';
  fn_opj_read_header = '_opj_read_header@12';
  fn_opj_set_decode_area = '_opj_set_decode_area@24';
  fn_opj_decode = '_opj_decode@12';
  fn_opj_get_decoded_tile = '_opj_get_decoded_tile@16';
  fn_opj_set_decoded_resolution_factor = '_opj_set_decoded_resolution_factor@8';
  fn_opj_write_tile = '_opj_write_tile@2';
  fn_opj_read_tile_header = '_opj_read_tile_header@40';

  fn_opj_decode_tile_data = '_opj_decode_tile_data@20';
  fn_opj_create_compress = '_opj_create_compress@4';
  fn_opj_set_default_encoder_parameters = '_opj_set_default_encoder_parameters@4';
  fn_opj_setup_encoder = '_opj_setup_encoder@12';
  fn_opj_start_compress = '_opj_start_compress@12';
  fn_opj_end_compress = '_opj_end_compress@8';
  fn_opj_encode = '_opj_encode@8';
  fn_opj_destroy_cstr_info = '_opj_destroy_cstr_info@4';
  fn_opj_dump_codec = '_opj_dump_codec@12';
  fn_opj_get_cstr_info = '_opj_get_cstr_info@4';
  fn_opj_get_cstr_index = '_opj_get_cstr_index@4';

  fn_opj_destroy_cstr_index = '_opj_destroy_cstr_index@4';
 // fn_opj_get_jp2_metadata = 'opj_get_jp2_metadata';
 // fn_opj_get_jp2_index =  'opj_get_jp2_index';
  fn_opj_set_MCT = '_opj_set_MCT@16';

{$ELSE}
  fn_opj_version = 'opj_version';
  fn_opj_image_create = 'opj_image_create';
  fn_opj_image_destroy = 'opj_image_destroy';
  fn_opj_image_tile_create = 'opj_image_tile_create';
  fn_opj_stream_default_create = 'opj_stream_default_create';
  fn_opj_stream_create = 'opj_stream_create';
  fn_opj_stream_destroy =  'opj_stream_destroy';
  fn_opj_stream_set_read_function = 'opj_stream_set_read_function';
  fn_opj_stream_set_write_function = 'opj_stream_set_write_function';
  fn_opj_stream_set_skip_function = 'opj_stream_set_skip_function';

  fn_opj_stream_set_seek_function = 'opj_stream_set_seek_function';
  fn_opj_stream_set_user_data = 'opj_stream_set_user_data';
  fn_opj_stream_set_user_data_length = 'opj_stream_set_user_data_length';
  fn_opj_stream_create_default_file_stream = 'opj_stream_create_default_file_stream';
  fn_opj_stream_create_file_stream = 'opj_stream_create_file_stream';
  fn_opj_set_info_handler = 'opj_set_info_handler';
  fn_opj_set_warning_handler = 'opj_set_warning_handler';
  fn_opj_set_error_handler = 'opj_set_error_handler';
  fn_opj_create_decompress = 'opj_create_decompress';
  fn_opj_destroy_codec = 'opj_destroy_codec';

  fn_opj_end_decompress = 'opj_end_decompress';
  fn_opj_set_default_decoder_parameters = 'opj_set_default_decoder_parameters';
  fn_opj_setup_decoder = 'opj_setup_decoder';
  fn_opj_read_header = 'opj_read_header';
  fn_opj_set_decode_area = 'opj_set_decode_area';
  fn_opj_decode = 'opj_decode';
  fn_opj_get_decoded_tile = 'opj_get_decoded_tile';
  fn_opj_set_decoded_resolution_factor = 'opj_set_decoded_resolution_factor';
  fn_opj_write_tile = 'opj_write_tile';
  fn_opj_read_tile_header = 'opj_read_tile_header';

  fn_opj_decode_tile_data = 'opj_decode_tile_data';
  fn_opj_create_compress = 'opj_create_compress';
  fn_opj_set_default_encoder_parameters = 'opj_set_default_encoder_parameters';
  fn_opj_setup_encoder = 'opj_setup_encoder';
  fn_opj_start_compress = 'opj_start_compress';
  fn_opj_end_compress = 'opj_end_compress';
  fn_opj_encode = 'opj_encode';
  fn_opj_destroy_cstr_info = 'opj_destroy_cstr_info';
  fn_opj_dump_codec = 'opj_dump_codec';
  fn_opj_get_cstr_info = 'opj_get_cstr_info';
  fn_opj_get_cstr_index = 'opj_get_cstr_index';

  fn_opj_destroy_cstr_index = 'opj_destroy_cstr_index';
 // fn_opj_get_jp2_metadata = 'opj_get_jp2_metadata';
 // fn_opj_get_jp2_index =  'opj_get_jp2_index';
  fn_opj_set_MCT = 'opj_set_MCT';

{$ENDIF}
{$IFDEF MSWINDOWS}
  libopenjpeg = 'openjp2.dll';
{$ENDIF}
{$IFDEF UNIX}
  //The extensions will be resolved by IdGlobal.HackLoad
  //This is a little messy because symbolic links to libraries may not always be the same
  //in various Unix types.  Even then, there could possibly be differences.
  libzlib = 'libopenjp2.so';
  libvers : array [0..3] of string = ('.6','.7','2.0.0','.2.1.0','');
 {$ENDIF}

var
  {$IFDEF UNIX}
  hOpenJpeg: HModule = nilhandle;
  {$ELSE}
  hOpenJpeg: THandle = 0;
  {$ENDIF}
  GOpenJPegPath: String = '';

const
  RSOpenJPegCallError = 'Error on call to OpenJPeg library function %s';

constructor EOpenJPegStubError.Build(const ATitle : String; AError : UInt32);
begin
  FTitle := ATitle;
  FError := AError;
  if AError = 0 then begin
    inherited Create(ATitle);
  end else begin
    FErrorMessage := SysUtils.SysErrorMessage(AError);
    inherited Create(ATitle + ': ' + FErrorMessage);    {Do not Localize}
  end;
end;

function FixupStub(hDll: THandle; const AName: {$IFDEF WINCE}TIdUnicodeString{$ELSE}string{$ENDIF}): Pointer;
begin
  if hDll = 0 then begin
    raise EOpenJPegStubError.Build(Format(RSOpenJPegCallError, [AName]), 0);
  end;
  Result := GetProcAddress(hDll, {$IFDEF WINCE}PWideChar{$ELSE}PChar{$ENDIF}(AName));
  if Result = nil then begin
    raise EOpenJPegStubError.Build(Format(RSOpenJPegCallError, [AName]), 10022);
  end;
end;


function stub_opj_version : PAnsiChar stdcall;
begin
  opj_version := FixupStub(hOpenJpeg, fn_opj_version); {Do not Localize}
  Result := opj_version;
end;

function stub_opj_image_create ( numcmpts : OPJ_UINT32; cmptparms : opj_image_cmptparm_t; clrspc : OPJ_COLOR_SPACE) : popj_image_t stdcall;
begin
  opj_image_create := FixupStub(hOpenJpeg, fn_opj_image_create); {Do not Localize}
  Result := opj_image_create(numcmpts,cmptparms,clrspc);
end;

procedure stub_opj_image_destroy (image : popj_image_t) stdcall;
begin
  opj_image_destroy := FixupStub(hOpenJpeg, fn_opj_image_destroy); {Do not Localize}
  opj_image_destroy(image);
end;

function stub_opj_image_tile_create( numcmpts : OPJ_UINT32; cmptparms : popj_image_cmptparm_t;  clrspc : OPJ_COLOR_SPACE) : popj_image_t stdcall;
begin
  opj_image_tile_create := FixupStub(hOpenJpeg, fn_opj_image_tile_create); {Do not Localize}
  Result := opj_image_tile_create(numcmpts,cmptparms,clrspc);
end;

function stub_opj_stream_default_create( p_is_input : OPJ_BOOL) : popj_stream_t stdcall;
begin
  opj_stream_default_create := FixupStub(hOpenJpeg, fn_opj_stream_default_create);
  Result := opj_stream_default_create(p_is_input);
end;

function stub_opj_stream_create( p_buffer_size :OPJ_SIZE_T;  p_is_input : OPJ_BOOL) : popj_stream_t stdcall;
begin
  opj_stream_create := FixupStub(hOpenJpeg, fn_opj_stream_create);
  Result := opj_stream_create(p_buffer_size,p_is_input);
end;

procedure stub_opj_stream_destroy(p_stream : popj_stream_t) stdcall;
begin
  opj_stream_destroy := FixupStub(hOpenJpeg, fn_opj_stream_destroy);
  opj_stream_destroy(p_stream);
end;

procedure stub_opj_stream_set_read_function(p_stream : popj_stream_t; p_function : opj_stream_read_fn) stdcall;
begin
  opj_stream_set_read_function := FixupStub(hOpenJpeg, fn_opj_stream_set_read_function);
  opj_stream_set_read_function(p_stream,p_function);
end;

procedure stub_opj_stream_set_write_function(p_stream : popj_stream_t;  p_function : opj_stream_write_fn) stdcall;
begin
  opj_stream_set_write_function := FixupStub(hOpenJpeg, fn_opj_stream_set_write_function);
  opj_stream_set_write_function(p_stream,p_function);
end;

procedure stub_opj_stream_set_skip_function(p_stream : popj_stream_t;  p_function : opj_stream_skip_fn) stdcall;
begin
  opj_stream_set_skip_function := FixupStub(hOpenJpeg, fn_opj_stream_set_skip_function);
  opj_stream_set_skip_function(p_stream,p_function);
end;

procedure stub_opj_stream_set_seek_function(p_stream : popj_stream_t;  p_function : opj_stream_seek_fn) stdcall;
begin
  opj_stream_set_seek_function := FixupStub(hOpenJpeg, fn_opj_stream_set_seek_function);
  opj_stream_set_seek_function(p_stream,p_function);
end;

procedure stub_opj_stream_set_user_data(p_stream : popj_stream_t; p_data : Pointer; p_function : opj_stream_free_user_data_fn) stdcall;
begin
  opj_stream_set_user_data := FixupStub(hOpenJpeg, fn_opj_stream_set_user_data);
  opj_stream_set_user_data(p_stream,p_data,p_function);
end;

procedure stub_opj_stream_set_user_data_length(p_stream : popj_stream_t;  data_length : OPJ_UINT64) stdcall;
begin
  opj_stream_set_user_data_length := FixupStub(hOpenJpeg, fn_opj_stream_set_user_data_length);
  opj_stream_set_user_data_length(p_stream,data_length);
end;

function stub_opj_stream_create_default_file_stream(fname : PByte;  p_is_read_stream : OPJ_BOOL) : popj_stream_t stdcall;
begin
  opj_stream_create_default_file_stream := FixupStub(hOpenJpeg, fn_opj_stream_create_default_file_stream);
  Result := opj_stream_create_default_file_stream(fname,p_is_read_stream);
end;

function stub_opj_stream_create_file_stream(fname : PByte;
                                               p_buffer_size : OPJ_SIZE_T;
                                               p_is_read_stream : OPJ_BOOL) : popj_stream_t stdcall;
begin
  opj_stream_create_file_stream := FixupStub(hOpenJpeg, fn_opj_stream_create_file_stream);
  Result := opj_stream_create_file_stream(fname,p_buffer_size,p_is_read_stream);
end;

function stub_opj_set_info_handler(p_codec : popj_codec_t;
                                       p_callback : opj_msg_callback;
                                       p_user_data : Pointer) : OPJ_BOOL stdcall;
begin
  opj_set_info_handler := FixupStub(hOpenJpeg, fn_opj_set_info_handler);
  Result := opj_set_info_handler(p_codec,p_callback,p_user_data);
end;

function stub_opj_set_warning_handler( p_codec : popj_codec_t;
                          p_callback : opj_msg_callback;
                          p_user_data : Pointer) : OPJ_BOOL stdcall;
begin
  opj_set_warning_handler := FixupStub(hOpenJpeg, fn_opj_set_warning_handler);
  Result := opj_set_warning_handler(p_codec,p_callback,p_user_data);
end;

function stub_opj_set_error_handler(p_codec : popj_codec_t;
                                       p_callback : opj_msg_callback;
                                       p_user_data : Pointer) : OPJ_BOOL stdcall;
begin
  opj_set_error_handler := FixupStub(hOpenJpeg, fn_opj_set_error_handler);
  Result := opj_set_error_handler(p_codec,p_callback,p_user_data);
end;

function stub_opj_create_decompress( format : OPJ_CODEC_FORMAT) : popj_codec_t stdcall;
begin
  opj_create_decompress := FixupStub(hOpenJpeg, fn_opj_create_decompress);
  Result := opj_create_decompress(format);
end;

procedure stub_opj_destroy_codec(p_codec : popj_codec_t) stdcall;
begin
  opj_destroy_codec := FixupStub(hOpenJpeg, fn_opj_destroy_codec);
  opj_destroy_codec(p_codec);
end;

function stub_opj_end_decompress(p_codec : popj_codec_t;
													 p_stream : popj_stream_t) : OPJ_BOOL stdcall;
begin
  opj_end_decompress := FixupStub(hOpenJpeg, fn_opj_end_decompress);
  Result := opj_end_decompress(p_codec,p_stream);
end;

procedure stub_opj_set_default_decoder_parameters(var parameters : opj_dparameters_t) stdcall;
begin
  opj_set_default_decoder_parameters := FixupStub(hOpenJpeg, fn_opj_set_default_decoder_parameters);
  opj_set_default_decoder_parameters(parameters);
end;

function stub_opj_setup_decoder(p_codec : popj_codec_t;
												 parameters : popj_dparameters_t) : OPJ_BOOL stdcall;
begin
  opj_setup_decoder := FixupStub(hOpenJpeg, fn_opj_setup_decoder);
  Result := opj_setup_decoder(p_codec,parameters);
end;

function stub_opj_read_header(p_stream : popj_stream_t;
												p_codec :popj_codec_t;
												var p_image : popj_image_t) : OPJ_BOOL stdcall;
begin
  opj_read_header := FixupStub(hOpenJpeg, fn_opj_read_header);
  Result := opj_read_header(p_stream,p_codec,p_image);
end;

function stub_opj_set_decode_area(p_codec : popj_codec_t;
				p_image : popj_image_t;
				p_start_x : OPJ_INT32;  p_start_y :OPJ_INT32;
				p_end_x : OPJ_INT32; p_end_y : OPJ_INT32 ) : OPJ_BOOL stdcall;
begin
  opj_set_decode_area := FixupStub(hOpenJpeg, fn_opj_set_decode_area);
  Result := opj_set_decode_area(p_codec,p_image,p_start_x, p_start_y,	p_end_x, p_end_y);
end;

function stub_opj_decode(p_decompressor : popj_codec_t;
                             p_stream : popj_stream_t;
                             p_image : popj_image_t) : OPJ_BOOL stdcall;
begin
  opj_decode := FixupStub(hOpenJpeg, fn_opj_decode);
  Result := opj_decode(p_decompressor,p_stream,p_image);
end;

function stub_opj_get_decoded_tile(p_codec :popj_codec_t;
													p_stream : popj_stream_t;
													p_image : popj_image_t;
													tile_index : OPJ_UINT32) : OPJ_BOOL stdcall;
begin
  opj_get_decoded_tile := FixupStub(hOpenJpeg, fn_opj_get_decoded_tile);
  Result := opj_get_decoded_tile(p_codec,p_stream,p_image,tile_index);
end;

function stub_opj_set_decoded_resolution_factor(p_codec : popj_codec_t; res_factor : OPJ_UINT32) : OPJ_BOOL stdcall;
begin
  opj_set_decoded_resolution_factor := FixupStub(hOpenJpeg, fn_opj_set_decoded_resolution_factor);
  Result := opj_set_decoded_resolution_factor(p_codec,res_factor);
end;

function stub_opj_write_tile(p_codec : popj_codec_t;
												 p_tile_index : OPJ_UINT32;
												 p_data : POPJ_BYTE;
												 p_data_size : OPJ_UINT32;
												 p_stream : popj_stream_t) : OPJ_BOOL stdcall;
begin
  opj_write_tile := FixupStub(hOpenJpeg, fn_opj_write_tile);
  Result := opj_write_tile(p_codec, p_tile_index, p_data, p_data_size,p_stream);
end;

function stub_opj_read_tile_header(p_codec : popj_codec_t;
												p_stream : popj_stream_t;
												var p_tile_index : OPJ_UINT32;
												var p_data_size : OPJ_UINT32;
												var p_tile_x0 : OPJ_INT32;
                        var p_tile_y0 : OPJ_INT32;
												var p_tile_x1 : OPJ_INT32;
                        var p_tile_y1 : OPJ_INT32;
												var p_nb_comps : OPJ_UINT32;
												var p_should_go_on : OPJ_BOOL ) : OPJ_BOOL stdcall;

{function stub_opj_read_tile_header(p_codec : popj_codec_t;
												p_stream : opj_stream_t;
												p_tile_index : OPJ_UINT32;
												p_data_size : OPJ_UINT32;
												p_tile_x0 : OPJ_INT32;
                        p_tile_y0 : OPJ_INT32;
												p_tile_x1 : OPJ_INT32;
                        p_tile_y1 : OPJ_INT32;
												p_nb_comps : OPJ_UINT32;
												p_should_go_on : OPJ_BOOL ) : OPJ_BOOL stdcall;
}
begin
  opj_read_tile_header := FixupStub(hOpenJpeg, fn_opj_read_tile_header);
  Result := opj_read_tile_header(p_codec,p_stream,p_tile_index,p_data_size,
    p_tile_x0, p_tile_y0,p_tile_x1, p_tile_y1,p_nb_comps,p_should_go_on );
end;

function stub_opj_decode_tile_data(p_codec : popj_codec_t;
			                  p_tile_index : OPJ_UINT32;
			 									p_data : POPJ_BYTE;
			 									p_data_size : OPJ_UINT32;
			 									p_stream : popj_stream_t ) : OPJ_BOOL stdcall;
begin
  opj_decode_tile_data := FixupStub(hOpenJpeg, fn_opj_decode_tile_data);
  Result := opj_decode_tile_data(p_codec,p_tile_index,p_data,p_data_size,p_stream);
end;

function stub_opj_create_compress( format : OPJ_CODEC_FORMAT) : popj_codec_t stdcall;
begin
  opj_create_compress := FixupStub(hOpenJpeg, fn_opj_create_compress);
  Result := opj_create_compress(format);
end;

procedure stub_opj_set_default_encoder_parameters(parameters : popj_cparameters_t) stdcall;
begin
  opj_set_default_encoder_parameters := FixupStub(hOpenJpeg, fn_opj_set_default_encoder_parameters);
  opj_set_default_encoder_parameters(parameters);
end;

function stub_opj_setup_encoder(p_codec : opj_codec_t;
												 parameters : popj_cparameters_t;
												 image : popj_image_t) : OPJ_BOOL stdcall;
begin
  opj_setup_encoder := FixupStub(hOpenJpeg, fn_opj_setup_encoder);
  Result := opj_setup_encoder(p_codec,parameters,image);
end;

function stub_opj_start_compress(p_codec : popj_codec_t;
													 p_image : popj_image_t;
													 p_stream : popj_stream_t) : OPJ_BOOL stdcall;
begin
  opj_start_compress := FixupStub(hOpenJpeg, fn_opj_start_compress);
  Result := opj_start_compress(p_codec,p_image,p_stream);
end;

function stub_opj_end_compress(p_codec : popj_codec_t;
												  p_stream : popj_stream_t) : OPJ_BOOL stdcall;
begin
  opj_end_compress := FixupStub(hOpenJpeg, fn_opj_end_compress);
  Result := opj_end_compress(p_codec,p_stream);
end;

function stub_opj_encode(p_codec : popj_codec_t;
                             p_stream : popj_stream_t) : OPJ_BOOL stdcall;
begin
  opj_encode := FixupStub(hOpenJpeg, fn_opj_encode);
  Result := opj_encode(p_codec,p_stream);
end;

procedure stub_opj_destroy_cstr_info(var cstr_info : popj_codestream_info_v2_t) stdcall;
begin
  opj_destroy_cstr_info  := FixupStub(hOpenJpeg, fn_opj_destroy_cstr_info);
  opj_destroy_cstr_info(cstr_info);
end;

procedure stub_opj_dump_codec(	p_codec : opj_codec_t;
											info_flag : OPJ_INT32;
                      //Todo: figure out what to do about *FILE
											output_stream : Pointer) stdcall;
begin
  opj_dump_codec := FixupStub(hOpenJpeg, fn_opj_dump_codec);
  opj_dump_codec(p_codec,info_flag,output_stream);
end;

function stub_opj_get_cstr_info(p_codec : popj_codec_t) : popj_codestream_info_v2_t stdcall;
begin
  opj_get_cstr_info := FixupStub(hOpenJpeg, fn_opj_get_cstr_info);
  Result := opj_get_cstr_info(p_codec);
end;

function stub_opj_get_cstr_index(p_codec : popj_codec_t) : popj_codestream_index_t stdcall;
begin
  opj_get_cstr_index := FixupStub(hOpenJpeg, fn_opj_get_cstr_index);
  Result := opj_get_cstr_index(p_codec);
end;

procedure stub_opj_destroy_cstr_index(var p_cstr_index : popj_codestream_index_t) stdcall;
begin
  opj_destroy_cstr_index := FixupStub(hOpenJpeg, fn_opj_destroy_cstr_index);
  opj_destroy_cstr_index(p_cstr_index);
end;

function stub_opj_set_MCT(parameters : popj_cparameters_t;
		                          pEncodingMatrix : POPJ_FLOAT32;
                              p_dc_shift : POPJ_INT32;
		                          pNbComp : OPJ_UINT32) : OPJ_BOOL stdcall;
begin
  opj_set_MCT  := FixupStub(hOpenJpeg, fn_opj_set_MCT);
  Result := opj_set_MCT(parameters,pEncodingMatrix,p_dc_shift,pNbComp);
end;

function Load : Boolean;
begin
  Result := Loaded;
  if not Result then begin
    //In Windows, you should use SafeLoadLibrary instead of the LoadLibrary API
    //call because LoadLibrary messes with the FPU control word.
    {$IFDEF WINDOWS}
    hOpenJpeg := SafeLoadLibrary(GOpenJPegPath + libopenjpeg);
    {$ELSE}
      {$IFDEF UNIX}
    hOpenJpeg := HackLoad(GOpenJPegPath + libzlib, libvers);
      {$ELSE}
    hOpenJpeg := LoadLibrary(GOpenJPegPath + libopenjpeg);
        {$IFDEF USE_INVALIDATE_MOD_CACHE}
    InvalidateModuleCache;
        {$ENDIF}
      {$ENDIF}
    {$ENDIF}
    Result := Loaded;
  end;
end;

function Loaded : Boolean;
begin
  Result := (hOpenJpeg <> 0);
end;


procedure InitializeStubs;
begin
  opj_version := stub_opj_version;
  opj_image_create := stub_opj_image_create;
  opj_image_destroy := stub_opj_image_destroy;
  opj_image_tile_create := stub_opj_image_tile_create;
  opj_stream_default_create := stub_opj_stream_default_create;
  opj_stream_create := stub_opj_stream_create;
  opj_stream_destroy := stub_opj_stream_destroy;
  opj_stream_set_read_function := stub_opj_stream_set_read_function;
  opj_stream_set_write_function := stub_opj_stream_set_write_function;
  opj_stream_set_skip_function := stub_opj_stream_set_skip_function;

  opj_stream_set_seek_function := stub_opj_stream_set_seek_function;
  opj_stream_set_user_data := stub_opj_stream_set_user_data;
  opj_stream_set_user_data_length := stub_opj_stream_set_user_data_length;
  opj_stream_create_default_file_stream := stub_opj_stream_create_default_file_stream;
  opj_stream_create_file_stream := stub_opj_stream_create_file_stream;
  opj_set_info_handler := stub_opj_set_info_handler;
  opj_set_warning_handler := stub_opj_set_warning_handler;
  opj_set_error_handler := stub_opj_set_error_handler;
  opj_create_decompress := stub_opj_create_decompress;
  opj_destroy_codec := stub_opj_destroy_codec;

  opj_end_decompress := stub_opj_end_decompress;
  opj_set_default_decoder_parameters := stub_opj_set_default_decoder_parameters;
  opj_setup_decoder := stub_opj_setup_decoder;
  opj_read_header := stub_opj_read_header;
  opj_set_decode_area := stub_opj_set_decode_area;
  opj_decode := stub_opj_decode;
  opj_get_decoded_tile := stub_opj_get_decoded_tile;
  opj_set_decoded_resolution_factor := stub_opj_set_decoded_resolution_factor;
  opj_write_tile := stub_opj_write_tile;
  opj_read_tile_header := stub_opj_read_tile_header;

  opj_decode_tile_data := stub_opj_decode_tile_data;
  opj_create_compress := stub_opj_create_compress;
  opj_set_default_encoder_parameters := stub_opj_set_default_encoder_parameters;
  opj_setup_encoder := stub_opj_setup_encoder;
  opj_start_compress := stub_opj_start_compress;
  opj_end_compress := stub_opj_end_compress;
  opj_encode := stub_opj_encode;
  opj_destroy_cstr_info := stub_opj_destroy_cstr_info;
  opj_dump_codec := stub_opj_dump_codec;
  opj_get_cstr_info := stub_opj_get_cstr_info;

  opj_get_cstr_index := stub_opj_get_cstr_index;
  opj_destroy_cstr_index := stub_opj_destroy_cstr_index;
 // opj_get_jp2_metadata := stub_opj_get_jp2_metadata;
 // opj_get_jp2_index =  'opj_get_jp2_index;
  opj_set_MCT := stub_opj_set_MCT;
end;

procedure Unload;
begin
  if Loaded then begin
    FreeLibrary(hOpenJpeg);
    {$IFDEF DELPHI_CROSS}
    InvalidateModuleCache;
    {$ENDIF}
    hOpenJpeg := 0;
    InitializeStubs;
  end;
end;

 initialization
  InitializeStubs;
  Load;
finalization
  Unload;
  InitializeStubs;
end.
