function test_lottery
%TEST_LOTTERY Boundary, validation, distribution and GUI integration tests.
rng(2026);
assert(lottery_pick([1 3 6],0) == 1);
assert(lottery_pick([1 3 6],0.1) == 2);
assert(lottery_pick([1 3 6],0.4) == 3);
assert(lottery_pick([0 1 0],0) == 2);
assert(lottery_pick([0 1 0],1-eps) == 2);
assert(lottery_pick([realmax realmax],0.75) == 2);
bad = {@() lottery_pick([0 0]), @() lottery_pick([-1 2]), ...
    @() lottery_pick([NaN 1]), @() lottery_pick([Inf 1]), ...
    @() lottery_pick([1 2],1), @() lottery_wheel({'A'},[1 2])};
for k = 1:numel(bad)
    failed = false;
    try, bad{k}(); catch, failed = true; end
    assert(failed,'Expected invalid input to be rejected.');
end
count = zeros(1,3); trials = 50000;
for k = 1:trials
    j = lottery_pick([1 3 6]); count(j) = count(j)+1;
end
observed = count/trials;
assert(all(abs(observed-[0.1 0.3 0.6]) < 0.01));
f = lottery_wheel({'A','B','C'},[1 3 6],'Visible','off','Duration',0);
cleanup = onCleanup(@() close(f));
callback = getappdata(f,'LotterySpin');
for k = 1:30
    callback();
    j = getappdata(f,'LotteryLastIndex');
    a = getappdata(f,'LotteryAngle');
    pointerAngle = mod(pi/2-a,2*pi);
    assert(floor(pointerAngle/(2*pi/3))+1 == j,'Pointer/result mismatch.');
end
animated = lottery_wheel({'A','B','C'},[1 3 6],'Visible','off','Duration',0.2);
animatedCleanup = onCleanup(@() close(animated));
animatedCallback = getappdata(animated,'LotterySpin');
animatedCallback();
j = getappdata(animated,'LotteryLastIndex');
a = getappdata(animated,'LotteryAngle');
assert(floor(mod(pi/2-a,2*pi)/(2*pi/3))+1 == j);
fprintf('PASS: boundaries, 6 invalid inputs, 50000 draws, 30 GUI spins, timed animation.\n');
fprintf('Observed probabilities: %.4f %.4f %.4f\n',observed);
end
