classdef BatchAnalyzer < matlab.mixin.Copyable
	properties
		Name
		Iters
		Seed
		ClusterFunc
		NumGroups
		Values
		UseRandomIndices
		SampleFraction
		Labels
		FixedLabels
		CRI
		CRI_mean
		CRI_std
		NMI
		NMI_mean
		NMI_std
		HEL
		HEL_mean
		HEL_std
	end
	methods
		function obj = BatchAnalyzer(name, numGroups, values, varargin)
			p = inputParser;
			addRequired(p, 'name', @(x) isstring(x) || ischar(x));
			addRequired(p, 'numGroups', @isnumeric);
			addRequired(p, 'values', @ismatrix);
			addOptional(p, 'labels', [], @(x) isinteger(x) || isnumeric(x));
			addParameter(p, 'iters', 30, @isnumeric);
			addParameter(p, 'sampleFraction', 1, @isnumeric);
			addParameter(p, 'clusterFunc', @linkageCluster);
			addParameter(p, 'seed', 7738, @isnumeric);
			parse(p, name, numGroups, values, varargin{:});

			obj.Name = p.Results.name;
			obj.Iters = p.Results.iters;
			obj.NumGroups = p.Results.numGroups;

			setValues(obj, p.Results.values);

			obj.Labels = p.Results.labels;
			obj.FixedLabels = (length(obj.Labels) > 0);

			obj.ClusterFunc = p.Results.clusterFunc;
			obj.Seed = p.Results.seed;

			obj.CRI = [];
			obj.NMI = [];
			obj.HEL = [];

			obj.SampleFraction = p.Results.sampleFraction;
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
				len = size(obj.Values, 1);
				if obj.SampleFraction < 1
					len = round(obj.SampleFraction * len);
					indices = randi(size(obj.Values, 1), 1, len); % Sample with replacement
					thisIterVals = obj.Values(indices, :);
					if obj.FixedLabels
						thisIterLabels = obj.Labels(indices);
					end
				end

				% Create the clustered groups
				if obj.UseRandomIndices
					idx = randi([1 obj.NumGroups], 1, len);
					if ~obj.FixedLabels
						thisIterLabels = idx;
					end
				else
					idx = obj.ClusterFunc(thisIterVals, obj.NumGroups);
					if ~obj.FixedLabels
						thisIterLabels = randi([1 obj.NumGroups], 1, len);
					end
				end

				obj.HEL = [obj.HEL hell(obj, thisIterVals, thisIterLabels)];

				% Calculate and append corrected rand index; 0 indicates no batch effects while 1 is perfect batches.
				obj.CRI = [obj.CRI rand_index(thisIterLabels, idx, 'adjusted')];

				% Calculate and append the normalized mutual information; 0 indicates to batch effects while (I think) 1 is perfect batches.
				obj.NMI = [obj.NMI nmi(thisIterLabels, idx)];

			end
			rmpath lib/rand_index;
			rmpath lib/info_entropy;
			rmpath lib;

			obj.HEL_mean = mean(obj.HEL);
			obj.HEL_std = std(obj.HEL);
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
				formatStr = '%s , % .3f , %.3f , % .3f , %.3f , % .3f , %.3f ';
			else
				formatStr = '%s | % .3f (%.3f) | % .3f (%.3f) | % .3f (%.3f) ';
			end

			str = sprintf(formatStr, pad(obj.Name, padLen), obj.HEL_mean, obj.HEL_std, obj.CRI_mean, obj.CRI_std, obj.NMI_mean, obj.NMI_std);
		end
		function hd = hell(obj, vals, labels)
			if obj.UseRandomIndices || ~obj.FixedLabels
				hd = 0;
				return;
			end
			labelList = unique(labels);
			numLabels = length(labelList);

			x = vals(labels == labelList(1), :);
			if numLabels > 1
				y = vals(labels == labelList(2), :);
				if numLabels > 2
					z = vals(labels == labelList(3), :);
					if numLabels > 3
						warning("HELL is only valid for up to 3 labels");
					else
						hd = hellingerFromMatrixSimple(x, y, z);
					end
				else
					hd = hellingerFromMatrixSimple(x, y);
				end
			else
				warning("HELL doesn't make sense for just 1 label");
			end
		end
	end
end
