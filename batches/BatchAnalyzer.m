classdef BatchAnalyzer < matlab.mixin.Copyable
	properties
		Name
		Iters
		Seed
		ClusterFunc
		NumGroups
		Values
		RandomIndices
		Labels
		FixedLabels
		CRI
		NMI
	end
	methods
		function obj = BatchAnalyzer(name, iters, numGroups, values, labels)
			obj.Name = name;
			obj.Iters = iters;
			obj.NumGroups = numGroups;

			setValues(obj, values);

			obj.FixedLabels = (nargin == 5);
			if obj.FixedLabels
				obj.Labels = labels;
			end

			obj.ClusterFunc = @kmeans;
			obj.Seed = 7738;

			obj.CRI = [];
			obj.NMI = [];
		end
		function obj = setValues(obj, values)
			obj.RandomIndices = (numel(values) == 1);
			if ~obj.RandomIndices
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
			rng(obj.Seed); % Ensure all start with the same seed

			addpath lib/rand_index;
			addpath lib/info_entropy;
			for i=1:obj.Iters
				% Create the clustered groups
				if obj.RandomIndices
					idx = randi([1 obj.NumGroups], 1, obj.Values);
					if ~obj.FixedLabels
						obj.Labels = idx;
					end
				else
					idx = obj.ClusterFunc(obj.Values, obj.NumGroups);
					if ~obj.FixedLabels
						obj.Labels = randi([1 obj.NumGroups], 1, length(obj.Values));
					end
				end

				% Calculate and append corrected rand index; 0 indicates no batch effects while 1 is perfect batches.
				obj.CRI = [obj.CRI rand_index(obj.Labels, idx, 'adjusted')];

				% Calculate and append the normalized mutual information; 0 indicates to batch effects while (I think) 1 is perfect batches.
				obj.NMI = [obj.NMI nmi(obj.Labels, idx)];
			end
			rmpath lib/rand_index;
			rmpath lib/info_entropy;
		end
	end
end
