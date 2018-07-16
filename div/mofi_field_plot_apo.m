%
% mofi_field_plot_apo.m
% This script plots the transducer layout and indicates each element's current apodization.
%
%  mofi_field_plot_apo (th [,key-value options])
%
%         th: Transducer handle
% edge_color: String or 1x3 vector setting the edge color. 
%             Examples: 'None', 'b', 'r', [0.2 0.4 0.95]. 
%             edge_color defaults to 'none'.
%       mode: 'phys_elm' -will plot the apodization of the physical elements. Is
%                         the standard.
%             'mat_elm'  -will plot the apodization of the mathematical elements.
%             'both'     -will plot the multiplication of the mathematical and physical
%                         element apodization.
%       
%
% Example:
%      mofi_field_plot_apo (th)  % which is the same as:
%      mofi_field_plot_apo (th 'mode','both', 'edge_color','none')
%
%
% By Morten F. Rasmussen, 
% Version 1.0  2011-03-10 Init version
% Version 1.1  2011-11-09 Removed edge color
% Version 1.2  2014-02-19 Added edge_color as second argument. Renamed the function.
% Version 2.0  2014-02-21 Is now extremely fast. Can now plot both mathematical element
%                         apodization and physical element apodization. Renamed again.
% Version 2.1  2014-03-06 Removed rounding on ticks, but kept rounding on tick-labels.
%                         edge_color now defaults to 'none'.
% Version 2.2  2014-03-10 Fixed a bug. Now plots the correct mathematical apodization :)
% Version 2.3  2014-10-23 Fixed a major bug. Now works with arbitrary number of
%                         mathematical elements :)

function mofi_field_plot_apo (th, varargin)

st.edge_color = 'none';
st.mode       = 'both';
st.elm_ar     = [];
st = mofi_parse_input_parameters(st, varargin);
if strcmp(st.mode, 'phys_elm')
    mat_elm_mode = 0;
elseif strcmp(st.mode, 'mat_elm')
    mat_elm_mode = 1;
elseif strcmp(st.mode, 'both')
    mat_elm_mode = 2;
else
    error('mode must be set to either ''phys_elm'', ''mat_elm'' or ''both''')
end


% Get XDC data / info
data = xdc_get(th,'rect');
if isempty(data)
    data = xdc_get(th,'lin');
    if ~isempty(data)
        error('This function does not work with ''use_lines'' enabled.')
    else
        data = xdc_get(th,'tri');
        if ~isempty(data)
            error('This function does not work with ''use_triangles'' enabled.')
        else
            error('No data about the transducer was found.')
        end
    end
end


apo              = xdc_get(th, 'apo');
apo              = apo(2:end); % remove time
num_mat_elements = size(data,2);
num_elements     = size(apo,1);
num_mat_per_elem = num_mat_elements/num_elements;
hold on;

mat_apo_local = [];

% set which elements should be plotted
if isempty(st.elm_ar)
    st.elm_ar = 1:num_elements;
end


% Plot elements
elm_idx=1;
x_sub = zeros(num_mat_per_elem,4);
y_sub = zeros(num_mat_per_elem,4);
z_sub = zeros(num_mat_per_elem,4);
%for elem_i=1:num_elements  %num_mat_elements,
for elem_i=st.elm_ar,
    c = apo(elem_i)*ones(2,2);
    for mat_elm_i = 1:num_mat_per_elem
        info_i = (elem_i-1)*num_mat_per_elem+mat_elm_i;
        x_sub(mat_elm_i,1:4) = [data(11,info_i), data(20,info_i),  data(14,info_i), data(17,info_i)];
        y_sub(mat_elm_i,1:4) = [data(12,info_i), data(21,info_i),  data(15,info_i), data(18,info_i)];
        z_sub(mat_elm_i,1:4) = [data(13,info_i), data(22,info_i),  data(16,info_i), data(19,info_i)];
        mat_apo(mat_elm_i)   = data(5,info_i);
    end
    
    % Round off numerical errors
    x_sub = round(x_sub*1e15)/1e15;
    y_sub = round(y_sub*1e15)/1e15;
    z_sub = round(z_sub*1e15)/1e15;

    % Make mesh grid
    x_uniq = unique(x_sub(:));
    y_uniq = unique(y_sub(:));
    z_uniq = unique(z_sub(:));
    N_x = length(x_uniq);
    N_y = length(y_uniq);
    N_z = length(z_uniq);
            
    % Make z-coordinate
    % Field outputs corners as: [BL BR TL TR] (B=bottom, T=top, L=left, R=right)
    idx_elm    = [1:N_x-1 N_x-1];
    idx_elm    = repmat(idx_elm, [N_y-1 1]) + (0:N_y-2)'*ones(1,N_x)*(N_x-1);
    idx_elm    = [idx_elm; idx_elm(end,:)];
    
    idx_corner = [ones(1,N_x-1) 2];
    idx_corner = repmat(idx_corner, [N_y-1 1]);
    idx_corner = [idx_corner; idx_corner(end,:)+2];

    idx = sub2ind(size(z_sub), idx_elm, idx_corner);
    z2 = z_sub(idx);
    %c2 = ones(size(z2))*apo(elem_i);
    %c3 = data(5,idx_elm);

    % Choose mat-element apo or full element apo
    if mat_elm_mode == 0 
        c = ones(num_mat_per_elem,1)*apo(elem_i);
    elseif mat_elm_mode == 1
        c = mat_apo(:);
    else
        c = (ones(num_mat_per_elem,1)*apo(elem_i)).* mat_apo';
    end
    

    % Reorder from Field II indexing to MATLAB indexing
    size_z = size(z2);
    size_c = (size_z - [1 1]);
    c=reshape(c, size_c);
    c=transpose(reshape(c(:), fliplr(size_c) ));
    

% $$$     ['x ' mat2str(size(x_uniq)) ' y ' mat2str(size(y_uniq))  ' z ' ...
% $$$      mat2str(size(z2)) ' c ' mat2str(size(c)) ' apo ' mat2str(size(apo)) ...
% $$$      ' matapo ' mat2str(size(mat_apo))]
% $$$ 
    
    surf(x_uniq*1e3,y_uniq*1e3,z2*1e3,c, 'EdgeColor', st.edge_color);
    hold on
    %keyboard
end

%return
cbh = colorbar;
ylabel(cbh,'Apodization value')
caxis([0 1])
xlabel('x [mm]')
ylabel('y [mm]')

% Set Tick marks
x_all = [data(11,:), data(20,:),  data(14,:), data(17,:)];
y_all = [data(12,:), data(21,:),  data(15,:), data(18,:)];
z_all = [data(13,:), data(22,:),  data(16,:), data(19,:)];

x_min = min(x_all(:));
x_max = max(x_all(:));
y_min = min(y_all(:));
y_max = max(y_all(:));
z_min = min(z_all(:));
z_max = max(z_all(:));

x_tick = [x_min (x_min+x_max)/2 x_max]*1e3;
y_tick = [y_min (y_min+y_max)/2 y_max]*1e3;
z_tick = [z_min (z_min+z_max)/2 z_max]*1e3;
% Round to tenth millimeter
x_tick_r = round(x_tick*10)/10;
y_tick_r = round(y_tick*10)/10;
z_tick_r = round(z_tick*10)/10;
% Make Tick Labels
for idx = 1:3
    str_x = sprintf('%.1f', x_tick_r(idx));
    str_y = sprintf('%.1f', y_tick_r(idx));
    str_z = sprintf('%.1f', z_tick_r(idx));
    xticklabel(idx, 1:length(str_x)) = str_x;
    yticklabel(idx, 1:length(str_y)) = str_y;
    zticklabel(idx, 1:length(str_z)) = str_z;
end

set(gca, 'xtick' , x_tick);
set(gca, 'ytick' , y_tick);
set(gca, 'xticklabel' , xticklabel);
set(gca, 'yticklabel' , yticklabel);

if N_z > 1
    zlabel('z [mm]')
    view(3)
    set(gca, 'ZTick' , z_tick*1e3);
    set(gca, 'zticklabel' , zticklabel);
else 
    view(2)
end


grid off;
box on
axis equal
axis image
ax = axis;
axis(ax*1.05)
hold off;

colormap (flipud(thermal(100)))

%figure;plot(mat_apo)
%figure;imagesc(c);figure;plot(c(:))
