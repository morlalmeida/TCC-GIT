clc; clear; close all;

% Define number of runs for benchmarking
num_tests = 5; % Run each version multiple times for accuracy

fprintf("Benchmarking `dyn_qprop.m`...\n");
fprintf("Running tests %d times for accuracy...\n", num_tests);

%% 🔹 Benchmarking Original Version (Sequential)
fprintf("\n🔹 Running Original (Sequential) Version...\n");
orig_times = zeros(1, num_tests);
for i = 1:num_tests
    tic;
    Result2_orig = dyn_qprop_V1(); % Rename original function to avoid conflict
    orig_times(i) = toc;
    fprintf("Run %d: %.2f seconds\n", i, orig_times(i));
end
avg_orig_time = mean(orig_times);
fprintf("\n✅ Average Execution Time (Original): %.2f seconds\n", avg_orig_time);

%% 🔹 Benchmarking Optimized Parallel Version
fprintf("\n🔹 Running Optimized Parallel Version...\n");
opt_times = zeros(1, num_tests);
for i = 1:num_tests
    tic;
    Result2_opt = dyn_qprop(); % Running the optimized function
    opt_times(i) = toc;
    fprintf("Run %d: %.2f seconds\n", i, opt_times(i));
end
avg_opt_time = mean(opt_times);
fprintf("\n✅ Average Execution Time (Optimized): %.2f seconds\n", avg_opt_time);

%% 🔹 Calculate Speedup
speedup = avg_orig_time / avg_opt_time;
fprintf("\n🚀 Speedup Achieved: %.2fx Faster Execution\n", speedup);
