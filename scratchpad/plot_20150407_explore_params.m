% For old plotting scripts, see scratchpad/archived/plotting-scripts/*

% Script to create figures from exploratory data capsules

%
% TODO: Consider restoring automatic date labeling using this construct:
% ['.....' FormatTime(nowms,'yyyymmdd_HHMM') '.....'];

function [hF,hAlex] = plot_20150407_explore_params

hF		= zeros(1,0);
hAlex	= cell(1,0);

load(['../data_store/' '20150403_explore_params' '.mat']);

p				= Pipeline;

%{
fixedPairs		= {	'nRun'		, 5			, ...
					'WSum'		, 0.1		, ...
					'WFullness'	, 0.1		  ...
				  };
ha				= p.renderMultiLinePlot(cCapsule{1},'nTBlock'	, ...
					'lineVarName'			, 'aggTBlock'		, ...
					'lineVarValues'			, {24 48 72 96}		, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{1},'aggTBlock'	, ...
					'lineVarName'			, 'nTBlock'			, ...
					'lineVarValues'			, {1 2 4 6 8}		, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;
%}


% Capsule 1 multiplots

fixedPairs		= {	'WFullness'	, 0.1		  ...
				  };
ha				= p.renderMultiLinePlot(cCapsule{1},'nTBlock'	, ...
					'lineVarName'			, 'aggTBlock'		, ...
					'lineVarValues'			, {24 48 72 96}		, ...
					'horizVarName'			, 'nRun'			, ...
					'horizVarValues'		, {5 20}			, ...
					'vertVarName'			, 'WSum'			, ...
					'vertVarValues'			, {0.1 0.2}			, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{1},'nTBlock'	, ...
					'lineVarName'			, 'nRun'			, ...
					'lineVarValues'			, {5 10 15 20}		, ...
					'horizVarName'			, 'aggTBlock'		, ...
					'horizVarValues'		, {24 72}			, ...
					'vertVarName'			, 'WSum'			, ...
					'vertVarValues'			, {0.1 0.2}			, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{1},'aggTBlock'	, ...
					'lineVarName'			, 'nTBlock'			, ...
					'lineVarValues'			, {1 2 4 6 8}		, ...
					'horizVarName'			, 'nRun'			, ...
					'horizVarValues'		, {5 20}			, ...
					'vertVarName'			, 'WSum'			, ...
					'vertVarValues'			, {0.1 0.2}			, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{1},'aggTBlock'	, ...
					'lineVarName'			, 'nRun'			, ...
					'lineVarValues'			, {5 10 15 20}		, ...
					'horizVarName'			, 'nTBlock'			, ...
					'horizVarValues'		, {1 12}			, ...
					'vertVarName'			, 'WSum'			, ...
					'vertVarValues'			, {0.1 0.2}			, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{1},'nRun'		, ...
					'lineVarName'			, 'nTBlock'			, ...
					'lineVarValues'			, {1 2 4 6 8}		, ...
					'horizVarName'			, 'aggTBlock'		, ...
					'horizVarValues'		, {24 72}			, ...
					'vertVarName'			, 'WSum'			, ...
					'vertVarValues'			, {0.1 0.2}			, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{1},'nRun'		, ...
					'lineVarName'			, 'aggTBlock'		, ...
					'lineVarValues'			, {24 48 72 96}		, ...
					'horizVarName'			, 'nTBlock'			, ...
					'horizVarValues'		, {1 12}			, ...
					'vertVarName'			, 'WSum'			, ...
					'vertVarValues'			, {0.1 0.2}			, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;


% Capsule 2 multiplots

wsums			= 0.1:0.05:0.3;
ha				= p.renderMultiLinePlot(cCapsule{2},'CRecurX'	, ...
					'lineVarName'			, 'WSum'			, ...
					'lineVarValues'			, num2cell(wsums)	, ...
					'horizVarName'			, 'WFullness'		, ...
					'horizVarValues'		, {0.1 0.3}			  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

recurxs			= 0.1:0.2:0.9;
ha				= p.renderMultiLinePlot(cCapsule{2},'WSum'		, ...
					'lineVarName'			, 'CRecurX'			, ...
					'lineVarValues'			, num2cell(recurxs)	, ...
					'horizVarName'			, 'WFullness'		, ...
					'horizVarValues'		, {0.1 0.3}			  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;


% Capsule 3 multiplots

fracs			= 0.1:0.2:0.9;
pcts			= 10:20:90;
pctLabels		= arrayfun(@(pct)sprintf('CRecurY:WSum = %d:%d',pct,100-pct),...
					pcts,'uni',false);

ha				= p.renderMultiLinePlot(cCapsule{3},'NoiseY'	, ...
					'lineVarName'			, '%recur::sum'		, ...
					'lineVarValues'			, num2cell(pcts)	, ...
					'lineLabels'			, pctLabels			, ...
					'horizVarName'			, 'WFullness'		, ...
					'horizVarValues'		, {0.1 0.3}			  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{3},'%recur::sum'	, ...
					'lineVarName'			, 'NoiseY'				, ...
					'lineVarValues'			, num2cell(fracs)		, ...
					'horizVarName'			, 'WFullness'			, ...
					'horizVarValues'		, {0.1 0.3}				  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{3},'CRecurY'	, ...
					'lineVarName'			, '%recur::sum'		, ...
					'lineVarValues'			, num2cell(pcts)	, ...
					'lineLabels'			, pctLabels			, ...
					'horizVarName'			, 'WFullness'		, ...
					'horizVarValues'		, {0.1 0.3}			  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{3},'CRecurY'	, ...
					'lineVarName'			, 'NoiseY'			, ...
					'lineVarValues'			, num2cell(fracs)	, ...
					'horizVarName'			, 'WFullness'		, ...
					'horizVarValues'		, {0.1 0.3}			  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{3},'WSum'		, ...
					'lineVarName'			, '%recur::sum'		, ...
					'lineVarValues'			, num2cell(pcts)	, ...
					'lineLabels'			, pctLabels			, ...
					'horizVarName'			, 'WFullness'		, ...
					'horizVarValues'		, {0.1 0.3}			  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;

ha				= p.renderMultiLinePlot(cCapsule{3},'WSum'		, ...
					'lineVarName'			, 'NoiseY'			, ...
					'lineVarValues'			, num2cell(fracs)	, ...
					'horizVarName'			, 'WFullness'		, ...
					'horizVarValues'		, {0.1 0.3}			  ...
				);
hF(end+1)		= ha.hF;
hAlex{end+1}	= ha;



figfilename	= 'scratchpad/figfiles/20150407_explore_params.fig';
savefig(hF(end:-1:1),figfilename);
fprintf('Plots saved to %s\n',figfilename);

end

