function p_GetRemoveLock(sch)
% p_GetRemoveLock
% 
% Description:	get a lock on removing from the task list
% 
% Syntax:	p_GetRemoveLock(sch)
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sch.root.info.scheduler.lock_remove	= sch.root.info.scheduler.lock_remove + 1;
