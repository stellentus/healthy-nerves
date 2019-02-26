classdef BatchAnalyzer < matlab.mixin.Copyable
	properties
		Name
		Iters
		Seed
		ClusterFunc
		NumGroups
		Values
		ValueIndices
		UseValueIndices
		UseRandomIndices
		Labels
		FixedLabels
		CRI
		CRI_mean
		CRI_std
		NMI
		NMI_mean
		NMI_std
	end
	methods
		function obj = BatchAnalyzer(name, numGroups, values, varargin)
			p = inputParser;
			addRequired(p, 'name', @(x) isstring(x) || ischar(x));
			addRequired(p, 'numGroups', @isnumeric);
			addRequired(p, 'values', @ismatrix);
			addOptional(p, 'labels', [], @(x) isinteger(x) || isnumeric(x));
			addParameter(p, 'indices', {}, @(x) iscell(x) && isnumeric(x{1}) && length(x{1}) > 1); % Test that this is a cell array with numeric elements with a length of at least 1
			addParameter(p, 'iters', 30, @isnumeric);
			addParameter(p, 'clusterFunc', @fkmeans);
			addParameter(p, 'seed', 7738, @isnumeric);
			parse(p, name, numGroups, values, varargin{:});

			obj.Name = p.Results.name;
			obj.Iters = p.Results.iters;
			obj.NumGroups = p.Results.numGroups;

			obj.Indices = p.Results.indices;
			indLen = length(obj.Indices);
			if indLen > 0
				obj.UseValueIndices = true;
				if indLen ~= p.Results.iters
					error(sprintf("Indices should be length %d, not whatever we got", p.Results.iters, obj.Indices));
					return;
				end
				for i = 1:indLen
					if ~(isnumeric(obj.Indices{i}) && length(obj.Indices{i}) > 1)
						error(sprintf("The indices at %d have a length of %d", i, length(obj.Indices{i}));
						return;
					end
				end
			else
				obj.UseValueIndices = false;
			end

			setValues(obj, p.Results.values);

			obj.Labels = p.Results.labels;
			obj.FixedLabels = (length(obj.Labels) > 0);

			obj.ClusterFunc = p.Results.clusterFunc;
			obj.Seed = p.Results.seed;

			obj.CRI = [];
			obj.NMI = [];
		end
		function obj = setValues(obj, values)
			obj.UseRandomIndices = (numel(values) == 1);
			if ~obj.UseRandomIndices
				% Zero mean unit variance
				obj.Values = bsxfun(@rdivide, values - mean(values), std(values));
			else
				obj.Values = values;
			end
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

			thisIterVals = obj.Values;
			thisIterLabels = obj.Labels;

			addpath lib/rand_index;
			addpath lib/info_entropy;
			addpath lib;
			for i=1:obj.Iters
				if obj.UseValueIndices
					thisIterVals = obj.Values(obj.ValueIndices{i}, :);
					thisIterLabels = obj.Labels(obj.ValueIndices{i});
				end

				% Create the clustered groups
				if obj.UseRandomIndices
					idx = randi([1 obj.NumGroups], 1, thisIterVals);
					if ~obj.FixedLabels
						thisIterLabels = idx;
					end
				else
					idx = obj.ClusterFunc(thisIterVals, obj.NumGroups);
					if ~obj.FixedLabels
						thisIterLabels = randi([1 obj.NumGroups], 1, length(thisIterVals));
					end
				end

				% Calculate and append corrected rand index; 0 indicates no batch effects while 1 is perfect batches.
				obj.CRI = [obj.CRI rand_index(thisIterLabels, idx, 'adjusted')];

				% Calculate and append the normalized mutual information; 0 indicates to batch effects while (I think) 1 is perfect batches.
				obj.NMI = [obj.NMI nmi(obj.Labels, idx)];
			end
			rmpath lib/rand_index;
			rmpath lib/info_entropy;
			rmpath lib;

			obj.CRI_mean = mean(obj.CRI);
			obj.CRI_std = std(obj.CRI);
			obj.NMI_mean = mean(obj.NMI);
			obj.NMI_std = std(obj.NMI);
		end
		function str = BAString(obj, padLen, asCSV)
			if nargin < 3
				asCSV = false
				if nargin < 2
					padLen = 0;
				end
			end

			if asCSV
				formatStr = '%s , % .3f , %.3f , % .3f , %.3f ';
			else
				formatStr = '%s | % .3f (%.3f) | % .3f (%.3f) ';
			end

			str = sprintf(formatStr, pad(obj.Name, padLen), obj.CRI_mean, obj.CRI_std, obj.NMI_mean, obj.NMI_std);
		end
	end
end
