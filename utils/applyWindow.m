function window = applyWindow(signal, windowType, frameSamples)
    % APPLYWINDOW Aplica una función de ventana a la señal
    %
    %   Sintaxis:
    %       window = applyWindow(signal, windowType, frameSamples)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       windowType (string): Tipo de ventana ('hann', 'hamming', 'blackman', etc.)
    %       frameSamples (int): Número de muestras de la ventana
    %
    %   Salida:
    %       window (vector): Señal ventaneada
    %
    %   Descripción:
    %       Aplica una función de ventana para reducir efectos espectrales.
    
    switch lower(windowType)
        case 'hann'
            w = hann(frameSamples, 'periodic')';
        case 'hamming'
            w = hamming(frameSamples)';
        case 'blackman'
            w = blackman(frameSamples)';
        otherwise
            w = hamming(frameSamples)';
    end
    
    window = signal .* w;
    
end
