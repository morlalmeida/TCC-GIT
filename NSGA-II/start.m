%% Initializing NSGA-II

clc;clear;close all
pop = 20;       % Sets population size (min = 20)
gen = 5;        % Sets number of generations (min = 5)

tic
nsga_2(pop,gen) % Running Optmization :)
toc
