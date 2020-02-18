// A simple pony wrapper around the bzip2 library

use "collections"
use "fileExt"
use "flow"

use "path:/usr/lib" if osx
use "lib:bz2"

  
actor BZ2FlowDecompress is Flowable
	
	let target:Flowable tag
	let bufferSize:USize
	
	var bzip2Stream:BzStream
	var bzret:U32 = Bz.ok()
	
	fun _tag():USize => 101

	new create(bufferSize':USize, target':Flowable tag) =>
		target = target'
		bufferSize = bufferSize'
		
		bzip2Stream = BzStream
						
		bzret = @BZ2_bzDecompressInit(BzStreamRef(bzip2Stream), 0, 0).u32()
		if bzret != Bz.ok() then
			return
		end
	
	be flowFinished() =>
		target.flowFinished()
	
	be flowReceived(dataIso:Any iso) =>
		let data:Any ref = consume dataIso
	
		// If the decompression error'd out, then we can't really do anything
		if bzret != Bz.ok() then
			return
		end
	
		try
			let chunk = data as CPointer
	
			bzip2Stream.next_in = chunk.cpointer()
			bzip2Stream.avail_in = chunk.size().u32()
	
			while (bzret == Bz.ok()) and (bzip2Stream.avail_in > 0) do
					
				let chunkBuffer = recover iso Array[U8](bufferSize) end
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

				bzret = @BZ2_bzDecompress(BzStreamRef(bzip2Stream)).u32()
				if (bzret != Bz.ok()) and (bzret != Bz.stream_end()) then
					@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "bzip decompression error\n".cstring())
			        @BZ2_bzDecompressEnd(BzStreamRef(bzip2Stream))
					return
				end
		
				let bytesRead = (bufferSize - bzip2Stream.avail_out.usize())
				chunkBuffer.undefined(bytesRead)
				target.flowReceived(consume chunkBuffer)
			end
		else
			@fprintf[I32](@pony_os_stdout[Pointer[U8]](), "BZ2FlowDecompress requires a CPointer flowable\n".cstring())
		end
		
		
	
	