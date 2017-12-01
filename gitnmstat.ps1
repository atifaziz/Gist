git log --pretty=%h |
	% { git cat-file -p $_ } |
	? { $_ -match '\b(committer|author) +(.+?) +<(.+?)>' } |
	% { New-Object psobject -Property @{ Role  = $Matches[1];
										 Name  = $Matches[2];
										 Email = $Matches[3] } } |
	Group-Object Name, Email, Role -NoElement |
	select Count, Name
