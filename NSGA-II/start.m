%% Initializing NSGA-II
clc;clear;close all
pop = 40;      % Sets population size (min = 20)
gen = 5;       % Sets number of generations (min = 5)

% 🔹 Ensure Parallel Pool is Active (Limited to 5 Workers)
poolobj = gcp('nocreate'); 
if isempty(poolobj)
   parpool(5); % Start parallel pool if not already running
end

global Vs MTOW rho g Sw
Sw   = 12.25;   % Wing Area [m^2]
MTOW = 870;    % Take-Off Weight [kg]
g    = 9.787;   % Gravity [m/s^2]
rho  = 1.15;  % Air Density [kg/m^3]
Vs = sqrt((2*MTOW*g)/(rho*Sw*1.673));

tic
nsga_2(pop,gen) % Running Optmization :)
elapsedTime = toc;  % Get elapsed time in seconds

% Convert elapsed time to days, hours, minutes, and seconds
days = floor(elapsedTime / 86400);
hours = floor(mod(elapsedTime, 86400) / 3600);
minutes = floor(mod(elapsedTime, 3600) / 60);
seconds = mod(elapsedTime, 60);

% Display the formatted output
fprintf('Elapsed time: %d days, %d hours, %d minutes, %.2f seconds\n', days, hours, minutes, seconds);
