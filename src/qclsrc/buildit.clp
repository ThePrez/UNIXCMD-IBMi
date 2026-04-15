/*-                                                                            +
 * Copyright (c) 2010-2016 Scott C. Klement                                    +
 * All rights reserved.                                                        +
 *                                                                             +
 * Redistribution and use in source and binary forms, with or without          +
 * modification, are permitted provided that the following conditions          +
 * are met:                                                                    +
 * 1. Redistributions of source code must retain the above copyright           +
 *    notice, this list of conditions and the following disclaimer.            +
 * 2. Redistributions in binary form must reproduce the above copyright        +
 *    notice, this list of conditions and the following disclaimer in the      +
 *    documentation and/or other materials provided with the distribution.     +
 *                                                                             +
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ''AS IS'' AND      +
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
 * SUCH DAMAGE.                                                                +
 *                                                                             +
 */                                                                            +


/*   THIS IS THE PROCEDURE REQUIRED TO BUILD THE UNIXCMD       +
     TOOLS.                                                    +
                            SCOTT KLEMENT, JANUARY 14, 2010   */
PGM
      DCL VAR(&RCVVAR)   TYPE(*CHAR) LEN(32)
      DCL VAR(&RCVLEN)   TYPE(*CHAR) LEN(4)
      DCL VAR(&PRODINFO) TYPE(*CHAR) LEN(27)
      DCL VAR(&ERRCODE)  TYPE(*CHAR) LEN(8)
      DCL VAR(&VERSION)  TYPE(*CHAR) LEN(6)


  /* GET IBM i VERSION */

      CHGVAR VAR(%BIN(&RCVLEN  1 4)) VALUE(32)
      CHGVAR VAR(%BIN(&ERRCODE 1 4)) VALUE(0)
      CHGVAR VAR(%SST(&PRODINFO  1  7)) VALUE('*OPSYS')
      CHGVAR VAR(%SST(&PRODINFO  8  6)) VALUE('*CUR'  )
      CHGVAR VAR(%SST(&PRODINFO 14  4)) VALUE('0000'  )
      CHGVAR VAR(%SST(&PRODINFO 18 10)) VALUE('*CODE' )

      CALL PGM(QSZRTVPR) PARM(&RCVVAR    +
                              &RCVLEN    +
                              'PRDR0100' +
                              &PRODINFO  +
                              &ERRCODE   )

      CHGVAR VAR(&VERSION) VALUE(%SST(&RCVVAR 20 6))


   /* THE CORE ROUTINES ARE IN THIS SERVICE PROGRAM....   */

      CRTRPGMOD UNIXPIPER4 DBGVIEW(*LIST)
      CRTSRVPGM UNIXPIPER4 EXPORT(*ALL) BNDDIR(QC2LE)
      DLTMOD UNIXPIPER4

   /* BUILD THE RPG SPECIAL FILE INTERFACE */

      CRTRPGMOD UNIXCMD DBGVIEW(*LIST)
      CRTPGM UNIXCMD ACTGRP(UNIXCMD) BNDSRVPGM(UNIXPIPER4)

   /* BUILD THE OPEN ACCESS INTERFACE */

      IF (&VERSION *GE 'V6R1M0') DO
         CRTRPGMOD UNIXCMDOA DBGVIEW(*LIST)
         CRTPGM UNIXCMDOA ACTGRP(UNIXCMD) BNDSRVPGM(UNIXPIPER4)
      ENDDO

   /* BUILD CL OPNPIPE COMMAND */

      CRTRPGMOD OPNPIPER4 DBGVIEW(*LIST)
      CRTPGM OPNPIPER4 ACTGRP(UNIXCMD) BNDSRVPGM(UNIXPIPER4)
      DLTMOD OPNPIPER4
      CRTPNLGRP OPNPIPE
      CRTCMD CMD(OPNPIPE) PGM(OPNPIPER4) +
             ALLOW(*IPGM *IMOD *BPGM *BMOD) +
             HLPPNLGRP(OPNPIPE) HLPID(OPNPIPE)

   /* BUILD CL SNDPIPE COMMAND */

      CRTRPGMOD SNDPIPER4 DBGVIEW(*LIST)
      CRTPGM SNDPIPER4 ACTGRP(UNIXCMD) BNDSRVPGM(UNIXPIPER4)
      DLTMOD SNDPIPER4
      CRTPNLGRP SNDPIPE
      CRTCMD CMD(SNDPIPE) PGM(SNDPIPER4) +
             ALLOW(*IPGM *IMOD *BPGM *BMOD) +
             HLPPNLGRP(SNDPIPE) HLPID(SNDPIPE)

   /* BUILD CL RCVPIPE COMMAND */

      CRTRPGMOD RCVPIPER4 DBGVIEW(*LIST)
      CRTPGM RCVPIPER4 ACTGRP(UNIXCMD) BNDSRVPGM(UNIXPIPER4)
      DLTMOD RCVPIPER4
      CRTPNLGRP RCVPIPE
      CRTCMD CMD(RCVPIPE) PGM(RCVPIPER4) +
             ALLOW(*IPGM *IMOD *BPGM *BMOD) +
             HLPPNLGRP(RCVPIPE) HLPID(RCVPIPE)

   /* BUILD CL CLOPIPE COMMAND */

      CRTRPGMOD CLOPIPER4 DBGVIEW(*LIST)
      CRTPGM CLOPIPER4 ACTGRP(UNIXCMD) BNDSRVPGM(UNIXPIPER4)
      DLTMOD CLOPIPER4
      CRTPNLGRP CLOPIPE
      CRTCMD CMD(CLOPIPE) PGM(CLOPIPER4) +
             ALLOW(*IPGM *IMOD *BPGM *BMOD) +
             HLPPNLGRP(CLOPIPE) HLPID(CLOPIPE)

   /* BUILD SAMPLE PROGRAMS */

      CRTBNDRPG EXAMPLE1 DBGVIEW(*LIST)
      CRTBNDRPG EXAMPLE2 DBGVIEW(*LIST)
      CRTBNDRPG EXAMPLE3 DBGVIEW(*LIST)
      CRTBNDRPG EXAMPLE4 DBGVIEW(*LIST)
      CRTBNDRPG EXAMPLE5 DBGVIEW(*LIST)
      CRTBNDRPG EXAMPLE6 DBGVIEW(*LIST)
      CRTBNDRPG EXAMPLE7 DBGVIEW(*LIST)


   /* THESE EXAMPLES REQUIRE LATER VERSIONS OF IBM i, +
      AND ALSO REQUIRE CERTAIN PTFs, SO WE MONMSG IN  +
      CASE THE PTFs AREN'T AVAILABLE                  */

      IF (&VERSION *GE V7R1M0) DO
         CRTBNDRPG EXAMPLE8 DBGVIEW(*LIST)
         MONMSG CPF0000
      ENDDO

      IF (&VERSION *GE V7R2M0) DO
         CRTBNDRPG EXAMPLE9 DBGVIEW(*LIST)
         MONMSG CPF0000

         CRTBNDRPG EXAMPLE10 DBGVIEW(*LIST)
         MONMSG CPF0000

         CRTBNDRPG EXAMPLE11 DBGVIEW(*LIST)
         MONMSG CPF0000
      ENDDO

ENDPGM
