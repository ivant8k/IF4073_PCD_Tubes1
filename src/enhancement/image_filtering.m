function OutImage = image_filtering(Image, FilterType, varargin)
    [M, N, C] = size(Image);
    ImgDouble = double(Image);
    FilterType = lower(FilterType);

    switch FilterType
        case {'mean', 'averaging'}
            KSize = 3;
            if nargin >= 3 && ~isempty(varargin{1}), KSize = double(varargin{1}); end
            Kernel = ones(KSize, KSize) / (KSize * KSize);
            OutDouble = apply_convolution(ImgDouble, Kernel);

        case 'gaussian'
            KSize = 3;
            Sigma = 1.0;
            if nargin >= 3 && ~isempty(varargin{1}), KSize = double(varargin{1}); end
            if nargin >= 4 && ~isempty(varargin{2}), Sigma = double(varargin{2}); end
            Kernel = create_gaussian_kernel(KSize, Sigma);
            OutDouble = apply_convolution(ImgDouble, Kernel);
        
        case {'laplacian', 'sharpen'}
            Kernel = [0 -1 0; -1 5 -1; 0 -1 0];
            if nargin >= 3 && ~isempty(varargin{1})
                KInput = varargin{1};
                if isnumeric(KInput) && ismatrix(KInput)
                    Kernel = double(KInput);
                end
            end
            OutDouble = apply_convolution(ImgDouble, Kernel);
         
        case 'unsharp'
            KSize =3;
            if nargin >= 3 && ~isempty(varargin{1}), KSize = double(varargin{1}); end
            Kernel = ones(KSize, KSize) / (KSize * KSize);
            Lowpass = apply_convolution(ImgDouble, Kernel);
            Highpass = ImgDouble - Lowpass;
            OutDouble = ImgDouble + Highpass;
           
        case 'highboost'
            Alpha = 1.5;
            KSize = 3;
            if nargin >= 3 && ~isempty(varargin{1}), Alpha = double(varargin{1}); end
            if nargin >= 4 && ~isempty(varargin{2}), KSize = double(varargin{2}); end
            Kernel = ones(KSize, KSize) / (KSize * KSize);
            Lowpass = apply_convolution(ImgDouble, Kernel);
            Highpass = ImgDouble - Lowpass;
            OutDouble = ImgDouble + Alpha * Highpass;

        case 'custom'
            if nargin < 3 || isempty(varargin{1})
                error('A custom filter kernel must be provided.');
            end
            Kernel = double(varargin{1});
            OutDouble = apply_convolution(ImgDouble, Kernel);

        case 'median'
            KSize = 3;
            if nargin >= 3 && ~isempty(varargin{1}), KSize = double(varargin{1}); end
            OutDouble = apply_order_filter(ImgDouble, KSize, 'median');
        
        case 'min'
            KSize = 3;
            if nargin >= 3 && ~isempty(varargin{1}), KSize = double(varargin{1}); end
            OutDouble = apply_order_filter(ImgDouble, KSize, 'min');

        case 'max'
            KSize = 3;
            if nargin >= 3 && ~isempty(varargin{1}), KSize = double(varargin{1}); end
            OutDouble = apply_order_filter(ImgDouble, KSize, 'max');

        otherwise
            error('Unknown Filter: %s', FilterType);
    end 

    OutImage = uint8(min(max(OutDouble, 0), 255));
end 

function Out = apply_convolution(ImgDouble, Kernel)
    [M, N, C] = size(ImgDouble);
    [kM, kN] = size(Kernel);
    padM = floor(kM / 2);
    padN = floor(kN / 2);

    RotKernel = rot90(Kernel, 2);
    Out = zeros(M, N, C);

    for c = 1:C
        Padded = pad_image_replicate(ImgDouble(:, :, c), padM, padN);
        for i = 1:M
            for j = 1:N
                Region = Padded(i : i + kM -1, j : j + kN - 1);
                Out(i, j, c) = sum(sum(Region .* RotKernel));
            end
        end
    end
end

function Out = apply_order_filter(ImgDouble, KSize, OrderType)
    [M, N, C] = size(ImgDouble);
    padSize = floor(KSize / 2);
    Out = zeros(M, N, C);

    for c = 1:C
        Padded = pad_image_replicate(ImgDouble(:, :, c), padSize, padSize);
        for i = 1:M
            for j = 1:N
                Region = Padded(i : i + KSize - 1, j : j + KSize - 1);
                Neighborhood = Region(:);
                switch OrderType
                    case 'median'
                        Out(i, j, c) = median(Neighborhood);
                    case 'min'
                        Out(i, j, c) = min(Neighborhood);
                    case 'max'
                        Out(i, j, c) = max(Neighborhood);
                end
            end
        end
    end
end

function Padded = pad_image_replicate(Channel, padM, padN)
    [M, N] = size(Channel);
    Padded = zeros(M + 2*padM, N + 2*padN);

    Padded(padM + 1 : padM + M, padN + 1 : padN + N) = Channel;

    for p = 1:padM
        Padded(p, padN + 1 : padN + N) = Channel(1, :);
        Padded(padM + M + p, padN + 1 : padN + N) = Channel(M, :);
    end
    for p = 1:padN
        Padded(:, p) = Padded(:, padN + 1);
        Padded(:, padN + N + p) = Padded(:, padN + N);
    end
end

function Kernel = create_gaussian_kernel(KSize, Sigma)
    padSize = floor(KSize / 2);
    [X, Y] = meshgrid(-padSize:padSize, -padSize:padSize);
    Kernel = exp(-(X.^2 + Y.^2) / (2 * Sigma^2));
    KernelSum = sum(Kernel(:));
    if KernelSum ~= 0
        Kernel = Kernel / KernelSum;
    end
end