all:
	stable env ponyc -o ./build/ ./bzip2
	./build/bzip2
