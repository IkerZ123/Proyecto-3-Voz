function energy = computeEnergy(signal, frameSamples)
    % COMPUTEENERGY Calcula la energía de la señal por frames
    %
    %   Sintaxis:
    %       energy = computeEnergy(signal, frameSamples)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       frameSamples (int): Número de muestras por frame
    %
    %   Salida:
    %       energy (vector): Energía por frame
    %
    %   Descripción:
    %       Divide la señal en frames y calcula la energía de cada uno.
    
    numFrames = floor(length(signal) / frameSamples);
    energy = zeros(numFrames, 1);
    
    for i = 1:numFrames
        frameStart = (i-1) * frameSamples + 1;
        frameEnd = frameStart + frameSamples - 1;
        frame = signal(frameStart:frameEnd);
        energy(i) = sum(frame .^ 2) / frameSamples;
    end
    
end
