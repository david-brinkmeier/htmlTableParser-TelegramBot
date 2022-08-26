%% David Brinkmeier, 19.08.2022; MATLAB R2021a Upd. 2, ver. 9.10.0.1669831
%
% This script fetches data provided by Siemens Simatic CPU using html
% Vartables ("Beobachtungsvariablen").
%
% The main logic is startRecord.m
% The table is initialized / specifid in initTable.m
% parse_html.m accesses the html table parsed by urlreadtable.m and converts strings to numbers and booleans
% updateTable.m then writes current data to the table
%
% Based on the available data a plot is generated periodically and sent to the Telegram chat
% A webcam image is grabbed periodically and sent to the Telegram chat
% Errors and Notifications are sent to the Telegram chat
% Errors are sent with notification. Notifications and Images are sent without notification (silent message).
% 
% Important: Telegram Bot Token and Chat ID is hardcoded in tgprint.m and tgprintf.m
% How to make a Telegram Bot?
% 1) Contact the Botfather https://t.me/botfather
% 2) Upon generation of your bot, you will get your Token.
% 3) Generate a Chat Group. Add your Bot to the Group and give it (admin) Access.
% 4) Add e.g. @raw_data_bot to the Group. raw_data_bot will post the chat id to the group chat.
% 5) Note the chat ID and remove raw_data_bot from the group.
% 
% Token and Chat ID should look like this
% token = '##########:AAAA_ABABABABA_#ABABABABABAababa';
% chat_id = '-#########';

%% INIT
clc
clearvars
close all
addpath(genpath(pwd))

%% SPECIFY SIEMENS VARIABLE TABLE / WEBSITE WITH A HTML TABLE
settings.url = 'http://10.69.70.7/Portal/Print.mwsl?PriNav=Vartables'; % Note: "Print" is more compact than regular http://10.69.70.7/Portal/Portal.mwsl?PriNav=Vartables

%% SETTINGS
settings.fetchEveryNSeconds = 5; % fetching html seems to require at least ~100ms, 1 second recommended.
settings.numOfIterationsPerTable = ceil((24*3600) / settings.fetchEveryNSeconds); % each full file 24 hours measurements
settings.saveBackupEveryNIteration = floor(3600 / (6*settings.fetchEveryNSeconds)); % make backup file every 10 minutes
settings.sendGraphEveryNIteration = floor(3600 / (2*settings.fetchEveryNSeconds)); % send plot every 30 minutes & send webcam image every 30 minutes if webcam exists
settings.enableTelegramNotification = true; % enable / disable telegram notifications

% FOR TESTING
% settings.numOfIterationsPerTable = 100;
% settings.sendGraphEveryNIteration = 50;
% settings.saveBackupEveryNIteration = 20;

%% START RECORDING
startRecord(settings)