     FUNIX      IF   F 1000        SPECIAL PGMNAME('UNIXCMD')
     F                                     PLIST(UNIXPARM) USROPN
     FQSYSPRT   O    F  132        PRINTER

     D cmd             s           5000a
     D mode            s              1A   inz('P')

     D record          ds          1000
     D outrec          ds           132

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
     C                   PARM                    MODE
      /free
          cmd = 'ssh bcserv3.klements.com ps axww "|" +
                 grep boxrelay "|" grep -v grep';
          open UNIX;

          read UNIX record;
          dow not %eof(UNIX);
             outrec = record;
             write QSYSPRT outrec;
             read UNIX record;
          enddo;

          close UNIX;
          *inlr = *on;
      /end-free
