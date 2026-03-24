function F0 = computeF0(signal, fs)
    % COMPUTEF0 Estimación de Frecuencia Fundamental (F0)
    %
    %   Sintaxis:
    %       F0 = computeF0(signal, fs)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       fs (int): Frecuencia de muestreo (Hz)
    %
    %   Salida:
    %       F0 (vector): Frecuencia fundamental por frame (Hz)
    %
    %   Descripción:
    %       Estima F0 usando autocorrelación para cada frame.
    
    frameDuration = 0.025;
    frameSamples = round(frameDuration * fs);
    minF0 = 50;  % Hz
    maxF0 = 500; % Hz
    
    minLag = round(fs / maxF0);
    maxLag = round(fs / minF0);
    
    numFrames = floor(length(signal) / frameSamples);
    F0 = zeros(numFrames, 1);
    
    for i = 1:numFrames
        frameStart = (i-1) * frameSamples + 1;
        frameEnd = frameStart + frameSamples - 1;
        frame = signal(frameStart:frameEnd);
        
        % Calcular autocorrelación
        acf = computeACF(frame, maxLag);
        
        % Encontrar pico en rango de F0
        [~, maxIdx] = max(acf(minLag:maxLag));
        lag = minLag + maxIdx - 1;
        F0(i) = fs / lag;
    end
    
end
