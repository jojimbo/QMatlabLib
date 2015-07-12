function report(obj, reportFlnm, result, varargin)
%% report
% Create individual report
% |report(obj, reportFlnm, result, varargin)|

% _____________________________________________________________
% 1. Prepare calculation results for reporting
%    Split per non-market risk. Entries of several non-market
%    risks are found in the corrMat object
riskTypes    = obj.corrMat.rtTable;

% First word of a risk is used to group
cllFirstWord = regexp(riskTypes(:, 1), '(\S+)\s*.*', 'tokens');
firstWords   = cellfun(@(x)(x{1}), cllFirstWord);
unFirstWord  = unique(firstWords, 'stable');
isSingle     = false(size(unFirstWord));


for iCount = 1:numel(unFirstWord)
    isSingle(iCount) = sum(strcmp(unFirstWord{iCount}, firstWords)) < 2;
end

unFirstWord(isSingle) = [];
diverStr              = cellfun(@(x)([x ' diversification']), unFirstWord, 'UniformOutput', false);
riskTypeFullNm        = [riskTypes(:, 1); unFirstWord];
riskTypeAbbr          = riskTypes(:, 2);


for iFirstWords = 1:numel(unFirstWord)
    idxWord               = strcmp(unFirstWord(iFirstWords), firstWords);
    riskTypeAbbr{end + 1} = riskTypes(idxWord, 2); %#ok<AGROW> not known a priori
end

[unRistTypeFullNm, inIn] = unique(riskTypeFullNm, 'stable');
unRiskTypeAbbr           = riskTypeAbbr(inIn);
NonMarketEC_split        = zeros(numel(result.GIDsToCalc), size(riskTypes, 1));


for iGroup = 1:numel(result.EC_AllGroups.ids)
    % Loop over GIDs (group id's)

    for jRiskType = 1:numel(unRiskTypeAbbr)
        % Loop over riskTypes
        riskType   = unRiskTypeAbbr{jRiskType};
        NMEC_split = obj.instCol.calculateNonMarketECaggr(obj.corrMat,   ...
            0, result.ECop, result.confLevel, obj.portfolio, ...
            result.EC_AllGroups.ids(iGroup),  obj.forexCol,  ...
            result.currency, riskType);
        
        NonMarketEC_split(iGroup, jRiskType) = NMEC_split;
    end
end

unRistTypeFullNmEx   = [unRistTypeFullNm; diverStr];
[sortedNms, sortIdx] = sort(unRistTypeFullNmEx);


% _____________________________________________________________
% 2. Report Creation: CSV file creation
% Construct filename, based on Stem, Currency and Confidence Level
splitStr = regexpi(reportFlnm, '\.', 'split');
flNmStem = splitStr{1};

if numel(splitStr) > 1
    flNmExt = splitStr{2};
else
    flNmExt = 'csv';
end

% Merge the individual parts
reportFlnm = [flNmStem '_' result.currency '_' num2str(result.confLevel) '.' flNmExt];

if eq(exist(reportFlnm, 'file'), 2)
    % Remove any existing instances
    try
        delete(reportFlnm);
    catch ME
        % Unable to delete legacy report files, this poses a
        % problem for the workflow. Warn the user and return...
        error(['Cannot remove obsoleted resultfile: ' reportFlnm '. ' ME.message]);
        return
    end
end

% Start composing the result file:
% Create cell:
%
% 4 more rows for:
%   column header
%   white line
%   EC aggregated
%   currency
%
% 1 extra column  for:
%   row header
%   market risk
extraRows   = 4;
extraCols   = 3;
reportCell  = cell(numel(result.EC_AllGroups.ids) + extraRows, ...
                    numel(sortedNms) + extraCols);

reportCell{1, 1} = 'Currency';
reportCell{1, 2} = result.currency;
reportCell{2, 1} = 'Aggregated EC';
reportCell{2, 2} = result.ECaggr;

% Fill row headers
reportCell((extraRows + 1):end, 1) = result.EC_AllGroups.ids;

% Fill hierarchy level
reportCell{extraRows, 2} = 'Portfolio Level';
allGIDs                  = cellfun(@(x)(x.GID{1}), obj.portfolio.groups, 'UniformOutput', false);
[~, ~, inSecond]         = intersect(result.EC_AllGroups.ids, allGIDs);
hierarchyVal             = num2cell(obj.portfolio.groupLevel(inSecond));

reportCell((extraRows + 1):end, extraCols - 1) = hierarchyVal;

% Fill column headers
reportCell{extraRows, extraCols}           = 'Market EC';
reportCell(extraRows, (extraCols + 1):end) = sortedNms;

% Fill Market EC values
reportCell((extraRows + 1):end, extraCols) = num2cell(result.MarketEC);

for iNode = 1:numel(result.EC_AllGroups.ids)

    for jRisk = 1:numel(sortedNms)
        % Initialize
        NMEC_div = [];

        % Check if string has 'diversification' in it, if so,
        % do the calculation for this
        isDiv = ~isempty(strfind(sortedNms{jRisk}, 'diversification'));

        if isDiv
            % Find level name
            name = regexp(sortedNms{jRisk}, '(\S+)\s*.*', 'tokens');
            
            % Exclude both 'xx diversification' and the level name itself
            risksToCalc        = ~cellfun(@isempty, strfind(sortedNms, [name{1}{1} ' ']));
            risksToCalc(jRisk) = false;
            groupRisk          = strcmp(name{1}{1}, sortedNms);

            % Calculate diversification
            NMEC_div = NonMarketEC_split(iNode, sortIdx(groupRisk)) ...
                        - sum(NonMarketEC_split(iNode, sortIdx(risksToCalc)));
        end


        tableCol = sortIdx(jRisk);
        if tableCol <= numel(unRistTypeFullNm)

            reportCell{extraRows + iNode, jRisk + extraCols} = NonMarketEC_split(iNode, tableCol);

        elseif isDiv

            reportCell{extraRows + iNode, jRisk + extraCols} = NMEC_div;

        end
    end
end

% Create CSV report
try
    internalModel.Utilities.cell2csv(reportFlnm, reportCell, ',');

catch ME %#ok<NASGU> might be usefull later
    warning('ing:NoFileCreated', ['Output ' reportFlnm ' has not been created']);
end

end
