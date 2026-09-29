function ImageEnhancementGUI()
% Main figure
f = figure('Name', 'Image Enhancement GUI', 'Position', [100, 100, 1200, 700], ...
    'MenuBar', 'none', 'NumberTitle', 'off', 'Resize', 'on');

scriptDir = fileparts(mfilename('fullpath'));
addpath(fullfile(scriptDir, '..', 'core'));
addpath(fullfile(scriptDir, '..', 'enhancement'));

% Data storage
data = struct('inputImg', [], 'refImg', [], 'outputImg', [], 'workingImg', []);

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
    'String', {'Negative', 'Linear/Brightening', 'Log', 'Inv Log', 'Gamma', 'Contrast Stretching'});

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

% Callbacks
    function categoryCallback(~, ~)
        val = get(dropCategory, 'Value');
        set(btnLoadRef, 'Enable', 'off');
        set(dropMethod, 'Enable', 'on');
        set(dropMethod, 'Value', 1);

        switch val
            case 1
                set(dropMethod, 'String', {'Negative', 'Linear/Brightening', 'Log', 'Inv Log', 'Gamma', 'Contrast Stretching'});
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
        params = str2num(get(editParams, 'String'));

        try
            switch catVal
                case 1 % Intensity Transformation
                    switch selMethod
                        case 'Negative',           tType = 'negative';
                        case 'Linear/Brightening', tType = 'linear';
                        case 'Log',                tType = 'log';
                        case 'Inv Log',            tType = 'inv_log';
                        case 'Gamma',              tType = 'gamma';
                        case 'Contrast Stretching',tType = 'contrast_stretching';
                    end
                    if isempty(params)
                        data.outputImg = intensity_transform(data.workingImg, tType);
                    elseif length(params) == 1
                        data.outputImg = intensity_transform(data.workingImg, tType, params(1));
                    else
                        data.outputImg = intensity_transform(data.workingImg, tType, params(1), params(2));
                    end

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
