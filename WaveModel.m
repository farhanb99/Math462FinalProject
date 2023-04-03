clc 
weights = zeros(1,100);
weights(2:11) = linspace(0, 1,10);
A = weights;
for i = 2:length(weights)
    weights = circshift(weights,1);
    A = [A; weights];
end

start = zeros(1,100);
start(1:5) = 1;

for iter = 1:4
    result = 1/100 .* A * transpose(start)
    result(result < 0.1) = 0;
    result(result > 0.1) = 1;
    result
    start = transpose(result);

end