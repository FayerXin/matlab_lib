function [sPoint,pipeline,threshOpt,h,area,color] = ThresholdWeave(varargin)
% ThresholdWeave
%
% Description:	For a range of SNRs and a designated parameter, find
%		least parameter values that bring p-value below a designated
%		threshold (on average)
%
% Syntax:	[sPoint,pipeline,threshOpt,h,area,color] = ThresholdWeave(<options>)
%
% In:
%	<options>:
%		fakedata:	(true) generate fake data (for quick tests)
%		noplot:		(false) suppress plotting
%		yname:		('nSubject') y-axis variable name
%		yvals:		(1:20) y-axis variable values
%		xname:		('SNR') x-axis variable name
%		xstart:		(0.05) lower-bound on x-variable value
%		xstep:		(0.002) x-variable step amount
%		xend:		(0.35) upper-bound on x-variable value
%		nSweep:		(1) number of SNR back-and-forth traversals
%						per independent survey
%		nOuter:		(6) number of independent surveys
%		pThreshold:	(0.05) threshold p-value to be attained
%
% Out:
% 	sPoint		- a struct array of probes (x, y, p, summary)
%	pipeline	- the Pipeline instance created to perform probes
%	threshOpt	- struct of options, including defaults for those
%				  not explicitly specified in arguments
%	h			- handle for generated plot (if any)
%	area		- area data for points in generated plot (if any);
%				  the area of each point represents the log-scale
%				  distance of its p-value from the threshold (see
%				  Notes below)
%	color		- color data for points in generated plot (if any);
%				  see Notes below
%
% Notes:
%	ThresholdWeave searches for (x,y) pairs that yield p-values at or
%	near the designated p-threshold.  It is assumed that p is (on
%	average) monotonically decreasing in x for fixed y, and also
%	monotonically decreasing in y for fixed x.  Thus, if (x,y) pairs
%	are plotted on a standard 2D graph, we postulate that at points
%	(x,y) toward the upper-right-hand portion of the graph, where x
%	and y are both high, the expected p-values should be *less* than
%	the p-threshold, while at points (x,y) toward the lower-left-hand
%	portion of the graph, where x and y are both low, the expected
%	p-values should be *greater* than the p-threshold.  The boundary
%	separating the large-p and small-p regions runs from somewhere
%	toward the upper-left-hand corner of the graph to somewhere toward
%	the lower-right-hand corner.  ThresholdWeave begins its search at
%	the latter corner; that is, the initial x-value is high, and the
%	initial y-value is low.  The code gradually scans ("sweeps")
%	leftward and upward, decreasing x and increasing y, all the while
%	attempting to cleave close to the boundary between the large-p and
%	small-p regions.  When the scan reaches either the left-hand or
%	upper edge of the graph, the code reverses course and scans
%	rightward and downward until it reaches either the right-hand or
%	lower edge of the graph.  The entire back-and-forth sweep is
%	serially repeated nSweep times.  Additionally, the code provides
%	for parallel execution of nOuter series of sweeps, yielding a
%	total of nOuter*nSweep back-and-forth sweeps.
%
%	To steer close to the boundary between the small-p and large-p
%	regions of the graph, the scanning code follows a simple rule:  If
%	the most recent probe point (x,y) yielded a p-value larger than
%	the threshold, then the next probe point is obtained by nudging
%	either x or y upward; whereas if the p-value was smaller than or
%	equal to the threshold, then the next probe point is obtained by
%	nudging either x or y *downward*.  The code thus attempts to weave
%	back and forth across the p-threshold boundary.  Because the
%	probes are highly stochastic, there is no guarantee that
%	successive probes will in fact cross the boundary, but the further
%	the probe points stray from it, the greater the likelihood that
%	the probed p-values will accurately reflect the current region,
%	and so cause the scan to weave back toward the boundary.
%
%	When the scan direction is from lower-right to upper-left, the
%	rule just stated becomes more specific:  If the most recent probe
%	point yielded a p-value larger than the threshold, then y (not x)
%	is nudged upward; otherwise, x (not y) is nudged *downward*.  When
%	the scan direction is from upper-left to lower-right, the rule is
%	specialized in the opposite way:  If the most recent probe point
%	yielded a p-value larger than the threshold, then x (not y) is
%	nudged upward; otherwise, y (not x) is nudged *downward*.
%
%	ThresholdWeave (unlike its predecessor ThresholdSketch) makes a
%	further provision regarding the scan direction.  Scans in a given
%	direction include "micro-stitches" in which the scan direction is
%	temporarily reversed.  For every two steps forward, so to speak, a
%	backward step is inserted.  The intent of these micro-reversals is
%	to prevent the scan from getting locked in ruts parallel to
%	sections of the threshold boundary that are nearly horizontal or
%	nearly vertical.  However, although the micro-reversals are
%	conjectured to be beneficial, their effectiveness has not been
%	established.
%
%	An interesting property of the probe sets generated by the
%	bidirectional scans is the balance between sub-threshold and
%	super-threshold probes.  ThresholdWeave produces scatter plots
%	showing each probe in either blue or red, depending on whether the
%	probe's p-value meets the designated threshold.  (Blue means yes,
%	the p-value is small enough; red means no.)  The numbers of red
%	and blue probes are roughly equal.  Moreover, except at the edges
%	of the graph, for each red probe there must be a corresponding
%	blue probe relatively nearby, and vice versa.  The reason for this
%	correspondence is as follows.  Consider two adjacent x-values xj
%	and xk (with xj < xk).  For some y0, during the scan from the
%	lower-right to the upper-left, the probe point progresses from
%	(xk,y0) to (xj,y0).  This progression can occur only if the
%	p-value at (xk,y0) meets the threshold, so (xk,y0) is colored
%	blue.  Likewise, for some y1, during the scan from the upper-left
%	to the lower-right, the probe point progresses from (xj,y1) to
%	(xk,y1).  This time the progression can occur only if the p-value
%	at (xj,y1) exceeds the threshold, so (xj,y1) is colored red.
%	Inasmuch as xj is close to xk, and both (xk,y0) and (xj,y1) are
%	near the threshold boundary, they must be relatively near to one
%	another.  A similar argument applies to progressions between
%	adjacent y-values, so color-pairings exist for probes followed by
%	vertical steps as well as for those followed by horizontal steps.
%
%	The foregoing paragraph implicitly assumes that there is just
%	*one* progression from xk to xj during a leftward scan, and then
%	just one rightward progression from xj to xk during the reverse
%	scan.  But in the presence of micro-stitches, there could be
%	multiple progressions between these x-values in either direction.
%	Even so, the balance between the red and blue points is preserved.
%	Suppose that the leftward scan starts in the lower-right corner of
%	the graph at (x_initial,y_initial).  For the reverse rightward
%	scan to wind up at that same point, there must necessarily be
%	equal numbers of progressions between xj and xk in either
%	direction.  The leftward and rightward progression counts between
%	xj and xk can differ only if the rightward scan ends at a
%	different point (x_final,y_final) from the initial point
%	(x_initial,y_initial), and if, moreover, xj and xk lie inside the
%	interval spanned by x_initial and x_final.  Again, this argument
%	is symmetric in x and y.  The assertion of the foregoing paragraph
%	that there is a correspondence between the red and blue probes
%	except at the edges of the graph can thus be refined:  The
%	correspondence holds everywhere except in the lower-right portion
%	of the graph between the initial and final points of the sweep.
%	However, in the upper-left portion of the graph, at the lowest
%	x-values and the highest y-values, the probes are typically
%	sparser than elsewhere, making their statistics less robust,
%	despite the preservation of balance between red and blue probes.
%
%	When the matter is viewed in the abstract, there is no reason why
%	the bidirectional scans should start and end in the lower-right
%	corner of the graph.  They could equally well start in the
%	upper-left, sweep rightward and downward to the lower-right, and
%	then sweep back to the upper-left again.  However, two
%	considerations weigh in favor of starting in the lower-right when
%	the x-axis represents SNR, as it does by default, and when the
%	y-axis represents parameters such as nSubject, nRun, nTBlock, and
%	so on.  First, with these variable assignments, the cost of a
%	probe increases as y increases, so it makes sense to begin with
%	low-cost probes and to increase y only as necessary to keep the
%	p-values hovering near the threshold.  Second, for low values of
%	SNR, the y-values at the p-threshold boundary tend to exceed the y
%	range of interest.  By letting the scans start at the lower-right
%	and climb upward and leftward until y goes out of bounds, we
%	automatically discover the minimum viable SNR value (to a close
%	approximation).  We avoid generating probe points whose x-value is
%	beneath that minimum, which in turn makes for cleaner diagnostic
%	plots than would obtain otherwise.
%
%	The end goal of the computations performed by ThresholdWeave is to
%	determine, for each x, the corresponding threshold y-value:  that
%	is, the y-value at which, on average, p(x,y) crosses the
%	designated p-threshold.  ThresholdWeave does not attempt to make
%	that determination.  It is instead left to the plotting script
%	s20150718_plot_thresholds to interpret the raw data generated by
%	ThresholdWeave and to present that data as a 2D line plot showing
%	threshold y-values as a function of x.  The plotting script
%	implements several strategies for estimating the threshold
%	y-values, and (by default) draws multiple plot lines corresponding
%	to the multiple strategies.  In recent runs, the different
%	strategies substantially agree on the y-thresholds, but disagree
%	on the confidence intervals (i.e., the error bars).  Some of the
%	strategies fail to yield y-threshold estimates for all x-values of
%	interest.
%
%	All but one of the strategies use curve-fitting in one way or
%	another.  Its use is motivated by the stochastic nature of p(x,y).
%	Because of the high cost of each probe, for a given (x,y) pair
%	ThresholdWeave might provide only a handful of samples of p(x,y).
%	From these samples the plotting code must infer a representative
%	value of p(x,y).  A logical choice for this representative would
%	be the median or mode of the distribution of p(x,y), or possibly
%	its mean, but none of these properties of the distribution can be
%	estimated accurately from a small set of samples.  Curve-fitting
%	allows the samples of p(x0,y) for multiple values of y at x=x0 to
%	be examined all at once, smoothing out the variability that would
%	arise from estimating a representative p(x0,y) for each y
%	individually.  A side benefit of curve-fitting, given that the
%	y-domain is typically discrete, is that the y-threshold estimates
%	computed through the fitted curves are interpolations.  Thus, y
%	behaves like a continuous variable on the resultant plots, and the
%	slopes of the plot lines also vary by fine degrees, as if they
%	were continuous.
%
%	The one strategy that does *not* use curve-fitting, the "meany"
%	strategy (added in late July, 2015), estimates the threshold
%	y-value at x=x0 by simply taking the mean of the y-values for all
%	probe points (x0,y).  Because of the balance between red and blue
%	probes, noted previously, the y-threshold estimates obtained in
%	this manner tend to lie near the boundary separating the regions
%	of the graph where the p-values are predominantly below and
%	predominantly above the p-threshold, respectively.
%
%	Here is a brief description of each strategy.
%
%		Fit G(y) to log p [for some linear function G]
%
%			At each x0, the algorithm collects the probes p(x0,y) for
%			all y, and builds a list of pairs (y, log p).  A line
%
%				log p = G(y) = m*y + b
%
%			is fitted to this list of pairs, using a least-squares fit
%			to find the best choices of m and b, and then the line
%			equation is solved with p = p_threshold to obtain y =
%			y_threshold at x0.
%
%			This strategy assumes a roughly linear relationship
%			between y and the mean of log p in the region of interest.
%
%		Fit F(log p) to y [for some linear function F]
%
%			At each x0, the algorithm collects the probes p(x0,y) for
%			all y, and builds a list of pairs (log p, y).  A line
%
%				y = F(log p) = m*(log p) + b
%
%			is fitted to this list of pairs, using a least-squares fit
%			to find the best choices of m and b, and then y_threshold
%			at x0 is computed as
%
%				y_threshold = m*(log p_threshold) + b.
%
%			This strategy assumes a roughly linear relationship
%			between y and the mean of log p in the region of interest.
%
%		Fit g(y) to log p(mean t) [for some linear function g]
%
%			This strategy makes use of the fact that along with each
%			probe value p(x,y), ThresholdWeave also provides the
%			t-test results that gave rise to the provided p-value.
%
%			With x0 fixed, at each yi the algorithm collects the
%			t-statistics for all probes at (x0,yi) and computes their
%			mean, which we denote "mean t(x0,yi)."  Then, still
%			holding x0 fixed but ranging across all values of yi, it
%			builds a multiset of pairs (yi, log p(mean t(x0,yi))),
%			where p is computed from the mean of the t-statistics as
%			if the mean were itself a t-statistic.  A given multiset
%			element derived from k probes at (x0,yi) is replicated k
%			times, thus weighting the influence of the elements by the
%			sampling frequencies of the different values of yi.  A
%			consequence of this replication is that the multiset's
%			cardinality is equal to the total number of probes at x0.
%			A line
%
%				log p(mean t(x0,y)) = g(y) = m*y + b
%
%			is fitted to this multiset of pairs, using a least-squares
%			fit to find the best choices of m and b, and then the line
%			equation is solved with p = p_threshold to obtain y =
%			y_threshold at x0.
%
%			This strategy assumes a roughly linear relationship
%			between the y-values and the computed p-values in the
%			region of interest.  Additionally, it treats the means of
%			the t-statistics as point values and disregards the
%			variances of those t-statistics.  The confidence intervals
%			associated with the curve-fitting may therefore understate
%			the actual uncertainty of the computed y-thresholds.
%
%		Fit f(log p(mean t)) to y [for some linear function f]
%
%			In the same way that the strategy "Fit F(log p) to y" is
%			complementary to "Fit G(y) to log p", the present
%			strategy, "Fit f(log p(mean t)) to y" is complementary to
%			the preceding one, "Fit g(y) to log p(mean t)".
%
%			Similarly to the preceding strategy, this one builds, for
%			each x0, a multiset of pairs (log p(mean t(x0,yi)), yi).
%			A line
%
%				y = f(log p) = m*(log p) + b
%
%			is fitted to this multiset of pairs, using a least-squares
%			fit to find the best choices of m and b, and then
%			y_threshold at x0 is computed as
%
%				y_threshold = m*(log p_threshold) + b.
%
%			This strategy makes the same assumptions as the preceding
%			one.
%
%		Fit H(Pr{p <= p_threshold}) to y [for some linear function H,
%			where Pr{A} means probability (or frequency) of A]
%
%			With x0 fixed, at each yi the algorithm collects the probe
%			values p(x0,yi) and computes the percentage of them that
%			satisfy the p-threshold.  Then, still holding x0 fixed but
%			ranging across all values of yi, it builds a multiset of
%			pairs (percentage, yi).  A given multiset element derived
%			from k probes at (x0,yi) is replicated k times (see also
%			the description of strategy "Fit g(y) to log p(mean t)",
%			which replicates multiset elements in the same way).  A
%			line
%
%				y = H(percentage) = m*percentage + b
%
%			is fitted to this multiset of pairs, using a least-squares
%			fit to find the best choices of m and b, and then
%			y_threshold at x0 is computed as
%
%				y_threshold = m*50 + b.
%
%			The computed y_threshold thus represents the value of y at
%			which 50% of the probes can be expected to satisfy the
%			p-threshold.  This strategy differs from the preceding
%			ones in that it estimates the y-value at which the
%			*median* of the p-values crosses the p-threshold.  That
%			y-value is, equivalently, the y-value at which the median
%			of the *logs* of the p-values crosses the *log* of the
%			p-threshold.  By contrast, the preceding strategies
%			estimate the y-value at which the *mean* of the logs of
%			the p-values crosses the log of the p-threshold.  (The
%			latter is *not* equivalent to the y-value at which the
%			mean of the p-values crosses the p-threshold.)
%
%			The present strategy assumes a roughly linear relationship
%			between y and the percentage of probes that satisfy the
%			p-threshold in the region of interest.
%
%		Meany
%
%			For each x0, the algorithm computes the mean of y for all
%			probes with x=x0.  If a given point (x0,yi) was probed k
%			times, then the mean incorporates k copies of yi.
%
%			Although this strategy computes the *mean* of probes'
%			y-values, what it thereby estimates is the y-value at
%			which the *median* of the p-values crosses the
%			p-threshold.  With x0 fixed, consider the function
%
%				C(y) = Pr{p(x0,y) <= p_threshold}.
%
%			By assumption, p(x0,y) is monotonically decreasing in y,
%			hence C(y) is monotonically increasing in y.  Moreover,
%			C(-Inf) = 0 and C(Inf) = 1, so C may be regarded as a
%			cumulative distribution function (CDF).  ThresholdWeave's
%			steps along the y-axis amount to a weighted random walk,
%			where the weighting is determined by C.  At each step, y
%			tends to increase when C(y) < 0.5, and tends to decrease
%			when C(y) > 0.5.  The further C(y) veers from 0.5, the
%			greater the pressure on y to return toward the point where
%			C(y) is closest to 0.5, that is, toward the median of C.
%			But the median of C is also the y-value at which the
%			median of p is equal to p_threshold.  (If D denotes the
%			CDF of p at (x0,y0), then C(y0) = D(p_threshold), so if
%			C(y0) = 0.5 then D(p_threshold) = 0.5 as well.)
%
%			Let c = C' be the probability density function (pdf)
%			corresponding to C.  If c is symmetric, then the weighted
%			random walk described above steps through a sequence of
%			y-values whose mean tends toward the median of C.
%			However, asymmetry in c may lead to bias.  Another
%			possible source of inaccuracy arises from the nature of
%			the balance between the red and blue probes.  For a fixed
%			x0, the balance may be inexact; for example, the blue
%			probe corresponding to a given red probe at x0 may lie
%			along a neighbor of x0 and not along x0 itself.  This last
%			source of inaccuracy can be mitigated by smoothing the
%			estimated y-thresholds through the use of moving averages
%			along the x-axis.
%
%	The first four strategies above make use of the p-values (or
%	t-statistics) from each probe; the fifth makes only a coarse
%	distinction between p-values that are above the p-threshold or
%	below it; and the sixth makes no use of the p-values at all.
%	Inasmuch as the last two strategies are discarding information,
%	one might expect them to yield inferior accuracy.  Empirically,
%	however, their accuracy does not appear to suffer.  It may be that
%	because of each p-value's role in determining future probe-point
%	coordinates, the coordinate values wind up implicitly revealing
%	enough about the p-values that the information conveyed by the
%	p-values themselves is largely redundant.
%
%	As noted, all but the last of the six strategies use curve-fitting
%	to estimate the y-threshold.  In cases where the probes at a given
%	x0 are too irregular to yield an accurate fit, the computed
%	estimate may be spurious.  There is no sure-fire way to detect all
%	ill-founded estimates, but it is possible to detect and suppress
%	some categories of implausible outliers.  By default, the plotting
%	script's 'clip' option discards y-threshold estimates that are
%	below the 20th percentile or above the 80th percentile among the
%	probe points' y-values.  For the first four strategies, an
%	estimate is also discarded if the p-threshold lies below the 20th
%	percentile or above the 80th percentile among the probe points'
%	p-values.  For the fifth strategy, an estimate is also discarded
%	if fewer than 20% of the probes are at values yi that tend to
%	satisfy the p-threshold (meaning that a probe at (x0,yi) satisfies
%	the p-threshold more often than not), or if fewer than 20% are at
%	values yi that tend *not* to satisfy the p-threshold.
%
%	Finally, for all strategies, if fewer than five points are
%	available for curve-fitting or for computing the mean y-value, the
%	y-threshold estimate at x0 is summarily discarded.  (These
%	policies are configurable through the clipping options.)
%
%	The y-threshold estimates are plotted with error bars.  For the
%	estimates obtained through curve-fitting, the error bars represent
%	50% confidence intervals supplied by MATLAB's polyval function.
%	The polyval function assumes that the errors in the curve-fitting
%	inputs are normally distributed, but this assumption is not
%	necessarily warranted for the inputs provided by the plotting
%	script's curve-fitting strategies.  For this reason, and because
%	of the possibly invalid assumptions noted above in connection with
%	each individual strategy, the reliability of the polyval-based
%	confidence intervals is uncertain.  The error bars for the "meany"
%	strategy represent the standard error of the input, and as such,
%	nominally depict 68% confidence intervals; however, like the
%	others, this strategy makes assumptions that do not necessarily
%	hold, with implications for accuracy that are tricky to quantify.
%
%	The "meany" strategy was added after the others, so the plots of
%	ThresholdWeave data initially added to the "figfiles" directory
%	show results only for the curve-fitting strategies:
%
%	  20150718_222503_s20150718_thresholds-multifit+test_snr-ta0.2-erT-0721.fig
%	  20150718_222503_s20150718_thresholds-multifit-ta0.2-erT-li13-0721.fig
%	  20150718_222503_s20150718_thresholds-multifit-ta0.2-erT-mvx5-0722.fig
%	  20150718_222503_s20150718_thresholds-multifit-ta0.2-erT-mvx5-li13-0722.fig
%
%	The first of these ".fig" files (with "multifit+test_snr" in its
%	name) includes scatter plots that give a picture of the raw data
%	generated by ThresholdWeave.  It also includes line plots for all
%	the curve-fitting strategies, but the lines for two of the
%	strategies--those based on t-statistics--are difficult to see, so
%	the second ".fig" file shows the lines for those two strategies by
%	themselves.  The third and fourth ".fig" files show plots in which
%	moving averages have been applied along the x-axis in a basically
%	failed bid to obtain cleaner-looking results.
%
%	Two sets of figures added to the "figfiles" directory on July 28,
%	2015, illustrate the results obtained with "meany":
%
%	  20150718_222503_s20150718_thresholds-multifit-ta0.2-erT-mny5-0728.fig
%	  20150718_222503_s20150718_thresholds-multifit-ta0.2-erT-mny5-mvx5-li5-0728.fig
%
%	(These files were created through the invocations
%
%	  s20150718_plot_thresholds('meanyline',5,'saveplot',true);
%	  s20150718_plot_thresholds('meanyline',5,'plotlines',5,'movavgx',5,'saveplot',true);
%
%	of the plotting script.)
%
%	From the first of these added files (*-mny5-0728.fig), it can be
%	seen that "meany" gives similar estimates to the other strategies.
%	The second (*-mny5-mvx5-li5-0728.fig) shows the "meany" estimates
%	by themselves, smoothed through the use of moving averages along
%	the x-axis.
%
%	See also ThresholdSketch.m, ThresholdProbe.m, s20150718_plot_thresholds.m
%
% Example:
%	ThresholdWeave;
%	ThresholdWeave('yname','nRun','seed',3);
%	ThresholdWeave('yname','WStrength','yvals',linspace(0.2,0.8,21),'seed',3);
%	sPoint=ThresholdWeave('noplot',true);
%
% Updated: 2015-09-27
% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.
% This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

%---------------------------------------------------------------------
% TODO: More comments
%---------------------------------------------------------------------

	threshOpt	= ParseArgs(varargin, ...
					'fakedata'			, true				, ...
					'noplot'			, false				, ...
					'yname'				, 'nSubject'		, ...
					'yvals'				, 1:20				, ...
					'xname'				, 'SNR'				, ...
					'xstart'			, 0.05				, ...
					'xstep'				, 0.002				, ...
					'xend'				, 0.35				, ...
					'nSweep'			, 1					, ...
					'nOuter'			, 6					, ...
					'pThreshold'		, 0.05				  ...
					);
	extraargs	= opt2cell(threshOpt.opt_extra);
	obj			= Pipeline(extraargs{:});
	obj			= obj.changeDefaultsForBatchProcessing;
	obj			= obj.changeOptionDefault('analysis','alex');
	obj			= obj.consumeRandomizationSeed;
	pipeline	= obj;

	% Assume p declines with increasing x or increasing y
	% Assume probe cost depends more on y than on x

	xvar.name	= threshOpt.xname;
	xvar.vals	= threshOpt.xstart:threshOpt.xstep:threshOpt.xend;
	yvar.name	= threshOpt.yname;
	yvar.vals	= threshOpt.yvals;

	nTask		= threshOpt.nOuter;
	cSeed		= num2cell(randperm(intmax('uint32'),nTask));
	rngState	= rng;
	reparg		= @(a) repmat({a},1,nTask);
	taskarg		= {reparg(obj),cSeed,reparg(xvar),reparg(yvar),reparg(threshOpt)};
	cPoint		= MultiTask(@thresholdSurvey, taskarg	, ...
					'njobmax'				, obj.uopt.njobmax			, ...
					'cores'					, obj.uopt.max_cores		, ...
					'debug'					, obj.uopt.MT_debug			, ...
					'debug_communicator'	, obj.uopt.MT_debug_comm	, ...
					'silent'				, (obj.uopt.max_cores<2)	  ...
					);
	rng(rngState);
	sPoint		= cat(2,cPoint{:});

	if ~threshOpt.noplot && feature('ShowFigureWindows')
		[h,area,color]	= plot_points(sPoint,threshOpt.pThreshold,xvar.name,yvar.name);
	else
		[h,area,color]	= deal([]);
	end
end

function sPoint = thresholdSurvey(obj,seed,xvar,yvar,tOpt)
	assert(isnumeric(seed),'Bug: bad seed');
	%fprintf('seed is %d\n',seed);
	obj		= obj.setopt('seed',seed);
	obj		= obj.consumeRandomizationSeed;

	sPoint	= [];

	for k=1:tOpt.nSweep
		sPointNew	= thresholdSweep(obj,xvar,yvar,tOpt);
		sPoint		= [sPoint sPointNew]; %#ok
	end
end

function sPoint = thresholdSweep(obj,xvar,yvar,tOpt)
	nx	= numel(xvar.vals);
	ny	= numel(yvar.vals);

	microStitch	= [false true false];
	nMicro		= numel(microStitch);
	zpt			= struct('x',0,'y',0,'p',0,'summary',struct);
	sPoint		= repmat(zpt,1,2*nMicro*(nx+ny));
	nPoint		= 0;

	kx	= nx;
	ky	= 1;
	for retrace=0:1 % i.e., retrace=false, then retrace=true
		microIndex		= 1;
		while conditional(~retrace, ...
				kx >= 1  && ky <= ny	, ... % right-left, bottom-top
				kx <= nx && ky >= 1		  ... % left-right, top-bottom
				)
			kx	= max(1,min(kx,nx));
			ky	= max(1,min(ky,ny));
			%fprintf('[%d] ',kx+ny-ky);

			pt.x				= xvar.vals(kx);
			pt.y				= yvar.vals(ky);

			obj					= obj.setopt(xvar.name,pt.x);
			obj					= obj.setopt(yvar.name,pt.y);
			if tOpt.fakedata
				summary			= fakeSimulateAllSubjects(obj);
			else
				summary			= simulateAllSubjects(obj);
			end

			pt.p				= summary.alex.p;
			pt.summary			= summary;
			nPoint				= nPoint+1;
			sPoint(nPoint)		= pt;

			meetsThreshold		= pt.p <= tOpt.pThreshold;
			step				= conditional(meetsThreshold,-1,+1);
			microRetrace		= xor(retrace,microStitch(microIndex));
			if meetsThreshold ~= microRetrace
				kx	= kx + step;
			else
				ky	= ky + step;
			end
			microIndex			= 1+mod(microIndex,nMicro);
		end
	end

	sPoint	= sPoint(1:nPoint);
end

function [h,area,color] = plot_points(sPoint,pThreshold,xname,yname)
	ratio		= max(1e-6,min([sPoint.p]./pThreshold,1e6));
	area		= 30+abs(60*log(ratio));
	leThreshold	= [sPoint.p] <= pThreshold;
	blue		= leThreshold.';
	red			= ~blue;
	green		= zeros(size(red));
	color		= [red green blue];
	h			= figure;
	scatter([sPoint.x],[sPoint.y],area,color);
	xlabel(xname);
	ylabel(yname);
end

function summary = fakeSimulateAllSubjects(obj)
	obj		= obj.consumeRandomizationSeed;
	% values synthesized here are not intended to be realistic, but
	% merely to create curve shapes that are useful for testing
	snr		= obj.uopt.SNR;
	nsubj	= obj.uopt.nSubject;	% default=15
	y1		= obj.uopt.nTBlock;		% default=10
	y2		= obj.uopt.nRepBlock;	% default=5
	y3		= obj.uopt.nRun;		% default=15
	y4		= obj.uopt.WStrength;	% default=0.5
	scale	= 0.25*atan((y1-0.5)*y2*sqrt(y3)/120);
	snoise	= 0.05/y4;
	bias	= (1 + snoise*randn(nsubj,1))*scale;
	acc		= 0.5 + (snr*bias + snoise*randn(size(bias)))/(snr+1);

	%summary.bias	= bias;
	%summary.acc		= acc;

	[h,p_grouplevel,ci,stats]	= ttest(acc,0.5,'tail','right');
	summary.alex.meanAccAllSubj	= mean(acc);
	summary.alex.stderrAccAllSu	= stderr(acc);
	summary.alex.h				= h;
	summary.alex.p				= p_grouplevel;
	summary.alex.ci				= ci;
	summary.alex.stats			= stats;
end
