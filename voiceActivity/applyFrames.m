function frames = applyFrames(signal, frameSamples, hopSamples)
    % APPLYFRAMES Divide la señal en frames con solapamiento
    %
    %   Sintaxis:
    %       frames = applyFrames(signal, frameSamples, hopSamples)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       frameSamples (int): Número de muestras por frame
    %       hopSamples (int): Número de muestras entre frames
    %
    %   Salida:
    %       frames (matrix): Matriz donde cada columna es un frame
    %
    %   Descripción:
    %       Crea frames solapados con ventaneo de Hann.
    
    % TODO: Implementar división en frames con solapamiento
    
    numFrames = floor((length(signal) - frameSamples) / hopSamples) + 1;
    frames = zeros(frameSamples, numFrames);
    window = hann(frameSamples, 'periodic')';
    
    for i = 1:numFrames
        start = (i-1) * hopSamples + 1;
        frames(:, i) = signal(start:start + frameSamples - 1) .* window;
    end
    
end
