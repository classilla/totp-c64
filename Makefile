OBJ=../prg/totp

.DEFAULT: $(OBJ)

.PHONY: clean

$(OBJ): totp.arc
	pucrunch -fshort totp.arc $(OBJ)

totp.arc: totp.o main.o
	tools/linkb --ofile=totp.arc main.o totp.o

totp.o: sha1.xa totp.xa time.xa spr.gen
	xa -o totp.o -l totp.sym totp.xa
	@grep key, totp.sym | perl -ane 'print "$$F[0]\t".hex($$F[1])."\n"'
	@grep totpsa, totp.sym | perl -ane 'print "$$F[0]\t".hex($$F[1])."\n"'
	@grep utimah, totp.sym | perl -ane 'print "$$F[0]\t".hex($$F[1])."\n"'
	@grep utimon, totp.sym | perl -ane 'print "$$F[0]\t".hex($$F[1])."\n"'

spr.gen: lock.spr
	tools/spr2data -byt lock.spr > spr.gen

main.o: main.bas
	tools/bt --ofile=main.o main.bas

clean:
	rm -f *.o *.sym *.arc *.gen $(OBJ)
