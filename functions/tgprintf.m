function ret = tgprintf(text,disable_notify)
% Modified: David Brinkmeier, 26.08.2022
% text will be sent by the bot to the telegram group
% disableNotification set to true (bool / logical) disables message notification on smartphone 

% TGPRINTF send a message to a Telegram bot
%
% Use tgprintf() in the same way as sprintf()
% Example: tgprintf('Hello, World!');
%          tgprintf('%d + %d = %d',1,2,1+2);
% 
% Define token and chat_id before use, 
% which are the authorization token of the target Telegram bot 
% and the identifier or username of the target chat
%
% Please refer the following post 
% "Creating a Telegram bot for personal notifications"
% https://www.forsomedefinition.com/automation/creating-telegram-bot-notifications/
% 
% Seongsik Park
% seongsikpark@postech.ac.kr

switch disable_notify
    case true
        notifyString = 'true';
    case false
        notifyString = 'false';
end

% default token and chat_id
token = 'YOUR_TOKEN';
chat_id = '-YOUR_CHAT_ID';

% convert MATLAB string to url query string
sendstr = urlencode(text);
sendstr = ['https://api.telegram.org/bot',token,...
           '/sendMessage?chat_id=',chat_id,...
           '&text=',sendstr,...
           '&disable_notification=',notifyString];

% send a message   
ret = webread(sendstr); 
assert(ret.ok);

% append human readable datetime to results [Set TimeZone value to desired time zone]
ret.result.datetime=datetime(ret.result.date,'ConvertFrom','posixtime','TimeZone','Asia/Seoul');
end