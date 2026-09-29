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

        case 'piecewise'
            % Linear sepotong-sepotong lewat (0,0), (r1,s1), (r2,s2), (255,255)
            R1 = 70; S1 = 20; R2 = 180; S2 = 235;
            if nargin >= 3 && ~isempty(varargin{1}), R1 = double(varargin{1}); end
            if nargin >= 4 && ~isempty(varargin{2}), S1 = double(varargin{2}); end
            if nargin >= 5 && ~isempty(varargin{3}), R2 = double(varargin{3}); end
            if nargin >= 6 && ~isempty(varargin{4}), S2 = double(varargin{4}); end

            ImgDouble = double(Image);
            Result = zeros(size(ImgDouble));
            Low  = ImgDouble < R1;
            Mid  = ImgDouble >= R1 & ImgDouble <= R2;
            High = ImgDouble > R2;

            Result(Low) = (S1 / R1) * ImgDouble(Low);
            if R2 > R1
                Result(Mid) = S1 + ((S2 - S1) / (R2 - R1)) * (ImgDouble(Mid) - R1);
            else
                Result(Mid) = S2;   % r1 == r2 -> thresholding
            end
            Result(High) = S2 + ((255 - S2) / (255 - R2)) * (ImgDouble(High) - R2);
            OutImage = uint8(min(max(Result, 0), 255));

        case 'piecewise_abg'
            % y = alpha*x (x<a); beta*(x-a)+ya (a<=x<b); gamma*(x-b)+yb (x>=b)
            A = 50; B = 150; Alpha = 0.2; Beta = 2; Gam = 1; Ya = 30; Yb = 200;
            if nargin >= 3 && ~isempty(varargin{1}), A     = double(varargin{1}); end
            if nargin >= 4 && ~isempty(varargin{2}), B     = double(varargin{2}); end
            if nargin >= 5 && ~isempty(varargin{3}), Alpha = double(varargin{3}); end
            if nargin >= 6 && ~isempty(varargin{4}), Beta  = double(varargin{4}); end
            if nargin >= 7 && ~isempty(varargin{5}), Gam   = double(varargin{5}); end
            if nargin >= 8 && ~isempty(varargin{6}), Ya    = double(varargin{6}); end
            if nargin >= 9 && ~isempty(varargin{7}), Yb    = double(varargin{7}); end

            ImgDouble = double(Image);
            Result = zeros(size(ImgDouble));
            M1 = ImgDouble < A;
            M2 = ImgDouble >= A & ImgDouble < B;
            M3 = ImgDouble >= B;
            Result(M1) = Alpha * ImgDouble(M1);
            Result(M2) = Beta * (ImgDouble(M2) - A) + Ya;
            Result(M3) = Gam * (ImgDouble(M3) - B) + Yb;
            OutImage = uint8(min(max(Result, 0), 255));

        case 'threshold'
            % r < m -> 0, r >= m -> 255
            ThreshM = 128;
            if nargin >= 3 && ~isempty(varargin{1}), ThreshM = double(varargin{1}); end

            OutImage = uint8(255 * (Image >= ThreshM));

        case 'slicing_discard'
            % rentang [A,B] -> 255, sisanya -> 0
            RangeA = 142;
            RangeB = 250;
            if nargin >= 3 && ~isempty(varargin{1}), RangeA = double(varargin{1}); end
            if nargin >= 4 && ~isempty(varargin{2}), RangeB = double(varargin{2}); end

            OutImage = zeros(M, N, C, 'uint8');
            OutImage(Image >= RangeA & Image <= RangeB) = 255;

        case 'slicing_preserve'
            % rentang [A,B] -> 255, sisanya tetap
            RangeA = 142;
            RangeB = 250;
            if nargin >= 3 && ~isempty(varargin{1}), RangeA = double(varargin{1}); end
            if nargin >= 4 && ~isempty(varargin{2}), RangeB = double(varargin{2}); end

            OutImage = Image;
            OutImage(Image >= RangeA & Image <= RangeB) = 255;

        case 'bitplane'
            % k = 0 (LSB) ... 7 (MSB)
            BitK = 7;
            if nargin >= 3 && ~isempty(varargin{1}), BitK = double(varargin{1}); end

            OutImage = uint8(bitget(Image, BitK + 1)) * 255;

        otherwise
            error('Unknown TransformType: %s', TransformType)
end