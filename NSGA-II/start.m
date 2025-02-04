%% Initializing NSGA-II

clc;clear;close all
pop = 20;       % Sets population size (min = 20)
gen = 5;        % Sets number of generations (min = 5)

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
