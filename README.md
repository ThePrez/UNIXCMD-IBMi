UNIXCMD project
----------------------------------------
In order to build the code in this project, you must first upload the
PC files in this ZIP archive to the source files on your IBM i system.

AUTOMATIC FTP UPLOAD
----------------------------------------
Because it can be tedious to transfer all of the files in this project
manually, I've included two FTP scripts:

  ftpsrc.bat -- Windows version of FTP script

NOTE: To use this script, you must be able to access your IBM i system
      via FTP. If that's not available, you'll need to find a way to
      upload stuff manually.

To run the automatic upload:

      ftpsrc.bat YOUR-HOST YOUR-LIB YOUR-USERID YOUR-PASSWORD

Where:
    YOUR-HOST = computer (TCP/IP domain name or IP address) 
     YOUR-LIB = library to put source into
  YOUR-USERID = your userid to sign on to FTP with
YOUR-PASSWORD = your password to sign on to FTP with

Example:
     ftpsrc.bat as400.example.com MYLIB klemscot bigboy


MANUAL UPLOAD
----------------------------------------
Here's a list of the enclosed files, and the source file/member to upload them to:

PC File            IBM i srcfile/member                 Type
----------------   ----------------------------------   -------
in qrpglesrc directory:
example1.rpgle     qrpglesrc, example1                  rpgle
example2.rpgle     qrpglesrc, example2                  rpgle
example3.rpgle     qrpglesrc, example3                  rpgle
example4.rpgle     qrpglesrc, example4                  rpgle
example5.rpgle     qrpglesrc, example5                  rpgle
example6.rpgle     qrpglesrc, example6                  rpgle
example7.rpgle     qrpglesrc, example7                  rpgle
example8.rpgle     qrpglesrc, example8                  rpgle
example9.rpgle     qrpglesrc, example9                  rpgle
example10.rpgle    qrpglesrc, example10                 rpgle
example11.rpgle    qrpglesrc, example11                 rpgle
ifsio_h.rpgle      qrpglesrc, ifsio_h                   rpgle
spawn_h.rpgle      qrpglesrc, spawn_h                   rpgle
unixcmd.rpgle      qrpglesrc, unixcmd                   rpgle
unixcmdoa.rpgle    qrpglesrc, unixcmdoa                 rpgle
unixpipe_h.rpgle   qrpglesrc, unixpipe_h                rpgle
unixpiper4.rpgle   qrpglesrc, unixpiper4                rpgle
opnpiper4.rpgle	   qrpglesrc, opnpiper4			rpgle
sndpiper4.rpgle	   qrpglesrc, sndpiper4			rpgle
rcvpiper4.rpgle	   qrpglesrc, rcvpiper4			rpgle
clopiper4.rpgle	   qrpglesrc, clopiper4			rpgle

in qcmdsrc directory:
opnpipe.cmd	   qcmdsrc, opnpipe			cmd
sndpipe.cmd	   qcmdsrc, sndpipe			cmd
rcvpipe.cmd	   qcmdsrc, rcvpipe			cmd
clopipe.cmd	   qcmdsrc, clopipe			cmd

in qpnlsrc directory:
opnpipe.pnlgrp	   qpnlsrc, opnpipe                     pnlgrp
sndpipe.pnlgrp	   qpnlsrc, sndpipe                     pnlgrp
rcvpipe.pnlgrp	   qpnlsrc, rcvpipe                     pnlgrp
clopipe.pnlgrp	   qpnlsrc, clopipe                     pnlgrp

in qclsrc directory:
buildit.clp	   qclsrc, buildit			clp

I recommend uploading these files using FTP in ASCII mode.  However, other methods (including copy/paste into WDSC/RDi) should work just fine as well.


COMPILING THE TOOL
----------------------------------------
  - Make sure the file you used in your uploads is in your *LIBL
  - Set your *CURLIB to the library you want the programs 
      to be compiled into.
  - CRTCLPGM buildit SRCFILE(QCLSRC)
  - CALL buildit

If you need assistance, please use the RPG Forum over on Code400.com
http://www.code400.com/forum/

Good luck!
