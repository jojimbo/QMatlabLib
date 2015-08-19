function matOut = cholesky(matIn)

    N = size(matIn,1);
    M = size(matIn,2);

    if M ~= N
        disp('GaussianCopula - Warning: invalid correlation matrix');
        return
    end
    l = zeros(N,N);
    for j = 1:N
        S = 0;
    
        for k = 1:j - 1
            S = S + l(j, k) ^ 2;
        end
    l(j, j) = matIn(j, j) - S;
    if l(j, j) <= 0 % Exit For 'matrix is not positive semi-definite
        l(j, j) = 0.00001;
    end
    l(j, j) = l(j, j)^(0.5);
    
        for i = j + 1:N
            S = 0;
            for k = 1:j - 1
                S = S + l(i, k) * l(j, k);
            end
            l(i, j) = (matIn(i, j) - S) / l(j, j);
        end

    end

    matOut = l;
end