function resultsTable = updateTable(resultsTable,parsedData,timeS,index)

resultsTable.date{index} = timeS.datestamp;
resultsTable.("time [HH:mm:ss]"){index} = timeS.timestamp;
resultsTable.seconds{index} = timeS.seconds;
resultsTable.power1{index} = parsedData.power1;
resultsTable.power2{index} = parsedData.power2;
resultsTable.power3{index} = parsedData.power3;
resultsTable.temperature{index} = parsedData.temperature/100;

resultsTable.water{index} = parsedData.water;
resultsTable.smoke{index} = parsedData.smoke;
resultsTable.laser{index} = parsedData.laser;

end

