SUBDIR=	lua lib ncurses installer

test:
	-killall lua50
	lua50c51 /usr/local/share/dfuibe_lua/main.lua \
	    /usr/local/share/dfuibe_lua/conf/BSDInstaller.lua \
	    /usr/local/share/dfuibe_lua/conf/FreeBSD.lua \
	    /usr/local/share/dfuibe_lua/conf/Product.lua

.include <bsd.subdir.mk>
