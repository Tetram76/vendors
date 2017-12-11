
 /* WizZip.h
 * This version is for VC++
 * Chris Vleghert & Eric W. Engler
 */

#ifndef _WIZZIP_H
  #define _WIZZIP_H

  #ifndef NDEBUG
    #define WinAssert( exp )                                                \
  {                                                                         \
    if ( !(exp) )                                                           \
    {                                                                       \
      char  szBuffer[40];                                                   \
      sprintf( szBuffer, "File %s, Line %d", __FILE__, __LINE__ );          \
      if ( IDABORT == MessageBox( (HWND) NULL, szBuffer, "Assertion Error", \
                                  MB_ABORTRETRYIGNORE | MB_ICONSTOP ) )     \
        FatalExit( -1 );                                                    \
    }                                                                       \
  }

  #else
    #define WinAssert( exp )
  #endif

/* Define the data passed back to the C++Builder/Delphi callback function */
// changed definition for 1.73 _ actioncode 14 - SetExtraData
// 1.73.2.6 callback return value for exception
  #define Callback_Except_No  10106

/* And make sure the data is byte aligned even if the make file use an other option */
  #pragma pack( 1 )
typedef struct
{
  HWND  handle;
  void  *caller;
  long  version;
  BOOL  isoperationzip;                   /* true=zip, false=unzip(not for this DLL) */
  long  actioncode;
  long  error_code;
  long  fsize;
  union
  {
    char  filenameormsg[512];             /* NOTE: NOT a pointer - data is here */
    struct
    {
      char          filename[500];
      unsigned      guard;
//      unsigned char *Data;
      unsigned long Data;
    };
  };
}

callbackstruct;
  #pragma pack()

//#pragma pack(4)
//typedef unsigned long (*DLLCALLBK) (callbackstruct *);
typedef ( CALLBACK *DLLCALLBK ) ( callbackstruct * );

  #pragma pack( 1 )
typedef struct
{
  HWND              fHandle;              /* handle of calling pgm's active Window                       */
  void              *fCaller;             /* object instance ("this/self") of calling form (not  */

  /* used in DLL; returned to BCB/Delphi via callback)   */
  long              fVersion;             /* version no. that BCB/Delphi Applic. expects                     */
  DLLCALLBK           fCallback;
  BOOL              fTraceEnabled;

  char              *fGenPassword;        /* password                                                                                        */
  char              *fSuffix;             /* Suffix string, files with these should be stored        */
  BOOL              fGenEncrypt;          /* should we, or shouldn't we?                                                     */

  BOOL              fSystem;              /* include system and hidden files                                         */
  BOOL              fVolume;              /* Include volume label                                                            */
  BOOL              fExtra;               /* Include extra attributes                                                        */
  BOOL              fNoDirEntries;        /* Do not add directory entries                                            */
  BOOL              fGenDateUsed;         /* Exclude files earlier than specified date                       */
  BOOL              fVerbose;             /* Mention oddities in zip file structure                          */
  BOOL              fQuiet;               /* Quiet operation                                                                         */

  int               fLevel;               /* Compression level (0 - 9)                                                       */
  BOOL              fComprSpecial;        /* try to compress files that are alreay compressed        */

  /* Only used with components < v1.6                                    */
  BOOL              fCRLF_LF;             /* Translate end-of-line                                                           */
  BOOL              fJunkDir;             /* Junk (remove) directory names                                           */
  unsigned short int  fRecurse;           /* Recurse into subdirectories                                          */

  // This next variable can be set to a to influence the way recursion works.
  // If the component send fRecurse as a 32 bit value (all official distributed
  // components do so) the following values in fNoRecurseFiles can occur:
  //   0xFFFF  Called by Delphi with fRecurse = true
  //   0x0001  Called by CB with fRecurse     = true
  //   0x0000  Called by CB or Delphi with fRecurse  = false.
  //   0x0002  means do NOT recurse into directories if the filespec is a file.
  unsigned short int  fNoRecurseFiles;

  BOOL              fGrow;                /* Allow appending to a zip file                                         */
  BOOL              fForce;               /* Make entries using DOS names (k for Katz)             */
  BOOL              fMove;                /* Delete files added or updated in zip file             */
  BOOL              fDeleteEntries;       /* Delete files from zip file                                            */
  BOOL              fUpdate;              /* Update zip file--overwrite only if newer              */
  BOOL              fFreshen;             /* Freshen zip file--overwrite only                              */
  BOOL              fJunkSFX;             /* Junk SFX prefix                                                                       */
  BOOL              fLatestTime;          /* Set zip file time to time of latest file in it        */

  char              fGenDate[8];          /* Date to include after (MMDDYY + 2 null)                       */
  long              fTotFileSpecs;        /* Count of filespecs to zip or delete                           */
  char              *fZipFN;              /* name of zip file                                                              */
  int   fSeven;                           /* stick a 7 in here to validate the struct offsets  */
  char  *FNV[];                           /* array of filespec strings                                             */
}

ZCL;
  #pragma pack()
  #pragma pack( 1 )
typedef struct
{
  char              *fFileSpec;
  char              *fFileComment;        // NEW z->comment and z->com
  char              *fFileAltName;        // NEW
  char              *fPassword;           // Overide v1.60L
  BOOL              fEncrypt;             // Overide v1.60L
  unsigned short int  fRecurse;           // Overide v1.60L
  //unsigned short int  fNoRecurseFile;     // Overide
  unsigned short int  fnotused1;
//BOOL              fDateUsed;            // Overide
  // use unsigned(-1) for 0 - nz overrides globals
  unsigned int      fFromDate;
//  char              fDate[8];             // Overide
  // use -1 for 0 - nz overrides globals
  int               fLevel;
  int               fnotused2;
  char              *fRootDir;            // NEW support for RootDir in v1.60L
  long              fNotUsed[16];         // NEW
}
 
FileData;
  #pragma pack()
  
  #pragma pack( 1 )
typedef struct
{
  char  *fFileSpec;
}

ExcludedFileSpec;

  #pragma pack( 1 )
typedef struct
{
  HWND              fHandle;
  void              *fCaller;
  long              fVersion;
  DLLCALLBK           fCallback;
  BOOL              fTraceEnabled;
  char              *fGenPassword;        // General password, if not superseded by FileData.fPassword
  char              *fSuffix;
  BOOL              fGenEncrypt;          // General encrypt, if not superseded by FileData.fEncrypt
  BOOL              fSystem;
  BOOL              fVolume;
  BOOL              fExtra;
  BOOL              fNoDirEntries;
  BOOL              fGenDateUsed;         // General DateUsed, if not superseded by FileData.fDateUsed
  BOOL              fVerbose;
  BOOL              fQuiet;
  int               fLevel;
  BOOL              fComprSpecial;
  BOOL              fCRLF_LF;
  BOOL              fJunkDir;
  unsigned short int  fRecurse;
  unsigned short int  fNoRecurseFile;
  BOOL              fGrow;
  BOOL              fForce;
  BOOL              fMove;
  BOOL              fDeleteEntries;
  BOOL              fUpdate;
  BOOL              fFreshen;
  BOOL              fJunkSFX;
  BOOL              fLatestTime;
  char              fGenDate[8];          // General Date, if not superseded by FileData.fDate
  long              fTotFileSpecs;        // Changed, Number of FileData structures.
  char              *fZipFN;

  // After this point the structure is different from the old "ZCL" structure.
  char              *fTempPath;           // b option
  char              *fArchComment;        // zcomment and zcomlen
  short int           fArchiveFilesOnly;  // when true only zip when archive bit set
  short int           fResetArchiveBit;   // when true reset the archive bit after a successfull zip
  FileData            *fFDS;
  BOOL              fForceWin;
  int               fTotExFileSpecs;      // Number of ExcludedFileSpec structures.
  ExcludedFileSpec  *fExFiles;            // Array of file specs to exclude from zipping.
  BOOL              fUseOutStream;        // component v160M, dll v1.6015 Use memory stream as output.
  void              *fOutStream;          // component v160M, dll v1.6015 Pointer to the start of the output stream data.
  unsigned long     fOutStreamSize;       // component v160M, dll v1.6015 Size of the Output data.
  BOOL              fUseInStream;         // component v160M, dll v1.6015 Use memory stream as input.
  void              *fInStream;           // component v160M, dll v1.6015 Pointer to the start of the input stream data.
  unsigned long     fInStreamSize;        // component v160M, dll v1.6015 Size of the input data.
  DWORD             fStrFileAttr;         // component v160M, dll v1.6015 File attributes to set for the streamed file.
  DWORD             fStrFileDate;         // component v160M, dll v1.6015 File date/time to set for the streamed file.
  BOOL              fHowToMove;           // component v160M
  unsigned short    fWantedCodePage;      // component v160N, dll v1.6017
  unsigned short    fWantedOS;            // v174
  long              fVCLVer;              // v174

  //  unsigned short fNotUsed0;
  const char        *RootDir;             // v1.76   global Root directory
  long              fNotUsed[2 /*4*/ ];
  int               fSeven;               // End of structure (eg. 7)
}
ZCL2;
  #pragma pack()

/* exports for the DLL */
//extern __stdcall __declspec( dllexport ) long GetZipDllVersion( void );
//extern __stdcall __declspec( dllexport ) long GetZipDllPrivVersion( void );
//extern __stdcall __declspec( dllexport ) long ZipDllExec( ZCL *C );
  #ifdef __cplusplus
extern "C"
{
  #endif
  extern BOOL WINAPI  DllEntryPoint( HINSTANCE hinstDll, DWORD fdwRreason,
                                     LPVOID plvReserved );
  extern long WINAPI  GetZipDllVersion( void );
  extern long WINAPI  GetZipDllPrivVersion( void );
  extern long WINAPI  ZipDllExec( ZCL *C );
  #ifdef __cplusplus
}

  #endif
#endif /* _WIZZIP_H */
