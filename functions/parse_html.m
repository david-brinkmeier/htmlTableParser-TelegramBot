function parsedData = parse_html(htmlData)
% init result struct
parsedData = struct();

% note: decodeHTMLEntities converte html hex codes like e.g. &#x2d to hyphen minus!
rawData = cellfun(@decodeHTMLEntities, htmlData{1,4}.web4(2:end), 'un', 0);

% 3 = power1, 4 = power2, 5 = power3, 6 = temp, 7 = wassermelder, 8 = rauchmelder,  9 = laser [state]
parsedData.power1 = checkValidNumber(str2double(rawData{1}));
parsedData.power2 = checkValidNumber(str2double(rawData{2}));
parsedData.power3 = checkValidNumber(str2double(rawData{3}));
parsedData.temperature = checkValidNumber(str2double(rawData{4}));

parsedData.water = string2boolean(rawData{5});
parsedData.smoke = string2boolean(rawData{6});
parsedData.laser = string2boolean(rawData{7});
end

function result = string2boolean(string)
if strcmpi(string,'false')
    result = false;
else
    result = true;
end
end

function val = checkValidNumber(val)
if ~isnumeric(val) || ~isfinite(val)
    val = nan;
end
end

