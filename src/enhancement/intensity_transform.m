function OutImage = intensity_transform(Image, TransformType, varargin)

    [M, N, C] = size(Image);
    OutImage = zeros(M, N, C, 'uint8');

    TransformType = lower(TransformType);

    switch TransformType
        case 'negative'
            OutImage = 255 - Image;
            
        case {'linear', 'bright', 'brightening'}
            GainA = 1.0;
            BiasB = 0.0;
            if nargin >= 3 && ~isempty(varargin{1}), GainA = double(varargin{1}); end
            if nargin >= 4 && ~isempty(varargin{2}), BiasB = double(varargin{2}); end

            ImgDouble = double(Image);
            Result = GainA * ImgDouble + BiasB;
            OutImage = uint8(min(max(Result, 0), 255));

        case 'log'
            ConstC = 1.0;
            if nargin >= 3 && ~isempty(varargin{1}), ConstC = double(varargin{1}); end

            ImgDouble = double(Image) / 255.0;
            Result = ConstC * (log(1 + ImgDouble) / log(2)) * 255.0;
            OutImage = uint8(min(max(Result, 0), 255));

        case 'inv_log'
            ConstC = 1.0;
            if nargin >= 3 && ~isempty(varargin{1}), ConstC = double(varargin{1}); end

            ImgDouble = double(Image) / 255.0;
            Result = ((exp(ImgDouble .^ ConstC) - 1) / (exp(1) - 1)) * 255.0;
            OutImage = uint8(min(max(Result,0),255));

        case {'gamma', 'power'}
            GammaVal = 1.0;
            ConstC = 1.0;
            if nargin >= 3 && ~isempty(varargin{1}), GammaVal = double(varargin{1}); end
            if nargin >= 4 && ~isempty(varargin{2}), ConstC = double(varargin{2}); end

            ImgDouble = double(Image) / 255.0;
            Result = ConstC * (ImgDouble .^ GammaVal) * 255.0;
            OutImage = uint8(min(max(Result, 0), 255));

        case 'gamma_correction'
            % s = c * r^(1/gamma)
            GammaVal = 2.2;
            ConstC = 1.0;
            if nargin >= 3 && ~isempty(varargin{1}), GammaVal = double(varargin{1}); end
            if nargin >= 4 && ~isempty(varargin{2}), ConstC = double(varargin{2}); end

            ImgDouble = double(Image) / 255.0;
            Result = ConstC * (ImgDouble .^ (1 / GammaVal)) * 255.0;
            OutImage = uint8(min(max(Result, 0), 255));

        case 'contrast_stretching'
            for c = 1:C
                ImgChannel = double(Image(:, :, c));

                if nargin >= 3 && ~isempty(varargin{1})
                    Rmin = double(varargin{1});
                else
                    Rmin = min(ImgChannel(:));
                end

                if nargin >= 4 && ~isempty(varargin{2})
                    Rmax = double(varargin{2});
                else
                    Rmax = max(ImgChannel(:));
                end

                if Rmax == Rmin
                    OutImage(:, :, c) = uint8(ImgChannel);
                else
                    Stretched = (ImgChannel - Rmin) * (255.0 / (Rmax - Rmin));
                    OutImage(:, :, c) = uint8(min(max(Stretched, 0), 255));
                end
            end

        otherwise
            error('Unknown TransformType: %s', TransformType)
    end
end