clear; close all; clc

%% Set up parameters

N = 500; % Number of people in a row
p = 4; % Number of people down the row that can influence
thresh = 0.99; % Threshold to make person stand up
rows = 10;
tmax = 400;

%% Set up Transition matrix T
A = zeros(N);
B = zeros(N);
C = zeros(N);
 
weights_next = zeros(1,N);
weights_next(N-p+1:N) = linspace(0, 1,p);
A(1,1:N) = weights_next;

weights_one_row_away = zeros(1,N);
weights_one_row_away(N-p+1:N) = linspace(0, 2/3,p);
B(1,1:N) = weights_one_row_away;

weights_two_rows_away = zeros(1,N);
weights_two_rows_away(N-p+2:N) = linspace(0, 1/3,p-1);
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
T = sparse(T);

%% Initialize starting matrix

M = zeros(rows,N);
% add perturbation

M(2, 1:2) = 1;
% M(3, 1:4) = 1;
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