function OutImage = image_filtering(Image, FilterType, varargin)
    [M, N, C] = size(Image);
    ImgDouble = double(Image);
    OutDouble = zeros(M, N, C);
    FilterType = lower(FilterType);

    switch FilterType
        case {'mean', 'averaging'}
            KSize = 3;
            if nargin >= 3 && ~isempty(varargin{1}), KSize = double(varargin{1}); end
            Kernel = ones(Ksize, KSize) / (KSize * KSize);
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
            % TODO

        case 'custom'
            % TODO

        case 'median'
            % TODO
        
        case 'min'
            % TODO

        case 'max'
            % TODO

        otherwise
            error('Unknown Filter: %s', FilterType);
    end 

    OutImage = uint(min(max(OutDouble, 0), 255));
end 

function Out = apply_convolution(ImgDouble, Kernel)
% TODO
end

function Out = apply_order_filter(ImgDouble, Kernel)
% TODO (buat median, min, max)
end

function Padded = pad_image_replicate(Channel, padM, padN)
% TODO
end

function Kernel = create_gaussian_kernel(KSize, Size)
% TODO
end