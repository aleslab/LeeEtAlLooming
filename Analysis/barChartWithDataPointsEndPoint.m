%bar chart with data points code for the looming paper. Data analysis for 
%speed change condition in terms of the speed at the endpoints of the
%change and standard intervals.

clear all; close all;

%thresholds for conditions in cm/s - from psychometric functions, hard
%coded here.

speedChange = [10.39862942 11.25558534 11.25558534 12.4856025 7.07136693 ...
    12.51931855 8.808658482 11.38809279 7.834546024 9.528391001 6.953529872];

duration = [13.42342095 10.61328776 8.613733641 15.73700571 6.227895739 ...
    8.139606584 14.01721309];

distance = [10.45196141 12.94842084 7.089060279 16.57741634 6.765567317 ...
    4.436278234 22.70700646];

meanThresholds = [(mean(speedChange)), (mean(duration)), (mean(distance))];

%confidence intervals
%speed change condition
semSpeedChange = std(speedChange)/sqrt(length(speedChange));
icdfSpeedChange = tinv([0.025, 0.975], 10);
rawCISpeedChange = semSpeedChange * icdfSpeedChange;
CISpeedChange = mean(speedChange) + rawCISpeedChange;

%duration condition
semDuration = std(duration)/sqrt(length(duration));
icdfDuration = tinv([0.025, 0.975], 6);
rawCIDuration = semDuration * icdfDuration;
CIDuration = mean(duration) + rawCIDuration;

%distance condition
semDistance = std(distance)/sqrt(length(distance));
icdfDistance = tinv([0.025, 0.975], 6);
rawCIDistance = semDistance * icdfDistance;
CIDistance = mean(distance) + rawCIDistance;

figure(101)
hold on
xlim([1,7]);
ylim([0,30]);
x = [2, 4, 6];
xticks(x);
xticklabels({'Speed change', 'Duration', 'Distance'});

bar(x, meanThresholds, 'BarWidth', 0.4, 'FaceColor', [1 0.6 0.5], 'EdgeColor', 'none');
neg = [rawCISpeedChange(1), rawCIDuration(1), rawCIDistance(1)];
pos = [rawCISpeedChange(2), rawCIDuration(2), rawCIDistance(2)];
errorbar(x, meanThresholds, neg, pos,'.k', 'LineWidth', 1, 'MarkerSize', 1, 'CapSize', 10);

%randomising x position of individual data dots
scDotXPreLim = repmat(2, length(speedChange), 1);
scXRand = -0.2 + (0.2--0.2).* (rand(length(speedChange),1));
scDotX = scDotXPreLim + scXRand;

durDotXPreLim = repmat(4, length(duration), 1);
durXRand = -0.2 + (0.2--0.2).* (rand(length(duration),1));
durDotX = durDotXPreLim + durXRand;

distDotXPreLim = repmat(6, length(distance), 1);
distXRand = -0.2 + (0.2--0.2).* (rand(length(distance),1));
distDotX = distDotXPreLim + distXRand;

%plot individual data points on bars
plot(scDotX, speedChange, 'o', 'MarkerFaceColor', [0.8 0 0], 'MarkerEdgeColor', [0.8 0 0], 'MarkerSize', 3);
plot(durDotX, duration, 'o', 'MarkerFaceColor', [0.8 0 0], 'MarkerEdgeColor', [0.8 0 0], 'MarkerSize', 3);
plot(distDotX, distance, 'o', 'MarkerFaceColor', [0.8 0 0], 'MarkerEdgeColor', [0.8 0 0], 'MarkerSize', 3);

set(gca,'linewidth',1)
set(gca,'TickLength',[0 0])
ylabel('75% threshold (cm/s)', 'FontSize', 12);

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 5 4];
print('Figure4_endpoint_analysis_individual_overlay','-dpdf','-r0')

