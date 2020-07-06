%From your spreadsheet:

duration = [0.3 0.4 0.3; ...

    0.7 1   1; ...

    0.9 0.6 0.6; ...

    0.4 0.8 0.6; ...

    0.5 0.3 0.3; ...

    0.5 0.2 0.1; ...

    0.5 0.8 0.8];

nTrials = 10*ones(size(duration)); %define total number of ntrials

nCorrect = duration.*nTrials; %convert %correct to nCorrect;

 

for i=1:7,

    xLoc = [1 2 3]+(i-1)/20; %Add a little offset to each plot

    plot2afc(xLoc,nCorrect(i,:),nTrials(i,:));

    hold on;

 end

