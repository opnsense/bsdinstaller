SUBDIR=	lua lib ncurses installer

upgrade:
.for DIR in ${SUBDIR}
	@${MAKE} -C ${DIR} all
.endfor
.for DIR in ${SUBDIR}
	@${MAKE} -C ${DIR} install
.endfor
.for DIR in ${SUBDIR}
	@${MAKE} -C ${DIR} clean
.endfor

test:
	-killall lua50
	lua50c51 /usr/local/share/dfuibe_lua/main.lua \
	    /usr/local/share/dfuibe_lua/conf/BSDInstaller.lua \
	    /usr/local/share/dfuibe_lua/conf/Product.lua

.include <bsd.subdir.mk>
