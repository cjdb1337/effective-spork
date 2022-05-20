CC=odin
LDFLAGS=-framework OpenGL -framework GLUT -framework Cocoa -framework IOKit -framework CoreVideo

chess: chess.odin
	$(CC) build chess.odin -out:shaders -extra-linker-flags:"$(LDFLAGS)"
