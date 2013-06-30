CC = cc
#WFLAGS = -Wmissing-prototypes -Wunused -Wimplicit -Wreturn-type -Wparentheses -pedantic
# the 10.2 (July-2002) developer tools seems to think that all preprocessor
# directives are gnu extensions, and -pedantic generates a warning for each
# #include, #if, etc.
WFLAGS = -Wmissing-prototypes -Wunused -Wimplicit -Wreturn-type -Wparentheses
CFLAGS = -g $(WFLAGS) -D__Mac -I/Developer/Headers/FlatCarbon/
FONDUOBJS = fondu.o readnfnt.o fondups.o
UFONDOBJS = ufond.o ufondbdf.o ufondpfb.o ufondttf.o crctab.o
DFONT2RESOBJS = dfont2res.o crctab.o
SHOWOBJS = showfond.o
TOBINOBJS = tomacbinary.o crctab.o
FROMBINOBJS = frommacbinary.o
LUMPEROBJS = lumper.o
SETFONDNAMEOBJS = setfondname.o
#CORE = /System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/CarbonCore
CORE = /System/Library/Frameworks/CoreServices.framework/CoreServices

bindir = /usr/local/bin

all: fondu ufond showfond dfont2res tobin frombin lumper setfondname

fondu: $(FONDUOBJS)
	$(CC) $(CFLAGS) -o fondu $(FONDUOBJS) -lm $(CORE)

ufond: $(UFONDOBJS)
	$(CC) $(CFLAGS) -o ufond $(UFONDOBJS)

showfond: $(SHOWOBJS)
	$(CC) $(CFLAGS) -o showfond $(SHOWOBJS) $(CORE)

dfont2res: $(DFONT2RESOBJS)
	$(CC) $(CFLAGS) -o dfont2res $(DFONT2RESOBJS)

tobin: $(TOBINOBJS)
	$(CC) $(CFLAGS) -o tobin $(TOBINOBJS) $(CORE)

frombin: $(FROMBINOBJS)
	$(CC) $(CFLAGS) -o frombin $(FROMBINOBJS) $(CORE)

lumper: $(LUMPEROBJS)
	$(CC) $(CFLAGS) -o lumper $(LUMPEROBJS)

setfondname: $(SETFONDNAMEOBJS)
	$(CC) $(CFLAGS) -o setfondname $(SETFONDNAMEOBJS)

clean:
	-rm -f *.o fondu ufond showfond dfont2res tobin frombin lumper setfondname

distclean: clean
	-rm Makefile

install: all
	cp fondu ufond showfond dfont2res tobin frombin lumper setfondname $(bindir)
