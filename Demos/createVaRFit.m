function [pd1,pd2,pd3,pd4,pd5,pd6] = createVaRFit(finalPayments, varLevel)
%CREATEFIT    Create plot of datasets and fits
%   [PD1,PD2,PD3,PD4,PD5,PD6] = CREATEFIT(FINALPAYMENTS)
%   Creates a plot, similar to the plot in the main distribution fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with dfittool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  6
%
%   See also FITDIST.

% This function was automatically generated on 19-May-2015 11:15:12

% Output fitted probablility distributions: PD1,PD2,PD3,PD4,PD5,PD6

% Data from dataset "finalPayments data":
%    Y = finalPayments

% Force all inputs to be column vectors
finalPayments = finalPayments(:);

% Prepare figure
%clf;
title('Final Payoffs Distribution and VaR');
hold on;
LegHandles = []; LegText = {};


% --- Plot data originally in dataset "finalPayments data"
[CdfF,CdfX] = ecdf(finalPayments,'Function','cdf');  % compute empirical cdf
BinInfo.rule = 1;
[~,BinEdge] = internal.stats.histbins(finalPayments,[],[],BinInfo,CdfF,CdfX);
[BinHeight,BinCenter] = ecdfhist(CdfF,CdfX,'edges',BinEdge);
hLine = bar(BinCenter,BinHeight,'hist');
set(hLine,'FaceColor','none','EdgeColor',[0.333333 0 0.666667],...
    'LineStyle','-', 'LineWidth',1);
xlabel('Data');
ylabel('Density')
LegHandles(end+1) = hLine;
LegText{end+1} = 'finalPayments data';

% Create grid where function will be computed
XLim = get(gca,'XLim');
XLim = XLim + [-1 1] * 0.01 * diff(XLim);
XGrid = linspace(XLim(1),XLim(2),100);


% --- Create fit "Normal"

% Fit this distribution to get parameter values
% To use parameter estimates from the original fit:
%     pd1 = ProbDistUnivParam('normal',[ 24.27680054189, 20.98685862284])
pd1 = fitdist(finalPayments, 'normal');
YPlot = pdf(pd1,XGrid);
hLine = plot(XGrid,YPlot,'Color',[1 0 0],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
LegHandles(end+1) = hLine;
LegText{end+1} = 'Normal';

% --- Create fit "lognormal"

% Fit this distribution to get parameter values

% Create vector for exclusion rule 'Exclude0s'
% Vector indexes the points that are included
Excluded = (finalPayments > 0);

Data = finalPayments(Excluded);
% To use parameter estimates from the original fit:
%     pd2 = ProbDistUnivParam('lognormal',[ 3.169858099788, 0.9432429549854])
pd2 = fitdist(Data, 'lognormal');
YPlot = pdf(pd2,XGrid);
hLine = plot(XGrid,YPlot,'Color',[0.666667 0.333333 0],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
LegHandles(end+1) = hLine;
LegText{end+1} = 'lognormal';

% --- Create fit "Non-parametric"
pd3 = fitdist(finalPayments,'kernel','kernel','normal','support','unbounded');
YPlot = pdf(pd3,XGrid);
hLine = plot(XGrid,YPlot,'Color',[0 0 1],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
LegHandles(end+1) = hLine;
LegText{end+1} = 'Non-parametric';

% --- Create fit "Exponential"

% Fit this distribution to get parameter values
% To use parameter estimates from the original fit:
%     pd4 = ProbDistUnivParam('exponential',[ 24.27680054189])
pd4 = fitdist(finalPayments, 'exponential');
YPlot = pdf(pd4,XGrid);
hLine = plot(XGrid,YPlot,'Color',[0.333333 0.333333 0.333333],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
LegHandles(end+1) = hLine;
LegText{end+1} = 'Exponential';

% --- Create fit "Generalized Extreme Value"

% Fit this distribution to get parameter values
% To use parameter estimates from the original fit:
%     pd5 = ProbDistUnivParam('generalized extreme value',[ 0.03794153889319, 16.62500011179, 13.93886856413])
pd5 = fitdist(finalPayments, 'generalized extreme value');
YPlot = pdf(pd5,XGrid);
hLine = plot(XGrid,YPlot,'Color',[1 0 1],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
LegHandles(end+1) = hLine;
LegText{end+1} = 'Generalized Extreme Value';

% --- Create fit "Birnbaum-Saunders"

% Fit this distribution to get parameter values

% Create vector for exclusion rule 'Exclude0s'
% Vector indexes the points that are included
Excluded = (finalPayments > 0);

Data = finalPayments(Excluded);
% To use parameter estimates from the original fit:
%     pd6 = ProbDistUnivParam('birnbaumsaunders',[ 13.41971136006, 1.464087989351])
pd6 = fitdist(Data, 'birnbaumsaunders');
YPlot = pdf(pd6,XGrid);
hLine = plot(XGrid,YPlot,'Color',[1 1 0],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
LegHandles(end+1) = hLine;
LegText{end+1} = 'Birnbaum-Saunders';


% Add vertical line for VaR number:
hLine = line([quantile(finalPayments, varLevel),quantile(finalPayments, varLevel)],ylim, ...
    'AlignVertexCenters', 'on', 'Tag', 'VaR', 'DisplayName', ['VaR at ',num2str(varLevel)], 'LineStyle', '-.')
LegHandles(end+1) = hLine;
LegText{end+1} = ['VaR at ',num2str(varLevel)];

% Adjust figure
box on;
hold off;

% Create legend from accumulated handles and labels
hLegend = legend(LegHandles,LegText,'Orientation', 'vertical', 'FontSize', 9, 'Location', 'northeast');
set(hLegend,'Interpreter','none');
