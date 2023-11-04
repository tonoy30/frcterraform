add-content -path %HOMEPATH%/.ssh/config -value @'

Host ${hostname}
	HostName ${hostname}
	User ${user}
	IdentityFile ${identityfile}
'@
