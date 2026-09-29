function ImageEnhancementGUI()
% Main figure
f = figure('Name', 'Image Enhancement GUI', 'Position', [100, 100, 1200, 700], ...
    'MenuBar', 'none', 'NumberTitle', 'off', 'Resize', 'on');

scriptDir = fileparts(mfilename('fullpath'));
addpath(fullfile(scriptDir, '..', 'core'));
addpath(fullfile(scriptDir, '..', 'enhancement'));

% Data storage
data = struct('inputImg', [], 'refImg', [], 'outputImg', [], 'workingImg', []);

% Daftar metode Intensity Transformation:
% {Nama di dropdown, TransformType, Petunjuk parameter}
intensityMethods = {
    'Negative',                        'negative',            'Tidak ada parameter.  s = 255 - r';
    'Linear/Brightening',              'linear',              'a, b  (default 1, 0)   s = a*r + b';
    'Log',                             'log',                 'c  (default 1)   s = c*log(1+r)';
    'Inv Log',                         'inv_log',             'c  (default 1)   s = exp(r^c) - 1';
    'Power (Gamma)',                   'gamma',               'gamma, c  (default 1, 1)   s = c*r^gamma.  gamma<1 terang, >1 gelap';
    'Gamma Correction',                'gamma_correction',    'gamma, c  (default 2.2, 1)   s = c*r^(1/gamma)';
    'Contrast Stretching (min-max)',   'contrast_stretching', 'rmin, rmax  (default: min & max citra)';
    'Piecewise (r1,s1,r2,s2)',         'piecewise',           'r1, s1, r2, s2  (default 70,20,180,235).  r1=r2, s1=0, s2=255 -> thresholding';
    'Piecewise (a,b,al,be,ga,ya,yb)',  'piecewise_abg',       'a, b, alpha, beta, gamma, ya, yb  (default 50,150,0.2,2,1,30,200)';
    'Thresholding',                    'threshold',           'm  (default 128).  r<m -> 0, r>=m -> 255';
    'Gray-level Slicing (Discard BG)', 'slicing_discard',     'A, B  (default 142,250).  Rentang [A,B] -> 255, lainnya -> 0';
    'Gray-level Slicing (Preserve BG)','slicing_preserve',    'A, B  (default 142,250).  Rentang [A,B] -> 255, lainnya tetap';
    'Bit-plane Slicing',               'bitplane',            'k = 0..7  (default 7).  0 = LSB, 7 = MSB'
    };

% Control Panel
uicontrol(f, 'Style', 'text', 'Position', [20, 650, 200, 20], 'String', 'CONTROLS', ...
    'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'FontSize', 12);

btnLoadInput = uicontrol(f, 'Style', 'pushbutton', 'Position', [20, 610, 220, 30], ...
    'String', 'Load Input Image', 'Callback', @loadInputCallback);
btnLoadRef = uicontrol(f, 'Style', 'pushbutton', 'Position', [20, 570, 220, 30], ...
    'String', 'Load Reference Image', 'Callback', @loadRefCallback, 'Enable', 'off');

uicontrol(f, 'Style', 'text', 'Position', [20, 540, 220, 20], 'String', 'Enhancement Category:', 'HorizontalAlignment', 'left');
dropCategory = uicontrol(f, 'Style', 'popupmenu', 'Position', [20, 520, 220, 20], ...
    'String', {'Intensity Transformation', 'Histogram Equalization', 'Histogram Specification', 'Image Filtering'}, ...
    'Callback', @categoryCallback);

uicontrol(f, 'Style', 'text', 'Position', [20, 490, 220, 20], 'String', 'Specific Method:', 'HorizontalAlignment', 'left');
dropMethod = uicontrol(f, 'Style', 'popupmenu', 'Position', [20, 470, 220, 20], ...
    'String', intensityMethods(:, 1)', 'Callback', @methodCallback);

uicontrol(f, 'Style', 'text', 'Position', [20, 440, 220, 20], 'String', 'Parameters (comma-separated):', 'HorizontalAlignment', 'left');
editParams = uicontrol(f, 'Style', 'edit', 'Position', [20, 420, 220, 20], 'HorizontalAlignment', 'left');

btnApply = uicontrol(f, 'Style', 'pushbutton', 'Position', [20, 370, 220, 35], ...
    'String', 'APPLY (from Input)', 'FontWeight', 'bold', 'BackgroundColor', [0.2 0.5 0.8], ...
    'ForegroundColor', 'white', 'Callback', @applyCallback);

btnApplySeq = uicontrol(f, 'Style', 'pushbutton', 'Position', [20, 328, 220, 35], ...
    'String', 'APPLY (chain to Output)', 'FontWeight', 'bold', 'BackgroundColor', [0.2 0.6 0.3], ...
    'ForegroundColor', 'white', 'Enable', 'off', 'Callback', @applySequentialCallback);

btnReset = uicontrol(f, 'Style', 'pushbutton', 'Position', [20, 288, 220, 32], ...
    'String', 'Reset to Original Input', 'ForegroundColor', [0.6 0.1 0.1], ...
    'Enable', 'off', 'Callback', @resetCallback);

txtChainStatus = uicontrol(f, 'Style', 'text', 'Position', [20, 255, 220, 28], ...
    'String', 'Input: (none)', 'HorizontalAlignment', 'center', 'FontSize', 8, ...
    'ForegroundColor', [0.3 0.3 0.3]);

% Petunjuk parameter (berubah sesuai metode terpilih)
txtHint = uicontrol(f, 'Style', 'text', 'Position', [20, 190, 220, 60], ...
    'String', '', 'HorizontalAlignment', 'left', 'FontSize', 8, ...
    'ForegroundColor', [0.15 0.15 0.5]);

% Input Panel
axInputImg = axes(f, 'Units', 'pixels', 'Position', [300, 350, 400, 300]);
title(axInputImg, 'Input Image');
axis(axInputImg, 'off');

axInputHist = axes(f, 'Units', 'pixels', 'Position', [300, 80, 400, 200]);
title(axInputHist, 'Input Histogram');

txtInputStats = uicontrol(f, 'Style', 'text', 'Position', [300, 30, 400, 20], ...
    'String', 'Input Stats: N/A', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

% Output Panel
axOutputImg = axes(f, 'Units', 'pixels', 'Position', [750, 350, 400, 300]);
title(axOutputImg, 'Output Image');
axis(axOutputImg, 'off');

axOutputHist = axes(f, 'Units', 'pixels', 'Position', [750, 80, 400, 200]);
title(axOutputHist, 'Output Histogram');

txtOutputStats = uicontrol(f, 'Style', 'text', 'Position', [750, 30, 400, 20], ...
    'String', 'Output Stats: N/A', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

updateHint();

% Callbacks
    function categoryCallback(~, ~)
        val = get(dropCategory, 'Value');
        set(btnLoadRef, 'Enable', 'off');
        set(dropMethod, 'Enable', 'on');
        set(dropMethod, 'Value', 1);

        switch val
            case 1
                set(dropMethod, 'String', intensityMethods(:, 1)');
            case 2
                set(dropMethod, 'String', {'None'});
                set(dropMethod, 'Enable', 'off');
            case 3
                set(dropMethod, 'String', {'None'});
                set(dropMethod, 'Enable', 'off');
                set(btnLoadRef, 'Enable', 'on');
            case 4
                set(dropMethod, 'String', {'Mean/Averaging', 'Gaussian', 'Laplacian/Sharpen', 'Unsharp', 'Highboost', 'Median', 'Min', 'Max'});
        end
        updateHint();
    end

    function methodCallback(~, ~)
        updateHint();
    end

    function updateHint()
        catVal = get(dropCategory, 'Value');
        switch catVal
            case 1
                idx = get(dropMethod, 'Value');
                hintStr = ['Parameter: ' intensityMethods{idx, 3}];
            case 2
                hintStr = 'Tidak ada parameter.';
            case 3
                hintStr = 'Tidak ada parameter. Load reference image terlebih dahulu.';
            case 4
                hintStr = 'Parameter opsional, sesuai fungsi image_filtering.';
            otherwise
                hintStr = '';
        end
        set(txtHint, 'String', hintStr);
    end

    function loadInputCallback(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files'});
        if isequal(filename,0), return; end
        data.inputImg = imread(fullfile(pathname, filename));
        data.workingImg = data.inputImg;

        imshow(data.inputImg, 'Parent', axInputImg);
        title(axInputImg, 'Input Image');
        plot_histogram(axInputHist, data.inputImg);
        update_stats(txtInputStats, data.inputImg, 'Input Stats');

        cla(axOutputImg); axis(axOutputImg, 'off'); title(axOutputImg, 'Output Image');
        cla(axOutputHist); title(axOutputHist, 'Output Histogram');
        set(txtOutputStats, 'String', 'Output Stats: N/A');
        set(btnApplySeq, 'Enable', 'off');
        set(btnReset, 'Enable', 'off');
        set(txtChainStatus, 'String', sprintf('Input: %s', filename), 'ForegroundColor', [0.1 0.4 0.1]);
    end

    function loadRefCallback(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files'});
        if isequal(filename,0), return; end
        data.refImg = imread(fullfile(pathname, filename));
        msgbox('Reference image loaded successfully!', 'Success');
    end

% Apply dari citra input asli
    function applyCallback(~, ~)
        if isempty(data.inputImg)
            errordlg('Please load an input image first!', 'Error');
            return;
        end
        data.workingImg = data.inputImg;
        run_enhancement();
    end

% Apply chaining dari citra output terakhir
    function applySequentialCallback(~, ~)
        if isempty(data.outputImg)
            errordlg('No output image yet. Apply from Input first.', 'Error');
            return;
        end
        data.workingImg = data.outputImg;
        run_enhancement();
    end

% Reset ke citra asli
    function resetCallback(~, ~)
        data.workingImg = data.inputImg;
        data.outputImg = [];
        imshow(data.inputImg, 'Parent', axInputImg);
        title(axInputImg, 'Input Image');
        plot_histogram(axInputHist, data.inputImg);
        update_stats(txtInputStats, data.inputImg, 'Input Stats');
        cla(axOutputImg); axis(axOutputImg, 'off'); title(axOutputImg, 'Output Image');
        cla(axOutputHist); title(axOutputHist, 'Output Histogram');
        set(txtOutputStats, 'String', 'Output Stats: N/A');
        set(btnApplySeq, 'Enable', 'off');
        set(btnReset, 'Enable', 'off');
        set(txtChainStatus, 'ForegroundColor', [0.1 0.4 0.1]);
    end

    function run_enhancement()
        catVal = get(dropCategory, 'Value');
        methodStr = get(dropMethod, 'String');
        selMethod = methodStr{get(dropMethod, 'Value')};

        try
            params = parse_params(get(editParams, 'String'));

            switch catVal
                case 1 % Intensity Transformation
                    idx   = get(dropMethod, 'Value');
                    tType = intensityMethods{idx, 2};
                    args  = num2cell(params);   % semua parameter diteruskan (bisa > 2)
                    data.outputImg = intensity_transform(data.workingImg, tType, args{:});

                case 2 % Histogram Equalization
                    data.outputImg = hist_equalization(data.workingImg);

                case 3 % Histogram Specification
                    if isempty(data.refImg)
                        errordlg('Please load a reference image first!', 'Error');
                        return;
                    end
                    data.outputImg = hist_matching(data.workingImg, data.refImg);

                case 4 % Image Filtering
                    switch selMethod
                        case 'Mean/Averaging',    fType = 'mean';
                        case 'Gaussian',          fType = 'gaussian';
                        case 'Laplacian/Sharpen', fType = 'laplacian';
                        case 'Unsharp',           fType = 'unsharp';
                        case 'Highboost',         fType = 'highboost';
                        case 'Median',            fType = 'median';
                        case 'Min',               fType = 'min';
                        case 'Max',               fType = 'max';
                    end
                    if isempty(params)
                        data.outputImg = image_filtering(data.workingImg, fType);
                    elseif length(params) == 1
                        data.outputImg = image_filtering(data.workingImg, fType, params(1));
                    else
                        data.outputImg = image_filtering(data.workingImg, fType, params(1), params(2));
                    end
            end

            % input yang digunakan di panel kiri
            imshow(data.workingImg, 'Parent', axInputImg);
            title(axInputImg, 'Input (Working)');
            plot_histogram(axInputHist, data.workingImg);
            update_stats(txtInputStats, data.workingImg, 'Input Stats');

            % output di panel kanan
            imshow(data.outputImg, 'Parent', axOutputImg);
            title(axOutputImg, sprintf('Output (%s)', selMethod));
            plot_histogram(axOutputHist, data.outputImg);
            update_stats(txtOutputStats, data.outputImg, 'Output Stats');

            set(btnApplySeq, 'Enable', 'on');
            set(btnReset, 'Enable', 'on');
            set(txtChainStatus, 'String', sprintf('Last: %s', selMethod), 'ForegroundColor', [0.1 0.1 0.6]);

        catch ME
            errordlg(['Error during processing: ' ME.message], 'Processing Error');
        end
    end

% Helpers
    function p = parse_params(str)
        % Ubah "a, b, c" (dipisah koma/spasi/titik koma) menjadi vektor angka
        str = strtrim(str);
        if isempty(str), p = []; return; end
        tokens = strsplit(str, {',', ' ', ';'}, 'CollapseDelimiters', true);
        tokens = tokens(~cellfun(@isempty, tokens));
        p = str2double(tokens);
        if any(isnan(p))
            error('Parameter tidak valid. Gunakan angka yang dipisah koma, mis. 50,150,0.2');
        end
    end

    function plot_histogram(ax, img)
        if isempty(img), cla(ax); return; end
        hist_data = custom_hist(img);
        [~, C] = size(hist_data);
        cla(ax); hold(ax, 'on');
        if C == 1
            plot(ax, 0:255, hist_data(:, 1), 'k', 'LineWidth', 1.5);
        elseif C == 3
            plot(ax, 0:255, hist_data(:, 1), 'r', 'LineWidth', 1.5);
            plot(ax, 0:255, hist_data(:, 2), 'g', 'LineWidth', 1.5);
            plot(ax, 0:255, hist_data(:, 3), 'b', 'LineWidth', 1.5);
        end
        hold(ax, 'off');
        xlim(ax, [0 255]);
        title(ax, 'Histogram');
        grid(ax, 'on');
    end

    function update_stats(txt_handle, img, prefix)
        if isempty(img)
            set(txt_handle, 'String', sprintf('%s: N/A', prefix)); return;
        end
        img_double = double(img);
        str = sprintf('%s - Min: %.1f | Max: %.1f | Mean: %.2f | Std: %.2f', prefix, ...
            min(img_double(:)), max(img_double(:)), mean(img_double(:)), std(img_double(:)));
        set(txt_handle, 'String', str);
    end
end