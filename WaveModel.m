clear; close all; 

%% Set up parameters

N = 100; % Number of people in a row
p = 4; % Number of people down the row that can influence
T = 0.1; % Threshold to make person stand up
rows = 5;

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

M(3, 1:3) = 1;

% transform matrix into a single column vector
x = reshape(M', 1, [])';


% evolve matrix

% start = zeros(1,N);
% start(1:4) = 1;
% 
% for iter = 1:4
%     result = A * transpose(start);
%     result(result < T) = 0;
%     result(result >= T) = 1;
%     result
%     start = transpose(result);
% 
% end

% to save file, run command: 
% save [filename] N rows x -v7.3