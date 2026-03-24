function zcr = computeZCR(signal, frameSamples)
    % COMPUTEZCR Calcula la Tasa de Cruces por Cero (ZCR)
    %
    %   Sintaxis:
    %       zcr = computeZCR(signal, frameSamples)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       frameSamples (int): Número de muestras por frame
    %
    %   Salida:
    %       zcr (vector): Tasa de cruces por cero por frame
    %
    %   Descripción:
    %       Divide la señal en frames y calcula el número de cambios
    %       de signo en cada frame (normalizado).
    
    numFrames = floor(length(signal) / frameSamples);
    zcr = zeros(numFrames, 1);
    
    for i = 1:numFrames
        frameStart = (i-1) * frameSamples + 1;
        frameEnd = frameStart + frameSamples - 1;
        frame = signal(frameStart:frameEnd);
        
        % Contar cambios de signo
        signChanges = sum(abs(diff(sign(frame)))) / 2;
        zcr(i) = signChanges / frameSamples;
    end
    
end
