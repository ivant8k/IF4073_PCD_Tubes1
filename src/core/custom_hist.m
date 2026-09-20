function Hist = custom_hist(Image)
    [M, N] = size(Image);
    
    Hist = zeros(1, 256);
    Img_double = double(Image);

    for i = 1:M
        for j = 1:N
            val = Img_double(i, j);
            Hist(val + 1) = Hist(val + 1) + 1;
        end
    end

    n = M * N;
    Hist = Hist / double(n);
end