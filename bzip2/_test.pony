use "fileExt"
use "files"
use "ponytest"

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestStringDecompression)
	
 	fun @runtime_override_defaults(rto: RuntimeOptions) =>
		rto.ponyminthreads = 2
		rto.ponynoblock = true
		rto.ponygcinitial = 0
		rto.ponygcfactor = 1.0


class iso _TestStringDecompression is UnitTest
	fun name(): String => "small file decompression"

	fun apply(h: TestHelper) =>	
		var inFilePath = "test_large.bz2"
		var outFilePath = "/tmp/test_bzip_decompress.txt"

		FileExtFlowReader(inFilePath, 1024*1024*16,
			BZ2FlowDecompress(1024*1024*16,
				FileExtFlowByteCounter(
					FileExtFlowWriterEnd(outFilePath)
				)
			)
		)
		