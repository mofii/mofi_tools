function error = mofi_multi_node_handling(save_path, clean_tmp_files)
%
%  error = mofi_multi_node_handling(save_path [,clean_tmp_files])
%
%  This function works on all common operating systems, except M$ Windows.
%
%  Input:
%     - save_path      : string containing the save path
%     - clean_tmp_files: boolean controlling whether or not touched files are 
%                        removed again. Std = false.
%
%  returns: 0 on success(=nobody is working on file)
%           1 on error(somebody else is working on file)
%
%  By Morten F. Rasmussen
%  Version 1.0 Init version, 2011-12-07
%  Version 1.1 Added hostname to temp-string (it might be interesting to see who
%              calculated what. To actually see this, 'clean_tmp_files' must be 
%              set false.), 2012-01-12
%  Version 1.2 Changed to state-machine and added local random stream. 2012-01-12
%  Version 1.3 Added two extra waiting states -just to make sure we REALLY are the only one working on this
%              file. 2013-03-26
%  Version 1.5 Made the random ID persistent within each MATLAB session by using a
%              global variable.
%  Version 1.6 Forces file ending to be ''.mat'', 2017-03-15.
%



% make sure random generator differs on each worker
seed = sum(clock)*1e7;
seed = mod(seed,2^32); % limit to 2^32-1
% make new stream. We don't want to meas with standard stream.
stream1 = RandStream('mt19937ar','Seed',seed); 

% define inline functions
wait  = @(stream)      pause(rand(stream,1)*0.8+0.03); %wait from 0.03 to 0.8 sec.
touch = @(unique_path) system(sprintf('touch %s', unique_path));

% define input variable, if not given
if nargin < 2 
    clean_tmp_files = 0;
end


% remove spaces in save_path
save_path(save_path == ' ') = '_';
% make sure path includes file ending
if ~strcmp(save_path(end-4:end), '.mat')
    save_path = [save_path '.mat'];
end

% Add a unique ID and hostname to save_path
global mofi_multinode_handling_rand_id
if length(mofi_multinode_handling_rand_id) ==0
    mofi_multinode_handling_rand_id = round(rand(stream1,1)*1000000000);
end
[reteval host_name] = system('echo $HOSTNAME');
if length(host_name) < 2, error('could not get host name.'); end;
host_name = host_name(1:end-1); % remove newline
unique_path = sprintf('%s_%i_%s', save_path, mofi_multinode_handling_rand_id, host_name);

state = 'no_workers1';
while true 
    switch state
      case 'no_workers1' 
        if  no_workers(save_path) > 0
            error = 1; % someone else is already working on file
            break;
        else
            touch(unique_path);
            state = 'wait1';
        end
        
      case 'wait1'
        wait(stream1);
        state = 'no_workers2';
        
      case 'no_workers2'
        if no_workers(save_path) > 1
            delete(unique_path);
            wait(stream1);
            state = 'no_workers1';
        else
            wait(stream1);
            state = 'no_workers3';
        end

        
      case 'no_workers3'
        if no_workers(save_path) > 1
            delete(unique_path);
            wait(stream1);
            state = 'no_workers1';
        else
            wait(stream1);
            state = 'no_workers4';
        end
        
      case 'no_workers4'
        if no_workers(save_path) > 1
            delete(unique_path);
            wait(stream1);
            state = 'no_workers1';
        else
            wait(stream1);
            state = 'no_workers5';
        end
        
      case 'no_workers5'
        if no_workers(save_path) > 1
            state = 'wait1';
        else
            % success, start working
            error = 0; 
            touch(save_path);
            if clean_tmp_files
                try delete(unique_path);
                catch me
                    warning('Could not delete temp. files.')
                end
            end
            break;
        end
      otherwise error('should not end in this state...');
    end
end
end



function out = no_workers (str)
[retval out_str] = system(sprintf('ls -l %s* 2>/dev/null | wc -l', str));
out = sscanf(out_str, '%i'); % string to double
end

