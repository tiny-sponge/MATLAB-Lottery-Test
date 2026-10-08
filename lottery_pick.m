function index = lottery_pick(weights, u)
%LOTTERY_PICK Select a prize using nonnegative relative weights.
validateattributes(weights, {'numeric'}, {'vector','real','finite','nonnegative','nonempty'});
weights = double(weights(:));
if ~any(weights > 0)
    error('lottery:ZeroWeights', '至少一个奖项的权重必须大于零。');
end
if nargin < 2
    u = rand;
end
validateattributes(u, {'numeric'}, {'scalar','real','finite','>=',0,'<',1});
% Scaling first avoids overflow when users supply very large weights.
weights = weights / max(weights);
cdf = cumsum(weights / sum(weights));
cdf(end) = 1;
index = find(u < cdf, 1, 'first');
% Git version control test - October 8, 2026
end
