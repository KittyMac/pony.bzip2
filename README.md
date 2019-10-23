# pony.bzip2
A wrapper around the bzip2 library to allow for easy compression/decompression in Pony

Utilizes the Streamable type available in the [pony.fileExt](https://github.com/KittyMac/pony.fileExt) library.

```
FileExtStreamReader(h.env, "test_large.bz2", 1024*1024*16,
	BZ2StreamDecompress(h.env,
		FileExtStreamWriterEnd(h.env, "/tmp/test_bzip_decompress.txt")
	)
)
```