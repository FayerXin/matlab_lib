function y = weibull(x,varargin)
% weibull
% 
% Description:	Weibull function of the form:
%					W(x) = g+(1-g-lapse)*(1-exp(-(k*(x-xmin)/(t-xmin))^b))
%				where  k = (-log((1-a-lapse)/(1-g-lapse)))^(1/b)
%					t		= the threshold
%					b		= a parameter determining the slope of the curve
%					xmin	= the minimum stimulus value
%					g		= the minimum expected performance
%					a		= the performance at threshold
%					lapse	= the lapse rate
% 
% Syntax:	y = weibull(x,[t]=0.5,[b]=1,[xmin]=0,[g]=0.5,[a]=0.75,[lapse]=0)
% 
% In:
% 	x		- the stimulus value
%	[t]		- the threshold
%	[b]		- a parameter determining the slope of the curve
%	[xmin]	- the minimum stimulus value
%	[g]		- the minimum expected performance
%	[a]		- the performance at threshold
%	[lapse]	- the lapse rate
% 
% Out:
% 	y	- W(x)
% 
% Updated:	2015-12-03
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	%get the input values
		varargin(numel(varargin)+1:6)	= {[]};
		[t,b,xmin,g,a,lapse]			= deal(varargin{1:6});
	%assign defaults to empty inputs
		if isempty(t)
			t	= 0.5;
		end
		if isempty(b)
			b	= 1;
		end
		if isempty(xmin)
			xmin	= 0;
		end
		if isempty(g)
			g	= 0.5;
		end
		if isempty(a)
			a	= 0.75;
		end
		if isempty(lapse)
			lapse	= 0;
		end

k	= (-log((1-a-lapse)./(1-g-lapse))).^(1./b);
y	= g + (1-g-lapse).*(1-exp(-(k.*(x-xmin)./(t-xmin)).^b));
