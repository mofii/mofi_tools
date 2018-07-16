function apo = mofi_vs_apo(points, varargin)
%
% apo = mofi_vs_apo(points, paramter-value pairs)
%
% Input parameters:
%        points: 3xN vector = [x y z]                             [m]
%            vs: 3x1 coordinate of the virtual source/focus point [m]
%    xdc_center: 3x1 coordinate of aperture center                [m]
%     min_width: 1x1 Minimum width of the apodization (at focus)  [m]
%         alpha: 1x1 Acceptance angle of the apodization          [deg]
%   window_type: 'Hanning' is standard. See help file of mofi_window.
%  window_param: Only used for Blackman and Tukey. See help file of mofi_window.
%
% Example:
%   points = [linspace(-50,50,100); zeros(1,100); 40*ones(1,100)]*1e-3;
%   apo = mofi_vs_apo(points, 'vs', [0 0 30e-3], 'alpha',30, 'xdc_center',[-3 -2 0]/1e3);
%
% 2013-09-15, Mofi, Version 1.0  
% 2013-09-19, Mofi, Version 1.1, Renamed to mofi_vs_apo.
% 2014-05-06, Mofi, Version 1.2, Now works when xdc_center is not at origo. Now expects
%                                3xN vectors instead of Nx3.
%

if nargin == 0
    mofi_vs_apo_test;
    name = mfilename;
    help (name)
    return
end



% Input parameters
st.vs           = [0 0 0]';
st.xdc_center   = [0 0 0]';
st.alpha        = 55;
st.min_width    = 3e-3;
st.debug        = 0;
st.window_type  = 'Hanning';
st.window_param = 1.5;

% Parse Input Parameters
st = mofi_parse_input_parameters(st, varargin);


%% Input verification
[num_dim num_points]= size(points);
if num_dim ~= 3
    error('Size of points must be Nx3. Size was: %ix%i.', num_points, num_dim)
end

[vs_dim1 vs_dim2]= size(st.vs);
if vs_dim1 ~= 3 && vs_dim2 ~= 1
    error('Dimension of VS must be 3x1, it was: %ix%i.', vs_dim1, vs_dim2)
end
[xdc_dim1 xdc_dim2]= size(st.xdc_center);
if vs_dim1 ~= 3 && vs_dim2 ~= 1
    error('Dimension of xdc_center must be 3x1, it was: %ix%i.', xdc_dim1, xdc_dim2)
end


%% Offset all coordinates
points = points-repmat(st.xdc_center, 1,num_points);
st.vs  = st.vs - st.xdc_center;
st.xdc_center = [0 0 0]';

%calc center line
c_line = st.vs - st.xdc_center;
c_line = c_line./norm(c_line);

% distance from VS to point projected onto center line
p_proj = mofi_dot_fast( repmat(c_line,1,num_points) , points);

% scale the unit vector
p_center = repmat(c_line,1,num_points) .* repmat(p_proj,3,1);

% distance between the two points (norm of difference)
%vs_dist = mofi_norm_fast( repmat(st.vs,1,num_points) - points );
vs_dist = mofi_norm_fast( repmat(st.vs,1,num_points) - p_center );

% max allowed distance from line (width of apodization)
max_dist  = tand(st.alpha) * vs_dist;
% make sure apodization is not too narrow
max_dist(max_dist<st.min_width) = st.min_width;

%% distance from point to center line 
% cross product
b = points;
c = points-repmat(c_line, 1,num_points);
a = mofi_cross_fast(b,c);
%norm
line_dist = mofi_norm_fast(a);
% normalised distance
line_dist_n = line_dist./max_dist;

% get the actual apodization
apo = mofi_window(st.window_type, line_dist_n, st.window_param)';
apo(line_dist_n>1) = 0;


% Debug plots
if st.debug
    if num_points == 1e6
        figure;imagesc(reshape(p_proj,1e3,1e3)');     axis image;title('p project')
        figure;imagesc(reshape(max_dist,1e3,1e3)');   axis image;title('Max dist')
        figure;imagesc(reshape(line_dist,1e3,1e3)');  axis image;title('line dist')
        figure;imagesc(reshape(line_dist_n,1e3,1e3)');axis image;title('Normalized line dist')
        %figure;imagesc(reshape(apo,1e3,1e3)');axis image;        title('APO')
    else        
        figure;plot(line_dist, '.-');  title('line dist')
        figure;plot(line_dist_n, '.-');title('Normalized line dist')
        figure;plot(max_dist, '.-');   title('Max dist')
        figure;plot(apo, '.-');        title('APO')
    end
end
end





%% Test Function
function mofi_vs_apo_test

vs         = [5e-3 0e-3 25e-3]';
alpha      = 35;
xdc_center = [20 0 0]'*1e-3;
min_width  = 3e-3;
window_type= 'Tukey';


x_ar = linspace(-100, 100, 1000)/1e3;
y_ar = 0;
z_ar = linspace(0, 120, 1000)/1e3;
[X, Y, Z] = meshgrid(x_ar, y_ar, z_ar);
points = [X(:) Y(:) Z(:)]';
apo = mofi_vs_apo(points, 'vs', vs, ...
                'alpha',      alpha, ...
                'xdc_center', xdc_center, ...
                'min_width',  min_width, ... 
                'debug', 0, ...
                'window_type', window_type);
apo = reshape(apo, size(X))';
figure;
imagesc(x_ar*1e3, z_ar*1e3, apo)
xlabel('x-axis [mm]')
ylabel('z-axis [mm]')
hold on
plot(vs(1)*1e3, vs(3)*1e3, 'k*', 'MarkerSize', 10, 'LineWidth',2)
plot(xdc_center(1)*1e3, xdc_center(3)*1e3, 'k*', 'MarkerSize', 10, 'LineWidth',2)
axis equal
axis image


x_ar = linspace(-100, 100, 1000)/1e3;
y_ar = linspace(-100, 100, 1000)/1e3;
z_ar = 80e-3;
[X, Y, Z] = meshgrid(x_ar, y_ar, z_ar);
points = [X(:) Y(:) Z(:)]';

apo = mofi_vs_apo(points, ...
                'vs',         vs, ...
                'alpha',      alpha, ...
                'xdc_center', xdc_center, ...
                'min_width',  min_width, ... 
                'window_type', window_type);

apo = reshape(apo, size(X));
figure;
imagesc(x_ar*1e3, y_ar*1e3, apo)
xlabel('x-axis [mm]')
ylabel('y-axis [mm]')
axis equal
axis image



end
