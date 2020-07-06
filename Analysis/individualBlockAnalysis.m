clearvars;

dataDir = uigetdir();
cd(dataDir)

participantCodes = {'AI'}; %'AA' 'AB' 'AD' 'AG' 'AH' 'AE'  'AI'

for iParticipant = 1:length(participantCodes)
    
    currParticipantCode = cell2mat(participantCodes(iParticipant));
    
    conditionList = {'SpeedDisc_fixed_duration'}; %; 'SpeedDisc_fixed_distance' 'SpeedDisc_fixed_duration'
    
    for iCond = 1:length(conditionList)
        currCondition = cell2mat(conditionList(iCond));
        condAndParticipant = strcat(currCondition, '_', currParticipantCode);
        
        
        fileDir = fullfile(dataDir,[condAndParticipant, '_*']);
        
        filenames = dir(fileDir);
        filenames = {filenames.name}; %makes a cell of filenames from the same
        %participant and condition to be loaded together
        
        for iFiles = 1:length(filenames)
            filenamestr = char(filenames(iFiles));
            dataFile(iFiles) = load(filenamestr); %loads all of the files to be analysed together
        end
      
block1data = dataFile(1).experimentData;
block2data = dataFile(2).experimentData;
block3data = dataFile(3).experimentData;

block1ResponseCorrect = [block1data.isResponseCorrect];
block1CondNumber = [block1data.condNumber];

%for AE fixed distance
% invalidblock1 = 13;
% block1CondNumber(invalidblock1) = [];

%for AI fixed duration
% invalidblock1 = 3;
% block1CondNumber(invalidblock1) = [];

block2ResponseCorrect = [block2data.isResponseCorrect];
block2CondNumber = [block2data.condNumber];

%for AI fixed duration
% invalidblock2 = 1;
% block2CondNumber(invalidblock2) = [];

block3ResponseCorrect = [block3data.isResponseCorrect];
block3CondNumber = [block3data.condNumber];

%for AE fixed distance 
% invalidblock3 = 81;
% block3CondNumber(invalidblock3) = [];

block1cond8indices = find(block1CondNumber == 8);
block2cond8indices = find(block2CondNumber == 8);
block3cond8indices = find(block3CondNumber == 8);



for iIndices1 = 1:length(block1cond8indices)
    
    block1cond8vals(iIndices1) = block1ResponseCorrect(block1cond8indices(iIndices1));
    
end

for iIndices2 = 1:length(block2cond8indices)
    
    block2cond8vals(iIndices2) = block2ResponseCorrect(block2cond8indices(iIndices2));
    
end

for iIndices3 = 1:length(block3cond8indices)
    
    block3cond8vals(iIndices3) = block3ResponseCorrect(block3cond8indices(iIndices3));
    
end

block1sum = sum(block1cond8vals);
block2sum = sum(block2cond8vals);
block3sum = sum(block3cond8vals);

block1percentage = block1sum/length(block1cond8vals);
block2percentage = block2sum/length(block2cond8vals);
block3percentage = block3sum/length(block3cond8vals);

disp(block1percentage);
disp(block2percentage);
disp(block3percentage);
    end
end
