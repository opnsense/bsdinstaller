# $Id: Makefile,v 1.8 2005/08/27 07:20:39 cpressey Exp $
# BSD Installer Makefile for luasocket, adapted from makefile.Linux.

BASE?=../../..
include ${BASE}/Config

LV=2.0
MV=1.0

LUA?=../../../lua

COMPAT?=../compat-5.1

LOBJS=	luasocket.o timeout.o buffer.o io.o auxiliar.o except.o \
	select.o options.o inet.o tcp.o udp.o usocket.o

MOBJS=	mime.o

CFLAGS+=	-I$(LUA)/include -I$(COMPAT) \
		$(PROF) $(DBG) -pedantic -W -Wall -fPIC
LDFLAGS+=	-L$(LUA)/lib -llua -llualib

LDYN=lsocket.so

MDYN=lmime.so

all: $(LDYN) $(MDYN)

$(LDYN): $(LOBJS)
	$(CC) $(LOBJS) $(COMPAT)/compat-5.1.o -shared $(LDFLAGS) -o $(LDYN)

$(MDYN): $(MOBJS)
	$(CC) ${MOBJS} $(COMPAT)/compat-5.1.o -shared ${LDFLAGS} -o $(MDYN)

strip:
	strip $(LDYN) $(MDYN)

clean:
	rm -f $(LOBJS) $(MOBJS) $(SOBJS)
	rm -f $(MDYN) $(LDYN) $(SDYN)

install: strip
	mkdir -p $(DESTDIR)${PREFIX}/lib/lua/5.0
	cp $(LDYN) $(MDYN) $(DESTDIR)${PREFIX}/lib/lua/5.0
	mkdir -p $(DESTDIR)${PREFIX}/share/lua/5.0
	cp lua/*.lua $(DESTDIR)${PREFIX}/share/lua/5.0
