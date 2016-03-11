TARGET = osxMediaKey

CC = gcc
CFLAGS = -O3 -Wall
LDFLAGS = -framework Cocoa -framework IOKit
RM = rm -rf
COPY = cp -f
MKDIR = mkdir -p
SRCS = $(wildcard *.m)
OBJS = $(SRCS:.m=.o)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

%.o: %.m
	$(CC) -c $(CFLAGS) -o $@ $<

clean:
	$(RM) $(OBJS) $(TARGET) $(TARGET).app

app: all
	$(MKDIR) $(TARGET).app/Contents/MacOS/
	$(COPY) $(TARGET) $(TARGET).app/Contents/MacOS/
