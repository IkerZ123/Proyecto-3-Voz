function signalStretched = timeStretch(signal, stretchFactor)
    % TIMESTRETCH Expansión o compresión temporal
    %
    %   Sintaxis:
    %       signalStretched = timeStretch(signal, stretchFactor)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       stretchFactor (float): Factor de estiramiento (>1 más lenta, <1 más rápida)
    %
    %   Salida:
    %       signalStretched (vector): Señal con duración modificada
    %
    if stretchFactor == 1 || isempty(signal)
        signalStretched = signal;
        return;
    end

    signal = signal(:);
    winLen = 256;
    hop = round(winLen/4);
    if hop < 1
        hop = 1;
    end
    outHop = max(1, round(hop * stretchFactor));
    window = hann(winLen, 'periodic');

    numFrames = floor((length(signal) - winLen) / hop) + 1;
    outLen = (numFrames-1) * outHop + winLen;
    signalStretched = zeros(outLen, 1);
    normWindow = zeros(outLen, 1);

    for i = 1:numFrames
        inStart = (i-1) * hop + 1;
        frame = signal(inStart:inStart + winLen - 1) .* window;
        outStart = (i-1) * outHop + 1;
        signalStretched(outStart:outStart + winLen - 1) = signalStretched(outStart:outStart + winLen - 1) + frame;
        normWindow(outStart:outStart + winLen - 1) = normWindow(outStart:outStart + winLen - 1) + window;
    end

    nz = normWindow > 0;
    signalStretched(nz) = signalStretched(nz) ./ normWindow(nz);
    signalStretched(~nz) = 0;

    % Ajustar longitud final aproximada
    desiredLen = round(length(signal) * stretchFactor);
    if length(signalStretched) > desiredLen
        signalStretched = signalStretched(1:desiredLen);
    else
        signalStretched = [signalStretched; zeros(desiredLen - length(signalStretched), 1)];
    end
end
