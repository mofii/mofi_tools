function mofi_figure_set_font(varargin)
%
%  mofi_set_figure_font(key-value pair arguments)
% Arguments accepted:
%  fig_handle   -defaults to gcf.
%  font_name    -defaults to 'Times'.
%  font_size    -defaults to 16.
%  font_weight  -defaults to 'normal'.
%
% By MOFI, 2013-09-01, Init Version.
%

% Default parameters
st.fig_handle = gcf;
st.font_name  ='Times';
st.font_size  = 16;
st.font_weight = 'normal';

% Get input parameters
st = mofi_parse_input_parameters(st, varargin);

% Set properties for all text objects
set(findall(st.fig_handle,'type','text'), 'FontName',  st.font_name)
set(findall(st.fig_handle,'type','text'), 'FontSize',  st.font_size)
set(findall(st.fig_handle,'type','text'), 'FontWeight',st.font_weight)


% Set properties for the axes
st.ax_handle = findall(st.fig_handle,'type','axes');
set(st.ax_handle, 'FontName',   st.font_name)
set(st.ax_handle, 'FontSize',   st.font_size)
set(st.ax_handle, 'FontWeight', st.font_weight)
