// A simple pony wrapper around the bzip2 library

use "collections"
use "fileExt"

use "path:/usr/lib" if osx
use "lib:bz2"

use @BZ2_bzDecompressInit[I32](strm: NullablePointer[BZ2STREAM] ref, verbosity: I32, small: I32)
use @BZ2_bzDecompress[I32](strm: NullablePointer[BZ2STREAM] ref)
use @BZ2_bzDecompressEnd[I32](strm: NullablePointer[BZ2STREAM] ref)

  
struct BZ2STREAM
	var next_in:Pointer[U8] tag
	var avail_in:U32 = 0
	var total_in_lo32:U32 = 0
	var total_in_hi32:U32 = 0

	var next_out:Pointer[U8] tag
	var avail_out:U32 = 0
	var total_out_lo32:U32 = 0
	var total_out_hi32:U32 = 0

	var state:Pointer[U8] tag

	var bzalloc:Pointer[U8] tag
	var bzfree:Pointer[U8] tag
	var opaque:Pointer[U8] tag
	
	new create() =>
		next_in = Pointer[U8]
		next_out = Pointer[U8]
		state = Pointer[U8]
		bzalloc = Pointer[U8]
		bzfree = Pointer[U8]
		opaque = Pointer[U8]

actor BZ2StreamDecompress is Streamable

	let bz_run:I32 = 0
	let bz_flush:I32 = 1
	let bz_finish:I32 = 2

	let bz_ok:I32 = 0
	let bz_run_ok:I32 = 1
	let bz_flush_ok:I32 = 2
	let bz_finish_ok:I32 = 3
	let bz_stream_end:I32 = 4
	let bz_sequence_error:I32 = -1
	let bz_param_error:I32 = -2
	let bz_mem_error:I32 = -3
	let bz_data_error:I32 = -4
	let bz_data_error_magic:I32 = -5
	let bz_io_error:I32 = -6
	let bz_unexpected_eof:I32 = -7
	let bz_outbuff_full:I32 = -8
	let bz_config_error:I32 = -9
	
	let target:Streamable tag
	let env:Env
	let bufferSize:USize
	
	var bzip2Stream:BZ2STREAM
	var bzret:I32 = bz_ok

	new create(env':Env, bufferSize':USize, target':Streamable tag) =>
		target = target'
		env = env'
		bufferSize = bufferSize'
		
		bzip2Stream = BZ2STREAM
						
		bzret = @BZ2_bzDecompressInit(NullablePointer[BZ2STREAM](bzip2Stream), 0, 0)
		if bzret != bz_ok then
			return
		end
	
	be stream(chunkIso:ByteBlock iso) =>
		let chunk = consume chunkIso
		
		// If the decompression error'd out, then close the stream
		if bzret != bz_ok then
			target.stream(recover ByteBlock end)
			return
		end
		
		bzip2Stream.next_in = chunk.cpointer()
		bzip2Stream.avail_in = chunk.size().u32()
		
		while (bzret == bz_ok) and (bzip2Stream.avail_in > 0) do
						
			let chunkBuffer = recover ByteBlock(bufferSize) end
			bzip2Stream.next_out = chunkBuffer.cpointer()
			bzip2Stream.avail_out = bufferSize.u32()
			
			/*
			env.out.print("bzip2Stream.avail_in : " + bzip2Stream.avail_in.string())
			env.out.print("bzip2Stream.total_in_lo32 : " + bzip2Stream.total_in_lo32.string())
			env.out.print("bzip2Stream.total_in_hi32 : " + bzip2Stream.total_in_hi32.string())
			env.out.print("bzip2Stream.avail_out : " + bzip2Stream.avail_out.string())
			env.out.print("bzip2Stream.total_out_lo32 : " + bzip2Stream.total_out_lo32.string())
			env.out.print("bzip2Stream.total_out_hi32 : " + bzip2Stream.total_out_hi32.string())
			*/

			bzret = @BZ2_bzDecompress(NullablePointer[BZ2STREAM](bzip2Stream))
			if (bzret != bz_ok) and (bzret != bz_stream_end) then
				env.out.print("******* bzip2 error! ********")
		        @BZ2_bzDecompressEnd(NullablePointer[BZ2STREAM](bzip2Stream))
				target.stream(recover ByteBlock end)
				return
			end
			
			let bytesRead = (bufferSize - bzip2Stream.avail_out.usize())
			chunkBuffer.truncate(bytesRead)
			target.stream(consume chunkBuffer)
		end
				
		
		
	
	