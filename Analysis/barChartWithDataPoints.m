%bar chart with data points code for the looming paper. Data analysis for 
%speed change condition in terms of the change in speed within an interval.

clear all; close all;

%thresholds for conditions in cm/s - from psychometric functions, hard
%coded here.

%analysis in terms of the change within the interval
speedChangeAnalysis1 = [25.03863625 24.97120433 22.77618558 22.51116966 ...
    20.79725959 19.05678278 17.61731636 15.66909269 14.14273464 14.13452884 13.90705943];

%analysis in terms of the difference in endpoints between intervals
speedChangeAnalysis2 = [10.39862942 11.25558534 11.25558534 12.4856025 7.07136693 ...
    12.51931855 8.808658482 11.38809279 7.834546024 9.528391001 6.953529872];


duration = [13.42342095 10.61328776 8.613733641 15.73700571 6.227895739 ...
    8.139606584 14.01721309];

distance = [10.45196141 12.94842084 7.089060279 16.57741634 6.765567317 ...
    4.436278234 22.70700646];

meanThresholds = [(mean(speedChangeAnalysis1)), (mean(speedChangeAnalysis2)),  (mean(duration)), (mean(distance))];

%confidence intervals
%speed change condition in terms of the change within the interval
semSpeedChangeAnalysis1 = std(speedChangeAnalysis1)/sqrt(length(speedChangeAnalysis1));
icdfSpeedChangeAnalysis1 = tinv([0.025, 0.975], 10);
rawCISpeedChangeAnalysis1 = semSpeedChangeAnalysis1 * icdfSpeedChangeAnalysis1;
CISpeedChangeAnalysis1 = mean(speedChangeAnalysis1) + rawCISpeedChangeAnalysis1;

%speed change condition in terms of the difference between the end speeds
%of the two intervals

semSpeedChangeAnalysis2 = std(speedChangeAnalysis2)/sqrt(length(speedChangeAnalysis2));
icdfSpeedChangeAnalysis2 = tinv([0.025, 0.975], 10);
rawCISpeedChangeAnalysis2 = semSpeedChangeAnalysis2 * icdfSpeedChangeAnalysis2;
CISpeedChangeAnalysis2 = mean(speedChangeAnalysis2) + rawCISpeedChangeAnalysis2;


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
xlim([1,9]);
x = [2, 4, 6, 8];
xticks(x);
xticklabels({'Speed change', 'Speed change', 'Duration', 'Distance'});

bar(x, meanThresholds, 'BarWidth', 0.4, 'FaceColor', [1 0.8 0.7], 'EdgeColor', 'none');
neg = [rawCISpeedChangeAnalysis1(1), rawCISpeedChangeAnalysis2(1), rawCIDuration(1), rawCIDistance(1)];
pos = [rawCISpeedChangeAnalysis1(2), rawCISpeedChangeAnalysis2(2), rawCIDuration(2), rawCIDistance(2)];
errorbar(x, meanThresholds, neg, pos,'.k', 'LineWidth', 1, 'MarkerSize', 1, 'CapSize', 10);

%randomising x position of individual data dots
sc1DotXPreLim = repmat(2, length(speedChangeAnalysis1), 1);
sc1XRand = -0.2 + (0.2--0.2).* (rand(length(speedChangeAnalysis1),1));
sc1DotX = sc1DotXPreLim + sc1XRand;

sc2DotXPreLim = repmat(4, length(speedChangeAnalysis2), 1);
sc2XRand = -0.2 + (0.2--0.2).* (rand(length(speedChangeAnalysis2),1));
sc2DotX = sc2DotXPreLim + sc2XRand;

durDotXPreLim = repmat(6, length(duration), 1);
durXRand = -0.2 + (0.2--0.2).* (rand(length(duration),1));
durDotX = durDotXPreLim + durXRand;

distDotXPreLim = repmat(8, length(distance), 1);
distXRand = -0.2 + (0.2--0.2).* (rand(length(distance),1));
distDotX = distDotXPreLim + distXRand;

%plot individual data points on bars
plot(sc1DotX, speedChangeAnalysis1, 'o', 'MarkerFaceColor', [0.8 0 0], 'MarkerEdgeColor', [0.8 0 0], 'MarkerSize', 3);
plot(sc2DotX, speedChangeAnalysis2, 'o', 'MarkerFaceColor', [0.8 0 0], 'MarkerEdgeColor', [0.8 0 0], 'MarkerSize', 3);
plot(durDotX, duration, 'o', 'MarkerFaceColor', [0.8 0 0], 'MarkerEdgeColor', [0.8 0 0], 'MarkerSize', 3);
plot(distDotX, distance, 'o', 'MarkerFaceColor', [0.8 0 0], 'MarkerEdgeColor', [0.8 0 0], 'MarkerSize', 3);

set(gca,'linewidth',1)
set(gca,'TickLength',[0 0])
ylabel('75% threshold (cm/s)', 'FontSize', 12);

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 5.5 4];
print('Figure3_individual_overlay','-dpdf','-r0')

