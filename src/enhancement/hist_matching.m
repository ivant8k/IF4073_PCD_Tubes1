function ImageMatch = hist_matching(Image, RefInput)

    [M, N, C] = size(Image);
    ImageMatch = zeros(M, N, C, 'uint8');

    HistSrc = custom_hist(Image);
    HistRef = custom_hist(RefInput);

    for c = 1:C
        c_ref = min(c, size(HistRef, 1));
        CDFSrc = cumsum(HistSrc(c, :));
        SrcEq = uint8(round(255 * CDFSrc));

        CDFRef = cumsum(HistRef(c_ref, :));
        RefEq = uint8(round(255 * CDFRef));

        % Perbedaan dengan pseudocode pak rin
        % Membatasi pemetaan balik CDF hanya pada rentang intensitas aktif referensi untuk mencegah artefak piksel akibat area CDF datar.
        active_idx = find(HistRef(c_ref, :) > 0);
        min_ref = active_idx(1);
        max_ref = active_idx(end);

        InvHist = zeros(1, 256, 'uint8');
        RefEq_active = double(RefEq(min_ref:max_ref));

        for i = 1:256
            [~, minj_rel] = min(abs(double(SrcEq(i)) - RefEq_active));
            InvHist(i) = uint8(min_ref + minj_rel - 2);
        end

        Indices = double(Image(:, :, c)) + 1;
        ImageMatch(:, :, c) = InvHist(Indices);
    end
end