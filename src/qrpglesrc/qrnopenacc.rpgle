     /* begin_generated_IBM_copyright_prolog                              */
     /* This is an automatically generated copyright prolog.              */
     /* After initializing,  DO NOT MODIFY OR MOVE                        */
     /* ----------------------------------------------------------------- */
     /*                                                                   */
     /* Product(s):                                                       */
     /*     5733-OAR                                                      */
     /*                                                                   */
     /* (C)Copyright IBM Corp.  2010, 2010                                */
     /*                                                                   */
     /* All rights reserved.                                              */
     /* US Government Users Restricted Rights -                           */
     /* Use, duplication or disclosure restricted                         */
     /* by GSA ADP Schedule Contract with IBM Corp.                       */
     /*                                                                   */
     /* Licensed Materials-Property of IBM                                */
     /*                                                                   */
     /*  ---------------------------------------------------------------  */
     /*                                                                   */
     /* end_generated_IBM_copyright_prolog                                */
     /*** START HEADER FILE SPECIFICATIONS ***********************        */
     /*                                                                   */
     /*Header File Name: QRNOPENACC                                       */
     /*                                                                   */
     /*Descriptive Name: API error numbers.                               */
     /*                                                                   */
     /*Change Activity:                                                   */
     /*                                                                   */
     /*CFD List:                                                          */
     /*                                                                   */
     /*FLAG REASON       LEVEL DATE   PGMR      CHANGE DESCRIPTION        */
     /*---- ------------ ----- ------ --------- ----------------------    */
     /*$A0=                    090830 BLM       New Include               */
     /*$A1=                    100614 BLM       COMMIT and SLN keywords   */
     /*                                                                   */
     /*End CFD List.                                                      */
     /*                                                                   */
     /*Additional notes about the Change Activity                         */
     /*End Change Activity.                                               */
     /*** END HEADER FILE SPECIFICATIONS ******************************   */

      /IF DEFINED(QrnOpenAccess_Included)
      /EOF
      /ENDIF
      /DEFINE QrnOpenAccess_Included

     /* Format of QrnOpenAccess struct */
     D ROIO0100        C                   'ROIO0100'

     D QrnDevice_Database...
     D                 C                   'D'
     D QrnDevice_Printer...
     D                 C                   'P'
     D QrnDevice_UserInterface...
     D                 C                   'U'

     D QrnOperation_OPEN...
     D                 C                   1
     D QrnOperation_POSITION_START...
     D                 C                   2
     D QrnOperation_POSITION_END...
     D                 C                   3
     D QrnOperation_READ...
     D                 C                   4
     D QrnOperation_READC...
     D                 C                   5
     D QrnOperation_READE...
     D                 C                   6
     D QrnOperation_READP...
     D                 C                   7
     D QrnOperation_READPE...
     D                 C                   8
     D QrnOperation_CHAIN...
     D                 C                   9
     D QrnOperation_EXFMT...
     D                 C                   10
     D QrnOperation_SETGT...
     D                 C                   11
     D QrnOperation_SETLL...
     D                 C                   12
     D QrnOperation_UNLOCK...
     D                 C                   13
     D QrnOperation_UPDATE...
     D                 C                   14
     D QrnOperation_WRITE...
     D                 C                   15
     D QrnOperation_DELETE...
     D                 C                   16
     D QrnOperation_FEOD...
     D                 C                   17
     D QrnOperation_CLOSE...
     D                 C                   18
     D QrnOperation_DELETE_CURRENT...
     D                 C                   19
     D QrnOperation_READE_CURRENT...
     D                 C                   20
     D QrnOperation_READPE_CURRENT...
     D                 C                   21

     D QrnFunctionKey_None...
     D                 C                   0
     D QrnFunctionKey_01...
     D                 C                   1
     D QrnFunctionKey_02...
     D                 C                   2
     D QrnFunctionKey_03...
     D                 C                   3
     D QrnFunctionKey_04...
     D                 C                   4
     D QrnFunctionKey_05...
     D                 C                   5
     D QrnFunctionKey_06...
     D                 C                   6
     D QrnFunctionKey_07...
     D                 C                   7
     D QrnFunctionKey_08...
     D                 C                   8
     D QrnFunctionKey_09...
     D                 C                   9
     D QrnFunctionKey_10...
     D                 C                   10
     D QrnFunctionKey_11...
     D                 C                   11
     D QrnFunctionKey_12...
     D                 C                   12
     D QrnFunctionKey_13...
     D                 C                   13
     D QrnFunctionKey_14...
     D                 C                   14
     D QrnFunctionKey_15...
     D                 C                   15
     D QrnFunctionKey_16...
     D                 C                   16
     D QrnFunctionKey_17...
     D                 C                   17
     D QrnFunctionKey_18...
     D                 C                   18
     D QrnFunctionKey_19...
     D                 C                   19
     D QrnFunctionKey_20...
     D                 C                   20
     D QrnFunctionKey_21...
     D                 C                   21
     D QrnFunctionKey_22...
     D                 C                   22
     D QrnFunctionKey_23...
     D                 C                   23
     D QrnFunctionKey_24...
     D                 C                   24
     D QrnFunctionKey_PRINT...
     D                 C                   121
     D QrnFunctionKey_ROLLUP...
     D                 C                   122
     D QrnFunctionKey_ROLLDOWN...
     D                 C                   123
     D QrnFunctionKey_CLEAR...
     D                 C                   124
     D QrnFunctionKey_HELP...
     D                 C                   125
     D QrnFunctionKey_HOME...
     D                 C                   126

     D QrnDatatype_Alpha...
     D                 C                   1
     D QrnDatatype_AlphaVarying...
     D                 C                   2
     D QrnDatatype_Unicode...
     D                 C                   3
     D QrnDatatype_UnicodeVarying...
     D                 C                   4
     D QrnDatatype_Dbcs...
     D                 C                   5
     D QrnDatatype_DbcsVarying...
     D                 C                   6
     D QrnDatatype_Indicator...
     D                 C                   7
     D QrnDatatype_Decimal...
     D                 C                   8
     D QrnDatatype_Integer...
     D                 C                   9
     D QrnDatatype_Unsigned...
     D                 C                   10
     D QrnDatatype_Float...
     D                 C                   11
     D QrnDatatype_Date...
     D                 C                   12
     D QrnDatatype_Time...
     D                 C                   13
     D QrnDatatype_Timestamp...
     D                 C                   14

     D QrnDtzFormat_ISO...
     D                 C                   1
     D QrnDtzFormat_USA...
     D                 C                   2
     D QrnDtzFormat_EUR...
     D                 C                   3
     D QrnDtzFormat_JIS...
     D                 C                   4
     D QrnDtzFormat_YMD...
     D                 C                   5
     D QrnDtzFormat_MDY...
     D                 C                   6
     D QrnDtzFormat_DMY...
     D                 C                   7
     D QrnDtzFormat_JUL...
     D                 C                   8
     D QrnDtzFormat_HMS...
     D                 C                   9

     D QrnPrtctl_T...
     D                 DS                  QUALIFIED TEMPLATE
     D   spaceBefore                  3S 0
     D   spaceAfter                   3S 0
     D   skipBefore                   3S 0
     D   skipAfter                    3S 0
     D   currLine                     3S 0

     D QrnRecordLevel_T...
     D                 DS                  QUALIFIED TEMPLATE
     D   record                      10A
     D   level                       13A

     D QrnRecordLevels_T...
     D                 DS                  QUALIFIED TEMPLATE ALIGN
     D   num                         10I 0
     D   levels                            LIKEDS(QrnRecordLevel_T)
     D                                     DIM(32767)

     D QrnObject_T...
     D                 DS                  QUALIFIED TEMPLATE
     D   name                        10A
     D   library                     10A

     D QrnNameValue_T...
     D                 DS                  QUALIFIED TEMPLATE
     /* I   Name from external file    */
     D   externalName...
     D                               10A
     /* I   Data type of field         */
     /*     See QrnDatatype_*          */
     D   dataType...
     D                                3U 0
     /* I   Defined length of numeric  */
     /*      - Decimal: total digits   */
     /*      - Integer: bytes          */
     /*      - Unsigned: bytes         */
     /*      - Float: bytes            */
     /*     Numeric fields only        */
     D   numericDefinedLen...
     D                                3U 0
     /* I   Decimal places of field    */
     /*     Decimal fields only        */
     D   decimals...
     D                                3U 0
     /* I   Date/time/timestamp format */
     /*     Date, time, timestamp only */
     D   dtzFormat...
     D                                3U 0
     /* I   Date, time separator       */
     /*     Date, time only            */
     D   dtSeparator...
     D                                1A
     /* I   Input field (field is      */
     /*     set by handler)            */
     D   input...
     D                                 N
     /* I   Output field (field is     */
     /*     used by handler)           */
     D   output...
     D                                 N
     /* I   Is the field null capable  */
     D   isNullCapable...
     D                                 N
     /* I/O Does it have a null value  */
     D   hasNullValue...
     D                                 N
     /*     Hex zeros                  */
     D   reserved1...
     D                               13A
     /* I/O Length of value in bytes   */
     D   valueLenBytes...
     D                               10U 0
     /* I   Maximum length in bytes    */
     D   valueMaxLenBytes...
     D                               10U 0
     /* I   CCSID of the value         */
     D   valueCcsid...
     D                               10I 0
     /*     Zero                       */
     D   reserved2...
     D                               10U 0
     /* I/O The value of the field, in */
     /*     human-readable form        */
     D   value...
     D                                 *
     /*     NULL                       */
     D   reserved3...
     D                                 *

     D QrnNamesValues_T...
     D                 DS                  QUALIFIED TEMPLATE ALIGN
     D   num                         10I 0
     D   field                             LIKEDS(QrnNameValue_T)
     D                                     DIM(32767)

     D QrnOpenAccess_T...
     D                 DS                  TEMPLATE QUALIFIED ALIGN
     /* I   Length of this structure   */
     D   length...
     D                               10U 0
     /*     Zero                       */
     D   reserved1...
     D                               10U 0
     /* I   Format of this structure   */
     /*     ROACnnnn                   */
     D   parameterFormat...
     D                                8A
     /* I/O User area owned by the     */
     /*     RPG program                */
     D   userArea...
     D                                 *
     /* I/O State info owned by        */
     /*     the handler                */
     D   stateInfo...
     D                                 *
     /* I   Record format level        */
     /*     indicators.                */
     /*     - NULL if file is program  */
     /*       described                */
     D   recordLevels...
     D                                 *
     /* O   Input buffer               */
     /*     NULL if not used by opcode */
     /*     - Length is given by       */
     /*       inputBufferLen           */
     D   inputBuffer...
     D                                 *
     /* O   Input null byte map        */
     /*     - Length is given by       */
     /*       inputNullMapLen          */
     D   inputNullMap...
     D                                 *
     /* I   Output buffer              */
     /*     NULL if not used by opcode */
     /*     - Length is given by       */
     /*       outputBufferLen          */
     D   outputBuffer...
     D                                 *
     /* I   Output null byte map       */
     /*     - Length is given by       */
     /*       outputNullMapLen         */
     D   outputNullMap...
     D                                 *
     /* I/O Alternate version of       */
     /*     I/O buffer information     */
     D   namesValues...
     D                                 *
     /* I   Key                        */
     /*     NULL if not used by opcode */
     /*     - Length is given by       */
     /*       keyLen                   */
     D   key...
     D                                 *
     /* I   Key null byte map          */
     /*     - Length is given by       */
     /*       keyNullMapLen            */
     D   keyNullMap...
     D                                 *
     /* I   Alternate version of       */
     /*     key information            */
     D   keynamesValues...
     D                                 *
     /* I/O Indicator array, dim99     */
     /*     NULL if not used by file   */
     /*     or if using names-values   */
     D   indara...
     D                                 *
     /* I   Print control              */
     D   prtctl...
     D                                 *
     /* O   The handler can set        */
     /*     this pointer.              */
     /*     - Length is specified in   */
     /*       openFeedbackLen          */
     D   openFeedback...
     D                                 *
     /* O   The handler can set        */
     /*     this pointer.              */
     /*     - Length is specified in   */
     /*       ioFeedbackLen            */
     D   ioFeedback...
     D                                 *
     /* O   The handler can set        */
     /*     this pointer.              */
     /*     - Length is specified in   */
     /*       deviceFeedbackLen        */
     D   deviceFeedback...
     D                                 *
     /* I   NULL                       */
     D   reserved2...
     D                                 *
     /* I   NULL                       */
     D   reserved3...
     D                                 *
     /* I   NULL                       */
     D   reserved4...
     D                                 *
     /* I   External file              */
     D   externalFile...
     D                                     LIKEDS(QrnObject_T)
     /* I   External member            */
     D   externalMember...
     D                               10A
     /* I   File used at compile time  */
     D   compileFile...
     D                                     LIKEDS(QrnObject_T)
     /* I/O Record name                */
     D   recordName...
     D                               10A
     /*     Hex zeros                  */
     D   reserved5...
     D                               20A
     /* I   RPG operation              */
     /*     See QrnOperation_*         */
     D   rpgOperation...
     D                               10U 0
     /* O   RPG status code            */
     D   rpgStatus...
     D                               10I 0
     /* I   Length of inputBuffer      */
     D   inputBufferLen...
     D                               10U 0
     /* I   Length of inputNullMap     */
     D   inputNullMapLen...
     D                               10U 0
     /* I   Length of outputBuffer     */
     D   outputBufferLen...
     D                               10U 0
     /* I   Length of outputNullMap    */
     D   outputNullMapLen...
     D                               10U 0
     /* I   Length of key              */
     D   keyLen...
     D                               10U 0
     /* I   Length of keyNullMap       */
     D   keyNullMapLen...
     D                               10U 0
     /* O   Length of input data       */
     D   inputDataLen...
     D                               10U 0
     /* O   Length of openFeedback     */
     D   openFeedbackLen...
     D                               10U 0
     /* O   Length of ioFeedback       */
     D   ioFeedbackLen...
     D                               10U 0
     /* O   Length of deviceFeedback   */
     D   deviceFeedbackLen...
     D                               10U 0
     /* I   Number of key fields       */
     /*     N/A for program-desc file  */
     D   numKeys...
     D                               10U 0
     /* I/O RRN                        */
     D   rrn...
     D                               10U 0
     /* I   Printer form length        */
     /*     Only meaningful for        */
     /*     program described file     */
     /*     with device Printer        */
     D   formLen...
     D                               10U 0
     /* I   Printer form overflow      */
     /*     Only meaningful for        */
     /*     program described PRINTER  */
     D   formOfl...
     D                               10U 0
     /* I   Starting line number       */
     /*     for SLNO(*VAR)             */
@A1A D   sln...
@A1A D                               10U 0
     /*     Zero                       */
     D   reserved7...
     D                               10U 0
     /*     Zero                       */
     D   reserved8...
     D                               10U 0
     /*     Zero                       */
     D   reserved9...
     D                               10U 0
     /* O   F1-F24, PRINT,ROLLUP etc   */
     /*     See QrnFunctionKey_*       */
     /*     - Unknown values cause an  */
     /*       RPG exception            */
     D   functionKey...
     D                                3U 0
     /* I   Externally described file  */
     D   externallyDescribed...
     D                                1N
     /* I   RPG keyed access?          */
     D   keyedFile...
     D                                1N
     /* I   BLOCK(*YES)?               */
     D   blocked...
     D                                1N
     /* O   EOF                        */
     D   eof...
     D                                1N
     /* O   Record found               */
     D   found...
     D                                1N
     /* O   Key is equal               */
     D   equal...
     D                                1N
     /* O   Page overflow reached      */
     D   printerOverflow...
     D                                1N
     /* I   Input operation with lock  */
     D   inputWithLock...
     D                                1N
     /* I/O Whether the I/O operations */
     /*     will use the name-value    */
     /*     info rather than the       */
     /*     I/O buffers                */
     /*     Set by handler during OPEN */
     /*     operation, used by handler */
     /*     and RPG for I/O operations */
     D   useNamesValues...
     D                                1N
     /* I   Whether the record is      */
     /*     defined as a subfile to RPG*/
     D   isSubfile...
     D                                1N
     /*     '0'                        */
     D   reservedInds...
@A1C D                                1N   DIM(4)
     /* I   Whether the file will      */
     /*     use commitment control     */
@A1A D   commit...
@A1A D                                1N
     /* I   See QrnDevice_*         */
     D   rpgDevice...
     D                                1A
     /*     Hex zeros                  */
     D   reserved10...
     D                               31A
