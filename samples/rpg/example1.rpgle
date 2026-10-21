     FUNIX      CF   F 1000        SPECIAL PGMNAME('UNIXCMD')
     F                                     PLIST(UNIXPARM) USROPN
     FQSYSPRT   O    F  132        PRINTER

     D cmd             s           5000a
     D record          s           1000a
     D outrec          s            132a

     IUNIX      NS
     I                                  1 1000  Record

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
      /free
          cmd = 'cd /tmp; ls';
          open UNIX;

          read UNIX;
          dow not %eof(UNIX);
             outrec = record;
             except;
             read UNIX;
          enddo;

          *inlr = *on;
      /end-free

     OQSYSPRT   E
     O                       outrec             132
