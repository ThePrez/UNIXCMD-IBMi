@echo off
set FTPSCRIPT=genzippkg.fts
set HOST=%1
set LIB=%2
set USER=%3
set PASS=%4
if "%HOST%"=="" goto usage
if "%LIB%"=="" goto usage
if "%USER%"=="" goto usage
if "%PASS%"=="" goto usage
echo %USER% > %FTPSCRIPT%
echo %PASS% >> %FTPSCRIPT%
echo cd /qsys.lib/qgpl.lib >> %FTPSCRIPT%
echo quote site namefmt 0 >> %FTPSCRIPT%
echo quote rcmd crtlib %lib% >> %FTPSCRIPT%
echo quote rcmd crtsrcpf file(%LIB%/QCLSRC) rcdlen(92) text('') >> %FTPSCRIPT%
echo quote rcmd crtsrcpf file(%LIB%/QCMDSRC) rcdlen(92) text('') >> %FTPSCRIPT%
echo quote rcmd crtsrcpf file(%LIB%/QPNLSRC) rcdlen(92) text('') >> %FTPSCRIPT%
echo quote rcmd crtsrcpf file(%LIB%/QRPGLESRC) rcdlen(112) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qclsrc/buildit.clp %LIB%/QCLSRC.BUILDIT >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QCLSRC) mbr(BUILDIT) srctype(CLP) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qcmdsrc/clopipe.cmd %LIB%/QCMDSRC.CLOPIPE >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QCMDSRC) mbr(CLOPIPE) srctype(CMD) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qcmdsrc/opnpipe.cmd %LIB%/QCMDSRC.OPNPIPE >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QCMDSRC) mbr(OPNPIPE) srctype(CMD) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qcmdsrc/rcvpipe.cmd %LIB%/QCMDSRC.RCVPIPE >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QCMDSRC) mbr(RCVPIPE) srctype(CMD) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qcmdsrc/sndpipe.cmd %LIB%/QCMDSRC.SNDPIPE >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QCMDSRC) mbr(SNDPIPE) srctype(CMD) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qpnlsrc/clopipe.pnlgrp %LIB%/QPNLSRC.CLOPIPE >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QPNLSRC) mbr(CLOPIPE) srctype(PNLGRP) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qpnlsrc/opnpipe.pnlgrp %LIB%/QPNLSRC.OPNPIPE >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QPNLSRC) mbr(OPNPIPE) srctype(PNLGRP) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qpnlsrc/rcvpipe.pnlgrp %LIB%/QPNLSRC.RCVPIPE >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QPNLSRC) mbr(RCVPIPE) srctype(PNLGRP) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qpnlsrc/sndpipe.pnlgrp %LIB%/QPNLSRC.SNDPIPE >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QPNLSRC) mbr(SNDPIPE) srctype(PNLGRP) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/clopiper4.rpgle %LIB%/QRPGLESRC.CLOPIPER4 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(CLOPIPER4) srctype(RPGLE) text('CL CLOPIPE command CPP') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example1.rpgle %LIB%/QRPGLESRC.EXAMPLE1 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE1) srctype(RPGLE) text('Basic LS example') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example10.rpgle %LIB%/QRPGLESRC.EXAMPLE10 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE10) srctype(RPGLE) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example11.rpgle %LIB%/QRPGLESRC.EXAMPLE11 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE11) srctype(RPGLE) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example2.rpgle %LIB%/QRPGLESRC.EXAMPLE2 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE2) srctype(RPGLE) text('Basic Write to IFS example') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example3.rpgle %LIB%/QRPGLESRC.EXAMPLE3 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE3) srctype(RPGLE) text('Basic Convert ASCII Example') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example4.rpgle %LIB%/QRPGLESRC.EXAMPLE4 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE4) srctype(RPGLE) text('DS I/O Example') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example5.rpgle %LIB%/QRPGLESRC.EXAMPLE5 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE5) srctype(RPGLE) text('DS I/O With PASE Cmd') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example6.rpgle %LIB%/QRPGLESRC.EXAMPLE6 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE6) srctype(RPGLE) text('SSH remote command example') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example7.rpgle %LIB%/QRPGLESRC.EXAMPLE7 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE7) srctype(RPGLE) text('PHP Integration Example') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example8.rpgle %LIB%/QRPGLESRC.EXAMPLE8 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE8) srctype(RPGLE) text('Example of SPECIAL file in free format') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/example9.rpgle %LIB%/QRPGLESRC.EXAMPLE9 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(EXAMPLE9) srctype(RPGLE) text('') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/ifsio_h.rpgle %LIB%/QRPGLESRC.IFSIO_H >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(IFSIO_H) srctype(RPGLE) text('Copybook for accessing IFS from RPG') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/opnpiper4.rpgle %LIB%/QRPGLESRC.OPNPIPER4 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(OPNPIPER4) srctype(RPGLE) text('CL OPNPIPE command CPP') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/qrnopenacc.rpgle %LIB%/QRPGLESRC.QRNOPENACC >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(QRNOPENACC) srctype(RPGLE) text('IBM-supplied Open Access copybook') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/rcvpiper4.rpgle %LIB%/QRPGLESRC.RCVPIPER4 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(RCVPIPER4) srctype(RPGLE) text('CL RCVPIPE command CPP') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/sndpiper4.rpgle %LIB%/QRPGLESRC.SNDPIPER4 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(SNDPIPER4) srctype(RPGLE) text('CL SNDPIPE command CPP') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/spawn_h.rpgle %LIB%/QRPGLESRC.SPAWN_H >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(SPAWN_H) srctype(RPGLE) text('Copybook for spawn() API from RPG') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/unixcmd.rpgle %LIB%/QRPGLESRC.UNIXCMD >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(UNIXCMD) srctype(RPGLE) text('SPECIAL file interface to UNIXCMD') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/unixcmdoa.rpgle %LIB%/QRPGLESRC.UNIXCMDOA >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(UNIXCMDOA) srctype(RPGLE) text('Open Access interface for UNIXCMD') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/unixpipe_h.rpgle %LIB%/QRPGLESRC.UNIXPIPE_H >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(UNIXPIPE_H) srctype(RPGLE) text('Copybook for Unix Pipe Utilities') >> %FTPSCRIPT%
echo ascii >> %FTPSCRIPT%
echo put qrpglesrc/unixpiper4.rpgle %LIB%/QRPGLESRC.UNIXPIPER4 >> %FTPSCRIPT%
echo quote rcmd chgpfm file(%LIB%/QRPGLESRC) mbr(UNIXPIPER4) srctype(RPGLE) text('Unix Pipe utilities service program') >> %FTPSCRIPT%
echo quit >> %FTPSCRIPT%
ftp -s:%FTPSCRIPT% %HOST%
del %FTPSCRIPT%
goto end
:usage
echo.
echo USAGE: ftpsrc HOST LIB USERID PASSWORD
echo.
echo      HOST = FTP server to send to (ex: as400.example.com)
echo       LIB = IBM i library to put source code into (ex: QGPL)
echo    USERID = UserID to log in with
echo  PASSWORD = Password to log in with
echo.
:end
