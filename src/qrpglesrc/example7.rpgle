     FUNIX      CF   F 1000        SPECIAL PGMNAME('UNIXCMD')
     F                                     PLIST(UNIXPARM) USROPN
     FQSYSPRT   O    F  132        PRINTER

     D cmd             s           5000a

     D record          ds          1000
     D lat             s             11p 7
     D lon             s             11p 7

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
      /free
          cmd = 'PATH=$PATH:/usr/local/ZendSvr6/bin && +
                iconv -f 37 -t 819 | +
                php-cli /www/zendsvr/htdocs/geocode.php';
          open UNIX;

          record = '1600 W Pennsylvania Av, Washington DC';
          write UNIX record;

          read UNIX record;
          lat = %dec(record: 11: 7);

          read UNIX record;
          lon = %dec(record: 11: 7);

          close UNIX;

          dsply ('lat=' + %char(lat));
          dsply ('lon=' + %char(lon));
          *inlr = *on;
      /end-free
