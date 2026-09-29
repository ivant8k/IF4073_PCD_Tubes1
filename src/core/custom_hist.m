function Hist = custom_hist(Image)
    [~, ~, C] = size(Image);
    
    Img_double = double(Image);

    if C == 1
        Hist = zeros(256, 1);
        for val = Img_double(:)'
            Hist(val + 1) = Hist(val + 1) + 1;
        end
    else
        Hist = zeros(256, C);
        for c = 1:C
            channel_data = Img_double(:, :, c);
            for val = channel_data(:)'
                Hist(val + 1, c) = Hist(val + 1, c) + 1;
            end
        end
    end
end