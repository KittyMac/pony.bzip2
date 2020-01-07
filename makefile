all:
	stable env /Volumes/Development/Development/pony/ponyc/build/release/ponyc -o ./build/ ./bzip2
	time ./build/bzip2

test:
	stable env /Volumes/Development/Development/pony/ponyc/build/release/ponyc -V=0 -o ./build/ ./bzip2
	./build/bzip2