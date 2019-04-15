classdef BatchAnalyzer < matlab.mixin.Copyable
	properties
		Name
		Iters
		BaselineIters
		Seed
		ClusterFunc
		NumGroups
		Values
		ZMUVValues
		SampleFraction
		Labels
		Score
		Score_mean
		Score_std
		AllBaselineScores
		BaselineScore
		BaselineScore_mean
		BaselineScore_std
		ScoreDiff
		ScoreDiff_mean
		ScoreDiff_std
		PValue
	end
	methods
		function obj = BatchAnalyzer(name, numGroups, values, varargin)
			p = inputParser;
			addRequired(p, 'name', @(x) isstring(x) || ischar(x));
			addRequired(p, 'numGroups', @isnumeric);
			addOptional(p, 'values', @ismatrix);
			addOptional(p, 'labels', [], @(x) isinteger(x) || isnumeric(x));
			addParameter(p, 'iters', 30, @isnumeric);
			addParameter(p, 'baselineIters', 100, @isnumeric);
			addParameter(p, 'sampleFraction', 0.8, @isnumeric);
			addParameter(p, 'clusterFunc', @linkageCluster);
			addParameter(p, 'seed', 7738, @isnumeric);
			parse(p, name, numGroups, values, varargin{:});

			obj.NumGroups = p.Results.numGroups;
			setValues(obj, p.Results.values);
			obj.Labels = p.Results.labels;

			obj.Name = p.Results.name;
			obj.Iters = p.Results.iters;

			obj.ClusterFunc = p.Results.clusterFunc;
			obj.Seed = p.Results.seed;

			obj.SampleFraction = p.Results.sampleFraction;
			obj.BaselineIters = p.Results.baselineIters;
		end
		function obj = setValues(obj, values)
			obj.Values = values;

			% Zero mean unit variance
			obj.ZMUVValues = bsxfun(@rdivide, values - mean(values), std(values));

			% Clear array values
			obj.Score = [];
			obj.ScoreDiff = [];
			obj.BaselineScore = [];
			obj.AllBaselineScores = [];

			obj.PValue = 0; % Initialize to impossible 0.
		end
		function ba = BACopyWithValues(obj, name, values)
			ba = copy(obj);
			ba.Name = name;
			setValues(ba, values);
		end
		function calculateBatch(obj)
			if obj.Seed ~= 0
				rng(obj.Seed); % Ensure all start with the same seed
			end

			% Clear old array values
			obj.Score = [];
			obj.AllBaselineScores = zeros(obj.Iters, obj.BaselineIters);

			addpath lib/rand_index;
			addpath lib/info_entropy;
			addpath lib;
			for i=1:obj.Iters
				numValues = size(obj.Values, 1);

				if obj.SampleFraction < 1
					len = round(obj.SampleFraction * numValues);
					indices = randi(numValues, 1, len); % Sample with replacement
				else
					indices = 1:size(obj.Values, 1);
				end

				% Create the clustered groups
				idx = obj.ClusterFunc(obj.ZMUVValues(indices, :), obj.NumGroups);
				thisIterLabels = obj.Labels(indices);

				% Calculate and append the batch effect score.
				obj.Score = [obj.Score voi(thisIterLabels, idx)];

				% Calculate a lot of different possible scores that could come from the same group sizes.
				for j=1:obj.BaselineIters
					shuffled = idx(randperm(length(idx)));
					obj.AllBaselineScores(i, j) = voi(thisIterLabels, shuffled);
				end
			end
			rmpath lib/rand_index;
			rmpath lib/info_entropy;
			rmpath lib;

			obj.Score_mean = mean(obj.Score);
			obj.Score_std = std(obj.Score);

			obj.BaselineScore = mean(obj.AllBaselineScores, 2)'; % The mean for each iteration.
			obj.BaselineScore_mean = mean(obj.AllBaselineScores(:));
			obj.BaselineScore_std = std(obj.AllBaselineScores(:));

			obj.ScoreDiff = (obj.BaselineScore - obj.Score)/2/log2(obj.NumGroups);
			obj.ScoreDiff_mean = mean(obj.ScoreDiff);
			obj.ScoreDiff_std = std(obj.ScoreDiff);  % TODO This isn't making use of the variance in obj.BaselineScore_std

			[~, obj.PValue] = ttest2(obj.Score, obj.BaselineScore);
		end
		function str = BAString(obj, padLen)
			if nargin < 2
				padLen = 0;
			end

			if obj.PValue < 0.001
				pStr = sprintf('%.0e', obj.PValue);
			else
				pStr = sprintf('%.4f', obj.PValue);
			end

			formatStr = '%s , % .3f , %.3f , % .3f , %.3f , %3.0f%%  , %s ';
			str = sprintf(formatStr, pad(obj.Name, padLen), obj.Score_mean, obj.Score_std, obj.BaselineScore_mean, obj.BaselineScore_std, obj.ScoreDiff_mean*100, pStr);
		end
	end
end
