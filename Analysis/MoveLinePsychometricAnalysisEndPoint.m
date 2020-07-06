clearvars;

dataDir = uigetdir();
cd(dataDir)

%participantCodes = {'AA' 'AB' 'AD' 'AG' 'AH' 'AE'  'AI' 'AL'}; % participants in speed discrimination conditions
participantCodes = {'M' 'O' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' }; %'AL' participants in speed
%change discrimination conditions

ParOrNonPar = 2; %non-parametric bootstrap for all
BootNo = 1000; %number of simulations for all bootstraps and goodness of fits

for iParticipant = 1:length(participantCodes)
    
    currParticipantCode = cell2mat(participantCodes(iParticipant));
    
    %speed change discrimination conditions, including those that include
    %binocular cues to motion in depth, and those containing both looming
    %and binocular cues
    
        conditionList = {'MoveLine_accelerating_looming_midspeed'};
    
    %speed discrimination conditions
    %conditionList = {'SpeedDisc_fixed_duration'; 'SpeedDisc_fixed_distance'};
    
    analysisType = {'real_world_change_endpoint'}; %'real_world_change' for speed change discrimination task
    %analysisType = {'real_world_difference'}; % real_world_difference for
    %speed discrimination task
    
    for iAnalysis = 1:length(analysisType)
        currAnalysisType = cell2mat(analysisType(iAnalysis));
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
            
            allExperimentData = [dataFile.experimentData]; %all of the experiment data in one combined struct
            allSessionInfo = dataFile.sessionInfo; %all of the session info data in one combined struct
            ResponseTable = struct2table(allExperimentData); %The data struct is converted to a table
            
            %excluding invalid trials
            wantedData = ~(ResponseTable.validTrial == 0); %creates a logical of which trials in the data table were valid
            validIsResponseCorrect = ResponseTable.isResponseCorrect(wantedData); %
            validCondNumber = ResponseTable.condNumber(wantedData);
            if iscell(validIsResponseCorrect) %if this is a cell because there were invalid responses
                correctResponsesArray = cell2mat(validIsResponseCorrect); %convert to an array
                correctResponsesLogical = logical(correctResponsesArray); %then convert to a logical
            else
                correctResponsesLogical = logical(validIsResponseCorrect); %immediately convert to a logical
            end
            
            %Calculating the number of correct responses for each condition for the
            %valid trials
            correctTrials = validCondNumber(correctResponsesLogical); %the conditions of each individual correct response
            correctTrialConditions = unique(correctTrials); %the conditions for which a correct response was made
            condCorrectNumbers = histc(correctTrials, correctTrialConditions); %the total number of correct responses for each condition
            condCorrectNumbers = condCorrectNumbers';
            % %Finding the total number of trials for each condition for the valid trials
            allTrialConditions = unique(validCondNumber); %the conditions for which any response was made
            allTrialNumbers = histc(validCondNumber, allTrialConditions); %the total number of responses for each condition
            allTrialNumbers = allTrialNumbers';
            %allCorrectPercentages = (condCorrectNumbers./allTrialNumbers); %creates a double of the percentage correct responses for every condition
            
            %dealing with the catch trials, which were listed as conditions
            %8 and 9
            if length(condCorrectNumbers) > 7 && length(condCorrectNumbers) == 9
                
                level8 = condCorrectNumbers(8);
                
                level9 = condCorrectNumbers(9);
                
                condCorrectNumbers = condCorrectNumbers(1:7);
                
                allTrialNumbers = allTrialNumbers(1:7);
                
            elseif length(condCorrectNumbers) > 7 && length(condCorrectNumbers) == 8
                
                level8 = condCorrectNumbers(8);
                
                level9 = 0;
                
                condCorrectNumbers = condCorrectNumbers(1:7);
                
                allTrialNumbers = allTrialNumbers(1:7);
                
            end
            
            %% Specifying what the levels were in different types of analysis
            
            
            if strcmp(currAnalysisType, 'real_world_difference')
                
                xLabelTitle  = 'Speed difference in the world (cm/s)';
                
                speedDiff = [0 5 10 15 20 25 30];
                
            elseif strcmp(currAnalysisType, 'real_world_change');
                
                xLabelTitle  = 'Speed change in the world (cm/s)';
                
                if strfind(currCondition, 'midspeed')
                    
                    speedDiff = [0 10 20 30 40 50 60];
                    
                elseif strfind(currCondition, 'slow')
                    
                    speedDiff = [0 5 10 15 20 25 30];
                    
                end
                
            elseif strcmp(currAnalysisType, 'real_world_change_endpoint')
                
                xLabelTitle  = 'Speed difference between standard and test at end of interval (cm/s)';
                
                speedDiff = [0 5 10 15 20 25 30];
                
            end
            %% Psychometric function fitting adapted from PAL_PFML_Demo
            
            tic
            
            PF = @PAL_CumulativeNormal;
            
            %Threshold and Slope are free parameters, guess and lapse rate are fixed
            paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
            
            %Parameter grid defining parameter space through which to perform a
            %brute-force search for values to be used as initial guesses in iterative
            %parameter search.
            searchGrid.alpha = linspace(min(speedDiff),max(speedDiff),101);
            searchGrid.beta = linspace(0,(30/max(speedDiff)),101);
            searchGrid.gamma = 0.5;  %scalar here (since fixed) but may be vector
            searchGrid.lambda = 0;  %ditto
            
            %Perform fit
            disp('Fitting function.....');
            [paramsValues, LL, exitflag] = PAL_PFML_Fit(speedDiff,condCorrectNumbers, ...
                allTrialNumbers,searchGrid,paramsFree,PF);
            
            disp('done:')
            message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
            disp(message);
            message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
            disp(message);
            
            disp('Determining standard errors.....');
            
            if ParOrNonPar == 1
                [SD, paramsSim, LLSim, converged] = PAL_PFML_BootstrapParametric(...
                    speedDiff, allTrialNumbers, paramsValues, paramsFree, BootNo, PF, ...
                    'searchGrid', searchGrid);
            else
                [SD, paramsSim, LLSim, converged] = PAL_PFML_BootstrapNonParametric(...
                    speedDiff, condCorrectNumbers, allTrialNumbers, [], paramsFree, BootNo, PF,...
                    'searchGrid',searchGrid);
            end
            
            disp('done:');
            message = sprintf('Standard error of Threshold: %6.4f',SD(1));
            disp(message);
            message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
            disp(message);
            
            disp('Determining Goodness-of-fit.....');
            
            [Dev, pDev] = PAL_PFML_GoodnessOfFit(speedDiff, condCorrectNumbers, allTrialNumbers, ...
                paramsValues, paramsFree, BootNo, PF, 'searchGrid', searchGrid);
            
            disp('done:');
            
            %Put summary of results on screen
            message = sprintf('Deviance: %6.4f',Dev);
            disp(message);
            message = sprintf('p-value: %6.4f',pDev);
            disp(message);
            
            %Create simple plot
            ProportionCorrectObserved=condCorrectNumbers./allTrialNumbers;
            StimLevelsFineGrain=[min(speedDiff):max(speedDiff)./1000:max(speedDiff)];
            ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
            
            figure;
            axes
            hold on
            plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[0.2, 0.2, 0.2],'linewidth',2);
            plot(speedDiff,ProportionCorrectObserved,'k.','markersize',10);
            set(gca, 'fontsize',10);
            set(gca, 'Xtick', speedDiff);
            axis([min(speedDiff) max(speedDiff) .4 1]);
            xlabel(xLabelTitle, 'FontSize', 12);
            ylabel('proportion correct', 'FontSize', 12);
            %title(condAndParticipant, 'interpreter', 'none');
            
            figFileName = strcat('psychometric_', currAnalysisType, '_', condAndParticipant, '.pdf');
            saveas(gcf, figFileName);
            
%             fig = gcf;
%             fig.PaperUnits = 'inches';
%             fig.PaperPosition = [0 0 2.5 2.5];
%             print('speedDurExFunction','-dpdf','-r0')
            
            if strcmp(currAnalysisType, 'real_world_difference');
                
                RawDataExcelFileName = strcat('raw_data_', condAndParticipant, '.csv');
                writetable(ResponseTable, RawDataExcelFileName);
            end
            
            
            %%
            stimAt75PercentCorrect = PAL_CumulativeNormal(paramsValues, 0.75, 'Inverse');
            slopeAt75PercentThreshold = PAL_CumulativeNormal(paramsValues, stimAt75PercentCorrect, 'Derivative');
            % this slope value might not be particularly close to the beta
            %value that comes out of the paramsValues things as with the
            %cumulative normal function the beta value is the inverse of
            %the standard deviation, which is related/proportional to the
            %slope but not actually the slope.
            
            for iBoot = 1:BootNo
                boot75Threshold(iBoot) = PAL_CumulativeNormal(paramsSim(iBoot,:), 0.75, 'Inverse');
                bootSlopeAt75Threshold(iBoot) = PAL_CumulativeNormal(paramsSim(iBoot,:), boot75Threshold(iBoot), 'Derivative');
            end
            
            thresholdSE = std(boot75Threshold); %standard error of the threshold, used for individual participant error bars
            slopeSE = std(bootSlopeAt75Threshold);
            
            sortedThresholdSim = sort(boot75Threshold);
            sortedSlopeSim = sort(bootSlopeAt75Threshold);
            thresholdCI = [sortedThresholdSim(25) sortedThresholdSim(BootNo-25)];
            slopeCI = [sortedSlopeSim(25) sortedSlopeSim(BootNo-25)];
            
            psychInfo(iCond).condition = currCondition;
            
            %correct values that i've calculated
            psychInfo(iCond).stimAt75PercentCorrect = stimAt75PercentCorrect;
            psychInfo(iCond).slopeAt75PercentThreshold = slopeAt75PercentThreshold;
            psychInfo(iCond).alphaCI = thresholdCI;
            psychInfo(iCond).betaCI = slopeCI;
            psychInfo(iCond).thresholdSE = thresholdSE;
            psychInfo(iCond).slopeSE = slopeSE;
            %psychInfo(iCond).level8 = level8;
            %psychInfo(iCond).level9 = level9;
            
            %the original parameters, standard errors from bootstrapping
            %and values from goodness of fit (dev and pdev).
            psychInfo(iCond).condParamsValues = paramsValues;
            psychInfo(iCond).condParamsSE = SD;
            psychInfo(iCond).condParamsDev = Dev;
            psychInfo(iCond).condParamsPDev = pDev;
            
            toc
        end
        psychTable = struct2table(psychInfo);
        psychExcelFileName = strcat('psychometric_data_', currAnalysisType, '_', currParticipantCode, '.csv');
        writetable(psychTable, psychExcelFileName);
    end
end
