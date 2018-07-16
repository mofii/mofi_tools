function mofi_tikz_export(filename, fig_dir, varargin)
% Export to both a Tikz-file and a PDF-file compiled from Tikz.
%
% mofi_tikz_export(filename [,fig_dir, matlab2tikz-arguments])
%
% By MOFI, 2014-04-10
% Updated 2014-05-01 to have at least minimum support for Windows (untestet).
% 2014-05-11, can now pass arguments directly to matlab2tikz. example:
%     mofi_tikz_export('name', 'figures', 'parseStrings', false).
%
% TODO: 
%  - Use mofi_parse_input_parameters.
%  - Have figure size as parameter.
%  - Save same size as shown on screen.

if nargin < 2
    fig_dir = '.';
end

if sum(strcmp('debug',varargin)) > 0,
    debug_mode = 1;
    varargin(strcmp('debug',varargin)) = [];
else
    debug_mode = 0;
end

if debug_mode, disp 'mofi_tikz: Init.'; end

% Get original formatting
format_old = get(0,'format');
% set short formatting - otherwise LaTeX panics!
format short

% $$$ textlength = 18.1353;           % IEEE Journal textlength in centimeters
% $$$ width      = 0.45*textlength;   % Figures for single column
% $$$ height     = width*0.75;        % Approximated
                                

fig_num = gcf;
papersize = get(fig_num, 'PaperSize');
paperunit = get(fig_num, 'PaperUnits');

if strcmp(paperunit, 'inches')
    unit = 'in';
elseif strcmp(paperunit, 'centimeters')
    unit = 'cm';
else
    error('Error: unknown unit in figure(%.0f): %s\nUse mofi_figure_set_size(x,y) to set the figure size.', fig_num.Number, paperunit)
end

width  = sprintf('%.3f%s',papersize(1),unit);
height = sprintf('%.3f%s',papersize(2),unit);


if debug_mode, disp 'mofi_tikz: Making tikz file'; end

% Make tikz figure to include in LaTeX
matlab2tikz([filename '.tikz'], ...
            'width', width, ...
            'height', height, ...
            'showInfo',false, ...
            varargin{:}, ...
            'parseStringsAsMath',false);


% Make PDf figure to include everywhere
if debug_mode, disp 'mofi_tikz: Making TeX-file'; end
matlab2tikz([ filename '.tex'], ...
            'showInfo',false, ...
            'parseStringsAsMath',false, ...
            'standalone',true, ...
            'strictFontSize', false, ...
            'height', height, ...
            'width',  width, ...
            varargin{:}, ...
            'extraCode','\pgfplotsset{every axis/.append style={font=\fontsize{12pt}{1em}\selectfont}}\usepackage{textcomp}');


%% Move and delete files
os = computer;
switch os
  case {'PCWIN' , 'PCWIN64'} % We're in Windows
    if debug_mode, disp 'mofi_tikz: compiling TeX-file'; end
    system(sprintf('pdflatex %s.tex', filename));
    if ~strcmp(fig_dir, '.')
        if debug_mode, disp 'mofi_tikz: Moving PDF file and cleaning up.'; end
        system(sprintf('move %s.pdf %s\', filename, fig_dir));
        system(sprintf('move %s.tikz %s\', filename, fig_dir));
        system(sprintf('move %s.tex %s\', filename, fig_dir));
        system(sprintf('move %s.log %s\', filename, fig_dir));
        system(sprintf('move %s-*.png%s\', filename, fig_dir));
    end
  otherwise  % MAC and GNU/Linux
    if debug_mode, disp 'mofi_tikz: compiling TeX-file'; end
    system(sprintf('pdflatex %s.tex >/dev/null', filename));
    system(sprintf('rm %s.aux', filename));
    if ~strcmp(fig_dir, '.')
        if debug_mode, disp 'mofi_tikz: Moving PDF file and cleaning up.'; end
        system(sprintf('mv %s{''.pdf'',''.tikz'',''.tex'',''.log''} %s/', filename, fig_dir));
        system(sprintf('mv %s-*.png %s/ 2> /dev/null', filename, fig_dir)); %If PNG files exit,
                                                                            %move them. Don't
                                                                            %complain if they don't.
    end
end


% restore format
set(0,'format', format_old);
