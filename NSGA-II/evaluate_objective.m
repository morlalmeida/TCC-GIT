function [f] = evaluate_objective(x, M, V)

%% function f = evaluate_objective(x, M, V)
% Function to evaluate the objective functions for the given input vector
% x. x is an array of decision variables and f(1), f(2), etc are the
% objective functions. The algorithm always minimizes the objective
% function hence if you would like to maximize the function then multiply
% the function by negative one. M is the numebr of objective functions and
% V is the number of decision variables. 
%
% This functions is basically written by the user who defines his/her own
% objective function. Make sure that the M and V matches your initial user
% input. Make sure that the 
%
% An example objective function is given below. It has two six decision
% variables are two objective functions.

% f = [];
% %% Objective function one
% % Decision variables are used to form the objective function.
% f(1) = 1 - exp(-4*x(1))*(sin(6*pi*x(1)))^6;
% sum = 0;
% for i = 2 : 6
%     sum = sum + x(i)/4;
% end
% %% Intermediate function
% g_x = 1 + 9*(sum)^(0.25);
% 
% %% Objective function two
% f(2) = g_x*(1 - ((f(1))/(g_x))^2);

%% Kursawe proposed by Frank Kursawe.
% Take a look at the following reference
% A variant of evolution strategies for vector optimization.
% In H. P. Schwefel and R. M�nner, editors, Parallel Problem Solving from
% Nature. 1st Workshop, PPSN I, volume 496 of Lecture Notes in Computer 
% Science, pages 193-197, Berlin, Germany, oct 1991. Springer-Verlag. 
%
% Number of objective is two, while it can have arbirtarly many decision
% variables within the range -5 and 5. Common number of variables is 3.
% f = [];
% % Objective function one
% sum = 0;
% for i = 1 : V - 1
%     sum = sum - 10*exp(-0.2*sqrt((x(i))^2 + (x(i + 1))^2));
% end
% % Decision variables are used to form the objective function.
% f(1) = sum;
% 
% % Objective function two
% sum = 0;
% for i = 1 : V
%     sum = sum + (abs(x(i))^0.8 + 5*(sin(x(i)))^3);
% end
% % Decision variables are used to form the objective function.
% f(2) = sum;

%% Setting Functions for Optimization

[f,pitch] = evaluate_fitness(x);
if f == [1e6, 1e6]
    fprintf('Bad Prop :( \n');
    fprintf('Running next individual! \n');
    fprintf('-------------------------------------------------------------------------------------------------------- \n');
else
    fprintf('Nice Prop :D \n');
    fprintf('Fitness:          %0.2f, %0.2f \n', f(1), f(2));
    fprintf('Diameter:         %.2f \n', x(1));
    fprintf('Pitch:            %.2f \n', pitch);
    fprintf('Number of Blades: %d \n', round(x(2)));
    fprintf('Running next individual! \n');
    fprintf('-------------------------------------------------------------------------------------------------------- \n');
end

%% Check for error
if length(f) ~= M
    error('The number of decision variables does not match you previous input. Kindly check your objective function');
end