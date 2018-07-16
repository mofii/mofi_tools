%  Procedure for displaying the Field II users' guide.
%
%  Calling:  field_guide ([pdf_viewer_command])
%
%  Parameters:  pdf_viewer_command is and optional argument. It's the command name of
%               an installed PDF-viewer on your system. It must be string.
%
%  Return:      The Field II guide is displayed in a separate
%               window. This demands that the users guide is available under MATLAB as
%               users_guide.pdf 
%               The PDF-viewer used is:
%               -under Windows: acroread.
%               -under Linux:   Evince, Okular or XDF, in that priority.
%               -under Mac:     The standard PDF-viewer using the 'open' command.
%
%  Version 1.01, May 6, 2011 by Joergen Arendt Jensen
%  Version 1.02, Jan 29, 2013 By MOFI. Now works on most platforms. Renamed to mofi_field_guide.m.
% 

function mofi_field_guide(command)
if nargin < 1, command = ''; end;

guide=which('users_guide.pdf');
if  isempty(guide)
    disp('The Field II users guide is not accessible under Matlab')
    disp('It should be placed in the same directory as the m-files for Field II')
    disp('and it should be called users_guide.pdf. The guide can be obtained')
    disp('from http://server.elektro.dtu.dk/personal/jaj/field/?users_guide.html')
else
    if isempty(command)
        os = computer;
        switch os
            % WIN :
          case {'PCWIN' , 'PCWIN64'}  
            cmd=['acroread ',guide,' &'];

            % Linux :
          case {'GLNX86', 'GLNXA64'}  
            if test_for_evince
                cmd=['LD_LIBRARY_PATH=/usr/lib/; evince ',guide,' &'];
            elseif test_for_okular
                cmd=['LD_LIBRARY_PATH=/usr/lib/; okular ',guide,' &'];
            else
                error(['Field II error: Could not use Evince or Okular on your system.\n ' ...
                       'Call this function again using the optional argument. See the help file.'])
            end
            
            % MAC :
          case 'MACI64'
            cmd=['open ',guide,' &'];
          otherwise
            error('Field II error: Your operating system was not recognized.')
        end
    else
        cmd = [command ' ' guide ' &'];
    end
    retval = system(cmd);
end
end

function success = test_for_evince
cmd = 'LD_LIBRARY_PATH=/usr/lib/; evince --version 1>/dev/null';
success = (system(cmd) ==0);
end

function success = test_for_okular
cmd = 'LD_LIBRARY_PATH=/usr/lib/; okular -v  1>/dev/null';
success = (system(cmd) ==0);
end

