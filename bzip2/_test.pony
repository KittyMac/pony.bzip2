use "fileExt"
use "files"
use "ponytest"

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestStringDecompression)


class iso _TestStringDecompression is UnitTest
	fun name(): String => "small file decompression"

	fun apply(h: TestHelper) =>	
		try
			var inFilePath = FilePath(h.env.root as AmbientAuth, "test_large.bz2", FileCaps.>all())?
			var outFilePath = FilePath(h.env.root as AmbientAuth, "/tmp/test_bzip_decompress.txt", FileCaps.>all())?

			FileExtFlowReader(inFilePath, 1024*1024*16,
				BZ2FlowDecompress(1024*1024*16,
					FileExtFlowWriterEnd(outFilePath)
				)
			)
		end
		