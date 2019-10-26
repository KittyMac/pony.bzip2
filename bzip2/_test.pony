use "fileExt"
use "ponytest"

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestStringDecompression)


class iso _TestStringDecompression is UnitTest
	fun name(): String => "small file decompression"

	fun apply(h: TestHelper) =>		
		FileExtStreamReader(h.env, "test_large.bz2", 1024*1024*16,
			BZ2StreamDecompress(h.env, 1024*1024*16,
				FileExtStreamWriterEnd(h.env, "/tmp/test_bzip_decompress.txt")
			)
		)
		