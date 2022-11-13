# ik should be set to totpsa, ah to utimah, ky to key and um to utimon
10 poke56,32:clr:ky=12288:ik=16384:tc=ik+3:td=tc+3:ah=18930:am=ah+1:as=am+1
20 um=21145:gosub2000:print"{Senhqqq}TOTP-C64 0.5 (C)2022 Cameron Kaiser"
#        ########################################
30 print"All rights reserved. BSD license."
40 print"http://oldvcr.blogspot.com/"
50 fori=0to63:pokeky+i,0:next:print"{q}(L)oad binary key from disk or":km=0
60 print"(E)nter temporary hex key?":a1$="l":a2$="e":gosub1000:ifaagoto250
70 print"Enter temporary key in hex, no spaces.":inputke$
80 iflen(ke$)>128orlen(ke$)<2or(len(ke$)and1)thenprint"Illegal length":goto50
90 en=0:ly=ky:fori=1tolen(ke$):hx=0:c$=mid$(ke$,i,1)
100 d$=mid$(ke$,i+1,1):i=i+1:ifc$<"0"ord$<"0"thenen=1:i=len(ke$):goto230
110 ifc$<="9"thenhx=hx+(asc(c$)-48)*16:goto170
120 ifc$<"a"thenen=1:i=len(ke$):goto230
130 ifc$<"g"thenhx=hx+(asc(c$)-55)*16:goto170
140 ifc$<"A"thenen=1:i=len(ke$):goto230
150 ifc$<"G"thenhx=hx+(asc(c$)-183)*16:goto170
160 en=1:i=len(ke$):goto230
170 ifd$<="9"thenhx=hx+(asc(d$)-48):goto230
180 ifd$<"a"thenen=1:i=len(ke$):goto230
190 ifd$<"g"thenhx=hx+(asc(d$)-55):goto230
200 ifd$<"A"thenen=1:i=len(ke$):goto230
210 ifd$<"G"thenhx=hx+(asc(d$)-183):goto230
220 en=1:i=len(ke$)
230 pokely,hx:ly=ly+1:next:ifenthenprint"Illegal character":goto50
240 sysik:goto430
250 ly=ky:input"{q}Filename";f$:iflen(f$)=0thenprint"Cancelled":goto50
260 print"Device?"peek(186):input"{Q}Device";dv:ifdv<8ordv>30goto50
270 open15,dv,15:close15:ifstthenprint"Device not present":goto50
280 open15,dv,15,"r0:"+f$+"="+f$:input#15,en:close15
290 ifen<>0anden<>63thenprint"File not found":goto50
300 input"Filetype? p{|||}";t$:ift$<>"p"andt$<>"s"andt$<>"u"thenprint"?":goto50
310 open15,dv,15:open1,dv,2,f$+","+t$+",r":input#15,en,em$,et,es
320 ifen<>0thenprinten,em$,et,es:close1:close15:goto50
330 poke144,.:input"Offset in file? 0{|||}";of:input"Length (0=max)? 0{|||}";le
340 ifle>64orle<0thenprint"Key length must be 0-64":close1:close15:goto250
350 ol=le:ifof<=0goto380
360 ifstthenclose1:close15:print"Unexpected EOF (offset)":goto50
370 get#1,a$:of=of-1:ifof>0then360
380 ifstthenclose1:close15:print"Unexpected EOF (key)":goto50
390 ifolthenget#1,a$:pokely,asc(a$):ly=ly+1:le=le-1:ifle>0goto380
400 ifolthenprintol"byte key read":close1:close15:sysik:goto430
410 get#1,a$:pokely,asc(a$):ly=ly+1:le=le+1:ifst=0andle<64then410
420 printle"byte key read":close1:close15:sysik
430 print"{q}F1: new key":print"Get (C)MD T-RA time or":km=1
440 print"(E)nter time manually?":a1$="e":a2$="c":gosub1000:te=aa:ifaegoto50
450 iftegoto500
460 print"{q}Device?"peek(186):input"{Q}Device";dv:ifdv<8ordv>30goto430
470 open15,dv,15:close15:ifstthenprint"Device not present":goto430
480 open15,dv,15,"t-ra":get#15,s$:prints$;
481 get#15,a$:printa$;:ifst=0then481
490 close15:print
491 ifs$=chr$(199)ors$="3"thenprint"CMD RTC not supported":goto430
500 print"Enter hours from UTC.":print"e.g. PST: -8":print"e.g. AEDT: 11"
510 input"Time zone hours";th:ifth<-23orth>23thenprint"Unpossible":goto430
520 input"Minutes (usually 0)? 0{|||}";tm:iftm<0ortm>59thenprint"Nope":goto430
530 pokeas,0:pokeah,abs(th):pokeam,tm:ifth>0thenpokeas,1
540 ifte=0thenprint"{SW}F1: stop{e}":open15,dv,15,"t-ra":systc:close15:goto20
550 tu=um:input"Month";bb:ifbb<1orbb>12thenprint"Illegal month":goto430
560 mo=bb:bb=bb-1:gosub1020
560 input"Day";bb:ifbb<1orbb>31thenprint"Illegal date":goto430
570 ifbb=31and(mo=2ormo=4ormo=6ormo=9ormo=11)thenprint"Illegal date":goto430
580 ifbb=30andmo=2thenprint"Illegal date":goto430:rem leap years xxx
590 gosub1020:input"Year";bb:ifbb<2000andbb>99thenprint"Unsupported":goto430
592 ifbb<0thenprint"BC not allowed":goto430
600 ifbb<2000thenbb=bb+2000:print"Adjusted to year"bb
610 gosub1020:print"{q}Enter what time will be on entry."
620 input"Hours (24 hour time)";bb:ifbb<0orbb>23thenprint"Illegal hour":goto430
630 gosub1020:input"Minutes";bb:ifbb<0orbb>59thenprint"Illegal minute":goto430
640 gosub1020:input"Seconds";bb:ifbb<0orbb>59thenprint"Illegal second":goto430
650 gosub1020:poke198,0:print"{q}Press F1 to reenter or press"
660 print"any other key when time correct":wait198,1:geta$:ifa$=chr$(133)goto550
670 print"{SW}F1: stop{e}":systd:goto20
999 end
1000 geta$:ifa$<>a1$anda$<>a2$and(km=0ora$<>chr$(133))goto1000
1010 aa=(a$=a1$):ae=(a$=chr$(133)):return
1020 a$=mid$(str$(bb),2):if(len(a$)and1)thena$="0"+a$
1030 fori=1tolen(a$):poketu,asc(mid$(a$,i,1))-48:tu=tu+1:next:return
2000 poke53280,.:poke53265,11:print"{Senh}";:sysik:poke53262,172:poke53271,127
2010 forj=0to5:poke53248+j+j,136+j*16:poke53249+j+j,120:poke53287+j,1:next
2020 poke53277,127:poke53263,92:poke53271,127:poke53277,127:poke53294,7
2030 poke2047,128:poke53281,0:poke53269,0:poke53265,27:return
