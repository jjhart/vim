	if did_filetype()	" filetype already set..
	  finish		" ..don't do these checks
	endif
	if getline(1) =~ '^#!.*\<perl\>'
	  setfiletype perl
	elseif getline(1) =~? '^#!.*\<bash\>'
	  setfiletype sh
	endif

