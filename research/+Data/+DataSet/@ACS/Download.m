function Download(ds)
% Data.DataSet.ACS.Download
% 
% Description:	download raw data from the ACS data set
% 
% Syntax:	ds.Download
% 
% Updated: 2013-03-09
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
Download@Data.DataSet(ds);

yrNow	= str2num(FormatTime(nowms,'yyyy'));

f	= ftp('ftp2.census.gov','anonymous','');

%get years 1996 - 2004 via "Core_Tables"
	for yr=1996:2004
		strYr		= num2str(yr);
		strDirCore	= ['/acs/downloads/Core_Tables/' strYr];
		strDirData	= DirAppend(ds.data_dir,strYr);
		
		Data.FTP.DirectoryTransfer(f,strDirCore,strDirData);
	end
%get years 2005 - present via ???
	

%urlwrite
