function [resultsTable,uuid,outputFolder] = initTable(mainFolder,numOfIterationsPerTable)
headers = {'date','time [HH:mm:ss]','seconds','power1','power2','power3','temperature','water','smoke','laser'};
resultsTable = cell2table(cell(numOfIterationsPerTable,length(headers))); % for testing
resultsTable.Properties.VariableNames = headers;

% generate unique ID, generate output / results folder
uuid = mkNewUUID();
outputFolder = sprintf('%s\\results\\%s_%s',mainFolder,datetime(now,'ConvertFrom','datenum','Format','dd.MM.yyyy'),uuid);
mkdir(outputFolder)
end

function uuid = mkNewUUID()
uuid_tmp = char(java.util.UUID.randomUUID.toString);
uuid = uuid_tmp(1:6);
end
