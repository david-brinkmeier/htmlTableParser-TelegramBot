function tgprint(fighandle_or_img, option, disable_notify)
% Modified: David Brinkmeier, 26.08.2022
% TGPRINT send an image to a Telegram bot
%
% Use tgprintf() in the same way as sprintf()
% Example: figure(1); plot(x,y);
%          tgprint();
% 
% There are two sending modes:
% (1) tgprint('photo'): send an image w/ compression using sendPhoto
% (2) tgprint('document'): send an image w/o compression using sendDocument
% 
% Define token and chat_id before use, 
% which are the authorization token of the target Telegram bot 
% and the identifier or username of the target chat
%
% 
% This also uses urlreadpost by Dan Eills
% https://www.mathworks.com/matlabcentral/fileexchange/27189-urlreadpost-url-post-method-with-binary-file-uploading
% 
% Seongsik Park
% seongsikpark@postech.ac.kr

switch disable_notify
    case true
        notifyString = 'true';
    case false
        notifyString = 'false';
end

filename = 'temp.png';
if ishandle(fighandle_or_img)
    print(fighandle_or_img,filename,'-dpng');
else
    imwrite(fighandle_or_img,filename);
end
f = fopen(filename,'rb');
d = fread(f,Inf,'*uint8')';
fclose(f);

% default token and chat_id
token = 'YOUR_TOKEN';
chat_id = '-YOUR_CHAT_ID';

if strcmpi(option,'photo')
    sendstr = ['https://api.telegram.org/bot',token,'/sendPhoto'];
    urlreadpost(sendstr,{'chat_id',chat_id,'photo',d,'disable_notification',notifyString}); 
else
    sendstr = ['https://api.telegram.org/bot',token,'/sendDocument'];
    urlreadpost(sendstr,{'chat_id',chat_id,'document',d,'disable_notification',notifyString}); 
end

end
