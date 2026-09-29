function ImageEq = hist_equalization(Image)
    [M, N, C] = size(Image);
    ImageEq = zeros(M, N, C, 'uint8');

    for c = 1:C
        ImgChannel = Image(:, :, c);
        PDF = custom_hist(ImgChannel) / (M * N);
        CDF = zeros(1, 256);
        sum_val = 0.0;
        for i = 1:256
            sum_val = sum_val + PDF(i);
            CDF(i) = sum_val;
        end

        HistEqMap = uint8(floor(255 * CDF));
        Indices = double(ImgChannel) + 1;
        ImageEq(:, :, c) = HistEqMap(Indices);
    end
end