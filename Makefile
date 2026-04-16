CC = clang
CFLAGS = -framework Metal -framework Foundation -framework AppKit \
         -dynamiclib -fPIC -O2 -g \
         -mmacosx-version-min=14.0

TARGET = tarnish.dylib
SRCS = src/tarnish.m src/frame_sched.m

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET)
