function fig = lottery_wheel(prizes, weights, varargin)
%LOTTERY_WHEEL Animated lottery wheel. Run lottery_wheel to start.
% Example: lottery_wheel({'一等奖','二等奖','谢谢参与'}, [1 3 6]);
% Sectors are equally sized; the displayed weights determine probabilities.
if nargin < 1
    prizes = {'一等奖','二等奖','三等奖','小礼品','再来一次','谢谢参与'};
end
if nargin < 2
    weights = [1 3 6 15 25 50];
end
if isstring(prizes), prizes = cellstr(prizes); end
if ~iscellstr(prizes) || isempty(prizes) || any(cellfun(@isempty, prizes))
    error('lottery:InvalidPrizes', '奖项必须是非空文字列表。');
end
lottery_pick(weights, 0); % Validate before creating UI.
if numel(prizes) ~= numel(weights)
    error('lottery:SizeMismatch', '奖项数量与权重数量必须相同。');
end
p = inputParser;
addParameter(p, 'Visible', 'on', @(x) any(strcmp(x, {'on','off'})));
addParameter(p, 'Duration', 3, @(x) isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x >= 0);
parse(p, varargin{:});
n = numel(prizes);
w = double(weights(:)); w = w/max(w); probability = w/sum(w);
fig = figure('Name','转盘抽奖','NumberTitle','off','MenuBar','none', ...
    'Color',[0.97 0.97 1],'Position',[200 100 720 720], 'Visible',p.Results.Visible);
ax = axes('Parent',fig,'Position',[0.08 0.25 0.84 0.68]);
hold(ax,'on'); axis(ax,'equal'); axis(ax,[-1.3 1.3 -1.3 1.3]); axis(ax,'off');
colors = lines(n);
sectors = gobjects(n,1); labels = gobjects(n,1); base = cell(n,1);
centers = ((1:n)-0.5)*2*pi/n;
for k = 1:n
    a = linspace((k-1)*2*pi/n, k*2*pi/n, 80);
    base{k} = [0 cos(a); 0 sin(a)];
    sectors(k) = patch(ax,base{k}(1,:),base{k}(2,:),colors(k,:), 'EdgeColor','w','LineWidth',2);
    labels(k) = text(ax,0.65*cos(centers(k)),0.65*sin(centers(k)), ...
        sprintf('%s\n%.1f%%',prizes{k},100*probability(k)), ...
        'HorizontalAlignment','center','FontSize',11,'FontWeight','bold','Color','k','Interpreter','none');
end
patch(ax,[-0.08 0.08 0],[1.18 1.18 0.96],[0.85 0.1 0.15],'EdgeColor','none');
text(ax,0,0,'抽奖','HorizontalAlignment','center','FontSize',18,'FontWeight','bold', ...
    'BackgroundColor','w','Margin',8);
result = uicontrol(fig,'Style','text','Units','normalized','Position',[0.08 0.16 0.84 0.06], ...
    'String','点击按钮开始抽奖','FontSize',16,'BackgroundColor',fig.Color);
button = uicontrol(fig,'Style','pushbutton','Units','normalized','Position',[0.3 0.07 0.4 0.075], ...
    'String','开始抽奖','FontSize',16,'Callback',@spin);
uicontrol(fig,'Style','text','Units','normalized','Position',[0.05 0.01 0.9 0.04], ...
    'String','扇区等大，中奖概率以奖项下方百分比为准。','BackgroundColor',fig.Color);
angle = 0; busy = false;
setappdata(fig,'LotterySpin',@spin);
setappdata(fig,'LotteryProbabilities',probability);
    function spin(varargin)
        if busy || ~isgraphics(fig), return; end
        busy = true; set(button,'Enable','off'); set(result,'String','转盘旋转中……');
        cleanup = onCleanup(@unlock);
        selected = lottery_pick(weights);
        % Stop inside the selected sector, with margin from either edge.
        landing = centers(selected) + (rand-0.5)*0.6*(2*pi/n);
        travel = 5*2*pi + mod(pi/2-landing-angle,2*pi);
        startAngle = angle;
        timer = tic;
        while isgraphics(fig)
            if p.Results.Duration == 0, t = 1; else, t = min(toc(timer)/p.Results.Duration,1); end
            angle = startAngle + travel*(1-(1-t)^3);
            paint(angle); drawnow;
            if t >= 1, break; end
            pause(0.015);
        end
        if ~isgraphics(fig), return; end
        angle = mod(angle,2*pi);
        setappdata(fig,'LotteryLastIndex',selected);
        setappdata(fig,'LotteryAngle',angle);
        set(result,'String',['抽奖结果：' prizes{selected}]);
    end
    function paint(a)
        rotation = [cos(a) -sin(a); sin(a) cos(a)];
        for j = 1:n
            xy = rotation*base{j};
            set(sectors(j),'XData',xy(1,:),'YData',xy(2,:));
            set(labels(j),'Position',[0.65*cos(centers(j)+a) 0.65*sin(centers(j)+a) 0]);
        end
    end
    function unlock
        busy = false;
        if isgraphics(button), set(button,'Enable','on'); end
    end
end
