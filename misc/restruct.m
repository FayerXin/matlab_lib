function s = restruct(s)
% restruct
% 
% Description:	flip between two ways of storing arrayed data in a struct:
%					1) a struct array / cellnest of structs
%					2) a 1x1 struct of arrays
% 
% Syntax:	s = restruct(s)
% 
% Updated: 2015-03-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

if iscell(s)
	%get the fieldnames
		c	= s;
		while iscell(c)
			assert(~isempty(c),'cellnest elements must be uniform structs.');
			
			c	= c{1};
		end
		
		assert(isstruct(c),'cellnest elements must be uniform structs.');
		
		cField	= fieldnames(c);
	
	%invert the array
		cStruct	= cellfun(@(f) cellnestfun(@(x) x.(f),s),cField,'uni',false);
		s		= cell2struct(cStruct,cField);
else
	%get the field names
		cField	= fieldnames(s);
		nField	= numel(cField);
		
		if nField==0
			return;
		end
		
	%which mode are we in
		if numel(s)==1 && uniform(cellfun(@(f) size(s.(f)),fieldnames(s),'UniformOutput',false))
		%1x1 struct of Nx1 arrays
			sArray	= size(s.(cField{1}));
			nArray	= prod(sArray);
			
			s2	= repmat(struct,sArray);
			
			for kF=1:nField
				if ~iscell(s.(cField{kF}))
					s.(cField{kF})	= num2cell(s.(cField{kF}));
				end
				[s2(1:nArray).(cField{kF})]	= deal(s.(cField{kF}){:});
			end
		else
		%Nx1 struct array
			sArray	= size(s);
			
			for kF=1:nField
				s2.(cField{kF})	= reshape({s.(cField{kF})},sArray);
				
				if all(cellfun(@(x) isscalar(x) && ~ischar(x),s2.(cField{kF})))
					s2.(cField{kF})	= cell2mat(s2.(cField{kF}));
				end
			end
		end
	
	s	= s2;
end
