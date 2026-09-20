function Hist = custom_hist(Image)
    [M, N, C] = size(Image);
    
    Hist = zeros(C, 256);
    Img_double = double(Image);
    n = M * N
    
    for c = 1:C
        for i = 1:M
            for j = 1:N
                val = Img_double(i, j, c);
                Hist(c, val + 1) = Hist(c, val + 1) + 1;
            end
        end
        Hist(c, :) = Hist(c, :) / double(n);
    end
end