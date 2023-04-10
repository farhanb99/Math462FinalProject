clear; close all; clc

%% Set up parameters

N = 250; % Number of people in a row
p = 5; % Number of people down the row that can influence
thresh = 0.19; % Threshold to make person stand up
rows = 50;
tmax = 88;
max_influence = 1;
num_influence = p + 2*floor(7*p/8) + 2*floor(5*p/8);
falloff = 0.5;

%% Set up Transition matrix T
A = zeros(N);
B = zeros(N);
C = zeros(N);

 
weights_next = zeros(1,N);
weights_next(N-p+1:N) = linspace(max_influence*falloff, max_influence,p);
A(1,1:N) = weights_next;

weights_one_row_away = zeros(1,N);
weights_one_row_away(N-floor(7*p/8)+1:N) = linspace(max_influence*falloff,max_influence,floor(7*p/8));
B(1,1:N) = weights_one_row_away;    

weights_two_rows_away = zeros(1,N);
weights_two_rows_away(N-floor(5*p/8)+1:N) = linspace(max_influence*falloff, max_influence,floor(5*p/8));
C(1,1:N) = weights_two_rows_away;

for i = 2:N
    weights_next = circshift(weights_next,1);
    weights_one_row_away = circshift(weights_one_row_away,1);
    weights_two_rows_away = circshift(weights_two_rows_away,1);
    A(i,1:N) = weights_next;
    B(i,1:N) = weights_one_row_away;
    C(i,1:end) = weights_two_rows_away;
end

A_ext = kron(eye(rows), A); % Creates block diagonal matrix with A in the main diagonal
B_ext = kron(diag(ones(1,rows - 1),1),B) + kron(diag(ones(1,rows - 1),-1),B); % Creates block matrix with B in the 1st upper and lower diagonals
C_ext = kron(diag(ones(1,rows - 2),2),C) + kron(diag(ones(1,rows - 2),-2),C); % Creates block matrix with C in the 2nd upper and lower diagonals

T = A_ext + B_ext + C_ext;
T = sparse(T) / num_influence;

%% Initialize starting matrix

M = zeros(rows,N);
% add perturbation

%M(floor(rows/2) - 5:floor(rows/2)+5, 1:5) = 1;
M(:, 1:4) = 1;
% M(4, 1:4) = 1;

% transform matrix into a single column vector
x = reshape(M', 1, [])';

RES = zeros(rows, N, tmax);
RES(:,:,1) = M;

%% evolve matrix



for iter = 2:tmax
    result = T*x;
    result(result < thresh) = 0;
    result(result >= thresh) = 1;
    RES(:,:,iter) = reshape(result, N, [])';
    x = result - x;
    x(x < 0) = 0;
end

%%



% to save file, run command: 
save test_run.mat N rows tmax RES -v7.3