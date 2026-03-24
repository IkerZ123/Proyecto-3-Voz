function [lpcCoeffs, residual, gain] = computeLPC(signal, fs, order)
    % COMPUTELPC Calcula los coeficientes de Linear Predictive Coding
    %
    %   Sintaxis:
    %       [lpcCoeffs, residual, gain] = computeLPC(signal, fs, order)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       fs (int): Frecuencia de muestreo (Hz)
    %       order (int): Orden del filtro LPC (típicamente 12-16)
    %
    %   Salida:
    %       lpcCoeffs (matrix): Coeficientes LPC por frame
    %       residual (matrix): Señal residual (pulso) por frame
    %       gain (vector): Ganancia por frame
    %
    %   Descripción:
    %       Calcular coeficientes LPC para modelar el tracto vocal.
    
    frameDuration = 0.025;
    frameSamples = round(frameDuration * fs);
    
    numFrames = floor(length(signal) / frameSamples);
    lpcCoeffs = zeros(numFrames, order);
    residual = zeros(numFrames, frameSamples);
    gain = zeros(numFrames, 1);
    
    for i = 1:numFrames
        frameStart = (i-1) * frameSamples + 1;
        frameEnd = frameStart + frameSamples - 1;
        frame = signal(frameStart:frameEnd);
        
        % Aplicar ventana
        window = hamming(frameSamples);
        frame = frame .* window;
        
        % Calcular coeficientes LPC
        [a, g] = lpc(frame, order);
        
        lpcCoeffs(i, :) = a(2:end); % Excluir coeficiente 1
        gain(i) = g;
        
        % Calcular residual
        residual(i, :) = filter([1 -a(2:end)], 1, frame)';
    end
    
end
