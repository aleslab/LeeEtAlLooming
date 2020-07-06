function [errorbarHandle] = plot2afc( x, nCorrect, nTrials )
%plot2afc plots 2afc data with 95% confidence intervals
% [errorbarHandle] = plot2afc( x, nCorrect, nTrials )
% 
% This function is to help with plotting data from 2AFC experiments 
% it calculates the 95% confidence intervals for the data using the
% binomial distribution 
% NOTE!: This function also inflates using the "Rule of Threes".  
% When there are no observed correct respones or 100% correct the binomial
% distribution confidence interval collapses to 0.  A simple way of
% correcting is to use the "rule of threes".  Basically it is assumed the
% confidence interval must be at least 3 trials wide.  See citations in
% code for more. 
%
% Inputs:
% x = levels to plot on x axis
% nCorrect = Number of correct trials.
% nTrials = Number of total trials. 
%
% Outputs:
% errorbarHandle = Handle to the errorbar plot series created. 
%


%
% http://www.pmean.com/01/zeroevents.html
%
% Further reading
% 
% Probability of adverse events that have not yet occurred: a statistical reminder. Eypasch E, Lefering R, Kum CK, Troidl H. Bmj 1995: 311(7005); 619-20. [Medline] [Full text]
% If nothing goes wrong, is everything all right? Interpreting zero numerators. Hanley JA, Lippman-Hand A. Jama 1983: 249(13); 1743-5. [Medline]
% How likely is it to go wrong Doctor?. Bandolier. Accessed on 2005-03-10. www.jr2.ox.ac.uk/bandolier/band23/b23-2.html
% 
%Coerce inputs into all being vectors with the same ;
x = x(:);
nCorrect = nCorrect(:);
nTrials  = nTrials(:);


percentCorrect = nCorrect./nTrials;

%Use rule of 3's to inflate the confidence intervals for 
%binoinv(.025,nTrials,percentCorrect)./nTrials
lowerValInflated = min(binoinv(.025,nTrials,percentCorrect)./nTrials,1-(3./nTrials));
upperValInflated = max(binoinv(.975,nTrials,percentCorrect)./nTrials,(3./nTrials));

%lowerCi = percentCorrect - binoinv(.025,nTrials,percentCorrect)./nTrials;
lowerCi = percentCorrect - lowerValInflated;

%upperCi = binoinv(.975,nTrials,percentCorrect)./nTrials - percentCorrect;
upperCi = upperValInflated - percentCorrect;
errorbarHandle=errorbar(x,percentCorrect,lowerCi,upperCi,'o','markersize',10);

if exist('ptbCorgiSetPlotOptions')
    ptbCorgiSetPlotOptions();
else
set(errorbarHandle,'linewidth',3);
box(gca,'off');  
set(gca,'linewidth',3,'fontsize',22);
set(gcf,'color','w');
end


end

