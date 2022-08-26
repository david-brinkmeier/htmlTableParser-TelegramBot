function startRecord(settings)
% parse
fetchEveryNSeconds = settings.fetchEveryNSeconds;
saveBackupEveryNIteration = settings.saveBackupEveryNIteration;
sendGraphEveryNIteration = settings.sendGraphEveryNIteration;
url = settings.url;

%% SCRIPT STARTS HERE / DO NOT TOUCH
mainFolder = pwd;
[resultsTable,uuid,outputFolder] = initTable(mainFolder,settings.numOfIterationsPerTable);

% initialization
index = 1;
savecounter = 1;
time = tic;
warnTime = tic;
timeS = struct('seconds',[],'datestamp',[],'timestamp',[]);
timestamp = nan(height(resultsTable),1);

% generate and start timer
htimer = timer('ExecutionMode','fixedRate','Period',fetchEveryNSeconds,...
                'TimerFcn', {@mainLoop, 'testarg'},'StartDelay',0);
start(htimer)

    function mainLoop(~,~,arg)
        % read html data
        skip = false;
        try
            htmlData = urlreadtable(url);
        catch
            warning('could not fetch data')
            skip = true; 
            pause(1)
        end
        
        % update timestamp now
        timestamp(index) = now;
        timeS.seconds = toc(time);
        timeS.timestamp = char(datetime(timestamp(index),'ConvertFrom','datenum','Format','HH:mm:ss')); % HH:mm:ss.SSS
        timeS.datestamp = char(datetime(timestamp(index),'ConvertFrom','datenum','Format','dd.MM.yyyy'));
        
        if ~skip
            % parse html data
            parsedData = parse_html(htmlData);
            if index > 1 && (settings.enableTelegramNotification == true)
                sendTelegramStatus(parsedData,false); % sends
            end
            
            % write new data to table
            resultsTable = updateTable(resultsTable,parsedData,timeS,index);
            
            % update console
            clc
            disp(resultsTable(index,:));
            fprintf('UUID: %s, Table row %i/%i.\n',uuid,index,height(resultsTable));
            
            % export current table section if condition is met
            if index == height(resultsTable)
                fprintf('Saving full table "%s"\n',sprintf('%s\\!FULL_RESULTS_%s.xlsx',outputFolder,uuid));
                writetable(resultsTable,sprintf('%s\\!FULL_RESULTS_%s.xlsx',outputFolder,uuid));
            end
            if mod(index,saveBackupEveryNIteration) == 0
                fprintf('Saving intermediate backup "%s"\n',sprintf('%s\\%i.xlsx',outputFolder,savecounter));
                writetable(resultsTable((index-saveBackupEveryNIteration+1):index,:),...
                    sprintf('%s\\%i.xlsx',outputFolder,savecounter));
                savecounter = savecounter + 1;
                if index > 1 && (settings.enableTelegramNotification == true)
                    sendTelegramStatus(parsedData,true);
                end
            end
            if mod(index,sendGraphEveryNIteration) == 0
                if index > 1 && (settings.enableTelegramNotification == true)
                    sendPlot();
                    sendWebcamImage();
                end
            end
            
            % advance index
            index = index + 1;
            if index > height(resultsTable)
                % reinit!
                [resultsTable,uuid,outputFolder] = initTable(mainFolder,settings.numOfIterationsPerTable);
                index = 1;
                savecounter = 1;
                time = tic;
                timestamp = nan(height(resultsTable),1);
            end
        end
    end

%% TELEGRAM
% When backup table is saved send status update to Telegram
% If ERROR then send ERROR with Notification every 20 seconds
    function sendTelegramStatus(parsedData,sendUpdate)
        warnUser = false;
        
        laserStr = 'ON';
        if parsedData.laser == false
            laserStr = 'OFF';
            warnUser = true;
        end
        
        waterStr = 'OK';
        if parsedData.water == false
            waterStr = 'HOLT DAS SCHLAUCHBOOT!';
            warnUser = true;
        end
        
        smokeStr = 'OK';
        if parsedData.smoke == false
            smokeStr = 'ALARM. ALAAAAAARM!';
            warnUser = true;
        end
                
        try
            switch warnUser
                case true
                    str = sprintf('FEHLER --- Laser [%s] Wasser [%s] Rauch [%s]. | %s', laserStr, waterStr, smokeStr, sprintf(datestr(now)));
                    if toc(warnTime) > 60
                        warning('Something is Wrong - Sending Telegram Notification!')
                        tgprintf(str,false);
                        sendWebcamImage();
                        warnTime = tic; % reset warnTimer
                    end
                case false
                    if sendUpdate == true
                        str = sprintf('ALLES OK --- Laser [%s] Wasser [%s] Rauch [%s]. | %s', laserStr, waterStr, smokeStr, sprintf(datestr(now)));
                        tgprintf(str,true);
                    end
            end
        catch
            warning('Something failed sending message via Telegram.')
        end
    end

    function sendPlot()
        try
            timeAxis = datetime(timestamp(1:index),'ConvertFrom','datenum');
            f = figure;
            hold on
            
            plot(timeAxis, cell2mat(resultsTable.power1(1:index)))
            plot(timeAxis, cell2mat(resultsTable.power2(1:index)))
            plot(timeAxis, cell2mat(resultsTable.power3(1:index)))
            ylabel('Power [a.u.]')
            
            yyaxis right
            plot(timeAxis, cell2mat(resultsTable.temperature(1:index)))
            ylabel('Temperature [°C]')
            
            legend pwr1 pwr2 pwr3 temp
            box on
            tgprint(f, 'photo', true)
            close(f)
        catch
            warning('Something went wrong sending plot.')
        end
    end

    function sendWebcamImage()
        try
            camList = webcamlist;
            if ~isempty(camList)
                cam = webcam(1);
                img = insertText(snapshot(cam), [0 0], datestr(now,'dd.mm - HH:MM:SS'), ...
                    'AnchorPoint','LeftTop', 'BoxColor', 'white', 'fontsize', 30);
                tgprint(img, 'photo', true)

                % OLD VARIANT; insertText requires vision toolbox tho
                %     img = snapshot(cam);
                %     f = figure;
                %     f.InvertHardcopy = 'off';
                %     f.Color = 'k';
                %     imshow(img)
                %     title(datestr(now),'Color','w')
                % tgprint(gcf, 'photo', true)
                %     close(f)

                clear cam
            end
        catch
            warning('Something went wrong grabbing webcam image.')
        end
    end

%% USER INPUT FOR STOPPING
answer = questdlg('Stop recording?', ...
    'SIMATIC RECORDER', ...
    'STOP RECORD','STOP RECORD');

% Handle response
switch answer
    case 'STOP RECORD'
        warning('RECORDING STOPPED. PLEASE WAIT.')
        stop(htimer)
        fprintf('Saving full table "%s"\n',sprintf('%s\\!FULL_RESULTS_%s.xlsx',outputFolder,uuid));
        if index > height(resultsTable)
            index = height(resultsTable);
        end
        writetable(resultsTable(1:index,:),sprintf('%s\\!FULL_RESULTS_%s.xlsx',outputFolder,uuid));
        delete(htimer)
end

end