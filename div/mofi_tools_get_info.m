function st = mofi_tools_get_info()
% st = mofi_tools_get_info()
% Returns a struct containing info about the CFUtools repository.
%
% The struct contains the following members:
%      revision : Revision of the checked out repository
%          date : Date of the last (checked in) change.
%          path : path to CFUtools 
%           url : location of repository on the server
%   last_author : Last author to edit in the repository
%          uuid : universally unique identifier of the repository
%
% 2013-06-25, Mofi, Init version.
% 2014-03-02, Mofi, Made the parsing more robust. Now also works on Mac OSX.
%
% TODO: Handle extra Windows new-line character when parsing.
%

dir_ending = ['div' filesep 'mofi_tools_get_info.m'];
mofitools_dir = strtrim(which(mfilename));
mofitools_dir = cfutools_dir(1:end-length(dir_ending));

[val str] = system(sprintf('svn info %s', mofitools_dir));
if val ~=0, warning('Could not get info on the CFUtools repository.'); end


% Get each line. This might not work on Windows
line_breaks = get_line_breaks(str);
line_start = 1;
line_end   = 1;
for idx = 1:length(line_breaks)
    line_end   = line_breaks(idx)-1;
    line{idx}  = str(line_start:line_end);
    line_start = line_breaks(idx)+1;
end



% Get the parameters
st.revision    = [];
st.date        = [];
st.path        = [];
st.url         = [];
st.last_author = [];
st.uuid        = [];

for idx=1:length(line)
    tmp = line{idx};
    sep = strfind(tmp, ': ');
    param = tmp(1:sep-1);
    val   = tmp(sep+2:end);
    
    if strcmp(param,'Revision')
        st.revision = str2num(val);
    elseif strcmp(param,'Last Changed Date')
        st.date = val;
    elseif strcmp(param,'Working Copy Root Path')
        st.path = val;
    elseif strcmp(param,'URL')
        st.url = val;
    elseif strcmp(param,'Last Changed Author')
        st.last_author = val;
    elseif strcmp(param,'Repository UUID')
        st.uuid = val;
    end
end

end




function line_breaks = get_line_breaks(str)
line_breaks = find(str == sprintf('\n'));
end
