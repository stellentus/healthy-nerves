clf;

% Generate random Gaussian target data
mu = [2 3];
sigma = [1 1.5; 1.5 3];
R = mvnrnd(mu, sigma, 100000);

% Relabel data for dd_tools
label = repmat(1, size(R, 1), 1);
a = prdataset(R, label);

x = target_class(a, '1');  % x is all input inliers
w = gauss_dd(x, 0.01);

% Plot the data
plot(x.data(:, 1), x.data(:, 2), '.', 'MarkerSize', 1);
xlim([-3 7]);
ylim([-5 11]);
plotc(w);  % Plot the border of the inlier zone

% Generate and plot test points
outls = [2, 3; 1, 0; 4, 5; 1, 2; -1, -2; 6, 11];
hold on;
plot(outls(:, 1), outls(:, 2), 'r*');

% Score outliers to see if they're inliers
outlScore = +(outls*w)
% The first column is a score for each outlier. The second column is the cutoff for each point.
% Scores below the cutoff indicate inliers. For Gaussian and MOG, the cutoff is constant.
