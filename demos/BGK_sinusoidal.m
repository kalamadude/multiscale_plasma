%%%--------------------------------------------------------------------%%%
%
% Sinusoidal initial conditions to test poisson plasma oscillation case.
% TURN OFF BGKCollide in the BGK function before running to get the
% collisionless result!
%
% Specifying domain paremeters allows for flexible testcase creation.
% Default values are included in the template (as comments)
%
% Everything is in dimensionless units based on the ion-circle radius,
% mass, charge, and plasma frequency of arbitrary reference parameters.
% Assumes for the reference charge Z0 = 1.
%
% The BGK_Func function takes the mass, charge, initial distribution, and
% all necessary spatial and time domain parameters.
%
% Species data:
%   species.Nsp     -   number of species
%   species.mass    -   mass of each species
%   species.charge  -   charge number of each species
%
%   f0              -   initial distribution function (Nsp x Nx x Nv x Nv)
%
% Spatial and time domain:
%   params.Nx           -   number of sptatial points in discretization
%   params.Lx           -   length of the spatial domain
%   params.Nv           -   number of velocity points in discretization
%   params.Lv           -   maximum velocity to integrate
%   params.Ndt          -   number of timesteps to take
%   params.order        -   first-order (1) or second-order(2)
%   params.minmodtheta  -   parameter for minmod (second order only)
%   params.CFL          -   CFL number to choose time step
%   params.k            -   screening parameter, k = a/lambda
%
% Plotting and timing parameters:
%   params.plotting -   whether of not to plot the results (boolean)
%   params.Njumps   -   if plotting, how often to plot data
%   params.timing   -   whether to output detailed timing info
%   params.legends  -   cell array of string names of species for plotting
%   params.axissize -   matrix of y-axis limits for density (row 1),
%                       temperature (row 2), and velocity (row 3)
%   params.saveplot -   whether to save the plots to image files
%
%%%--------------------------------------------------------------------%%%

% clear variables and set up paths
%clear all, close all
addpath('../BGK/')
addpath('../MD/')
addpath('../dependencies/')

% species properties (mass and charge should be column vectors (Nsp x 1))
species.Nsp     =   1;                          % default: 1
species.mass    =   1;                          % default: 1
species.charge  =   1;                          % default: 1

% make sure the mass and charge vectors are formatted correctly
species.mass    =   reshape(species.mass,[species.Nsp],1);
species.charge  =   reshape(species.charge,[species.Nsp],1);

% user specified spatial and time parameters (Lv is derived)
params.Nx   =   32;                             % default: 32
params.Lx   =   100;                            % default: 100
params.Nv   =   60;                             % default: 60
params.Ndt  =   1000;                           % default: 1000
params.CFL  =   0.2;                            % default: 0.2
params.k    =   1;                              % default: 1

% whether to use first (order = 1) or second (order = 2) order evolution
params.order        =   2;                      % default: 2
params.minmodtheta  =   1;                      % default: 1

% plotting and timing parameters
params.plotting =   1;                          % default: 1
params.Njumps   =   10;                         % default: 10
params.timing   =   0;                          % default: 0
params.legends  =   {};                         % default: {} (unspecified)
params.axissize =   [];                         % default: [] (unspecified)
params.saveplot =   0;                          % default: 0

% Periodic initial condition that should display plasma oscillations if
% collisions are turned off (comment out in BGK_func the line where f_coll
% is computed inside the BGKCollide subfunction)
Gamma   =   0.1;                                % default: 0.1
A       =   0.05;                               % amplitude of sine wave
K       =   1;                                  % wave number
moments.n   =   1/(pi*species.Nsp) * ones(species.Nsp,params.Nx) + ...
    A/(pi*species.Nsp) * sin(2*K*pi*(0:params.Nx-1)/params.Nx);
moments.T   =   repmat(species.charge,[1,params.Nx]) / (2*Gamma);
moments.u   =   zeros(species.Nsp,params.Nx,2);

% we can now get Lv and fill the initial maxwellian
params.Lv   =   10 * ...
    sqrt(max(max(moments.T ./ repmat(species.mass,[1,params.Nx]))));
f0 = maxwellian([],species,moments,params);

% set up axis and legend
if isempty(params.legends)
    legends = cell(species.Nsp,1);
    for i = 1:species.Nsp
        params.legends{i} = sprintf('Species %d', i);
    end
end
if isempty(params.axissize)
    params.axissize = NaN;
end

% call BGK_func
distribution = BGK_Func(species, f0, params);