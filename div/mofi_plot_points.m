function mofi_plot_points(x, varargin)
% plot_points(x, varargin)
% Plots an array of points using plot or plot3.
% Varargin can be used to pass arguments to plot.
%
% Input vector must be a 2xN or 3xN vector.
%
% Example: 
%  x = randn(3,10);
%  figure, plot_points(x, 'ro')
%

sz = size(x);
if sz(1) ~= 3 && sz(1) ~= 2, error('Only accepts 2xN and 3xN vectors.'); end
    
hold on
if sz(1) == 3
    if ~isempty(varargin)
        for idx = 1:sz(2)
            plot3(x(1,idx),  x(2, idx),  x(3, idx), varargin{:})
        end    
    else
        for idx = 1:sz(2)
            plot3(x(1, idx),  x(2, idx),  x(3, idx), '.')
        end
    end
else
    if ~isempty(varargin)
        for idx = 1:sz(2)
            plot(x(1, idx),  x(2, idx), varargin{:})
        end    
    else
        for idx = 1:sz(2)
            plot(x(1, idx),  x(2, idx), '.')
        end
    end
end    
