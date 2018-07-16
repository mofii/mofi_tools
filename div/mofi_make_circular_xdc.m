function th = mofi_make_circular_xdc(varargin)
%function st = mofi_make_circular_xdc(options)
%
%
% Options:
%     diameter: Diameter of the XDC in the x-y-plane (45mm)
% focal_length: Focal length (50mm)
% num_math_elm: Approx. number of math elements in the XDC (10k)
%    direction: Pointing direction of the XDC ([0 0 1])
%       offset: Offset/translation of the XDC ([0 0 0])
%      plot_on: Enable 3D plot of XDC (false)
%
% Version 1.0 2017/12/04 MOFI. Init version.

% Defaults
opt.diameter     = 45e-3; %m
opt.focal_length = 50e-3; %m
opt.num_math_elm = 10e3;
opt.direction    = [0 0 1];
opt.offset       = [0 0 0];
opt.plot_on      = false;

opt    = mofi_parse_input_parameters(opt, varargin);
opt.x0 = opt.offset;


% make maxtrix of math elements based on radius of XDC
xdc_area       = pi*(opt.diameter/2)^2;
math_width     = sqrt(xdc_area/opt.num_math_elm);
num_math_width = ceil(opt.diameter/math_width);
math_width     = opt.diameter/num_math_width;

x = (-opt.diameter/2:math_width:opt.diameter/2);
y = (-opt.diameter/2:math_width:opt.diameter/2);
[ctr_x, ctr_y] = meshgrid(x, y);

% Prune to element within the circle
prune = sqrt(ctr_x.^2 + ctr_y.^2) > opt.diameter/2;
ctr_x(prune) = [];
ctr_y(prune) = [];

% Make corners (BL TL TR BR)
dx = math_width/2-eps;
dy = math_width/2-eps;
corner1 = zeros(length(ctr_x(:)), 3);
corner2 = zeros(length(ctr_x(:)), 3);
corner3 = zeros(length(ctr_x(:)), 3);
corner4 = zeros(length(ctr_x(:)), 3);
for idx=1:length(ctr_x(:))
    corner1(idx,:) = [ctr_x(idx)-dx ctr_y(idx)-dy 0];
    corner2(idx,:) = [ctr_x(idx)-dx ctr_y(idx)+dy 0];
    corner3(idx,:) = [ctr_x(idx)+dx ctr_y(idx)+dy 0];
    corner4(idx,:) = [ctr_x(idx)+dx ctr_y(idx)-dy 0];
end


% project math elements onto perfect transducer(Spheroid)
% Focal point is at origo, elements is at positive z.
ctr_z = -sqrt((opt.focal_length^2 -ctr_x.^2 -ctr_y.^2));
center_elm = [ctr_x' ctr_y' ctr_z'];

for idx=1:length(ctr_x(:))
    corner1(idx,3) = -sqrt((opt.focal_length^2 -corner1(idx,1)^2 -corner1(idx,2)^2));
    corner2(idx,3) = -sqrt((opt.focal_length^2 -corner2(idx,1)^2 -corner2(idx,2)^2));
    corner3(idx,3) = -sqrt((opt.focal_length^2 -corner3(idx,1)^2 -corner3(idx,2)^2));
    corner4(idx,3) = -sqrt((opt.focal_length^2 -corner4(idx,1)^2 -corner4(idx,2)^2));
end

% Rotate all elements
center_xdc = [0,0,-opt.focal_length];
for idx=1:size(center_elm,1)
    center_elm(idx,:)  = mofi_rotate_vec_by_vec(center_elm(idx,:)',  opt.direction')';
    corner1(idx,:) = mofi_rotate_vec_by_vec(corner1(idx,:)', opt.direction')';
    corner2(idx,:) = mofi_rotate_vec_by_vec(corner2(idx,:)', opt.direction')';
    corner3(idx,:) = mofi_rotate_vec_by_vec(corner3(idx,:)', opt.direction')';
    corner4(idx,:) = mofi_rotate_vec_by_vec(corner4(idx,:)', opt.direction')';
end
center_xdc = mofi_rotate_vec_by_vec(center_xdc',  opt.direction')';


% Translate all elements
center_elm  = center_elm + repmat(opt.offset, [size(center_elm,1), 1]);
corner1     = corner1    + repmat(opt.offset, [size(center_elm,1), 1]);
corner2     = corner2    + repmat(opt.offset, [size(center_elm,1), 1]);
corner3     = corner3    + repmat(opt.offset, [size(center_elm,1), 1]);
corner4     = corner4    + repmat(opt.offset, [size(center_elm,1), 1]);
center_xdc  = center_xdc + opt.offset;
focus       = [0 0 0]    + opt.offset;

% Register elements with Field 2
phys_idx = ones(size(center_elm,1),1);
apo      = ones(size(center_elm,1),1);
width    = math_width*ones(size(center_elm,1),1);
height   = math_width*ones(size(center_elm,1),1);
rect     = [phys_idx, corner1, corner2, corner3, corner4, ...
            apo, width, height, center_elm];

th = xdc_rectangles(rect, center_xdc, focus);




if opt.plot_on
    %    figure
    hold on
    drawnow
    for idx = 1:size(corner1,1)
        surf([corner1(idx,1), corner4(idx,1); corner2(idx,1), corner3(idx,1)]*1e3, ...
             [corner1(idx,2), corner4(idx,2); corner2(idx,2), corner3(idx,2)]*1e3, ...
             [corner1(idx,3), corner4(idx,3); corner2(idx,3), corner3(idx,3)]*1e3, ...
             'edgecolor', 'none')
    end
    axis equal
    view(3)
    grid on
    box on
    plot3(0,0,0,'o')
    xlabel('x-axis')
    ylabel('y-axis')
    zlabel('z-axis')
end

