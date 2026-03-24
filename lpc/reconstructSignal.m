function signalReconstructed = reconstructSignal(signal, fs, lpcCoeffs, order, gain)
    % RECONSTRUCTSIGNAL Recompone la señal a partir de componentes LPC
    %
    %   Sintaxis:
    %       signalReconstructed = reconstructSignal(signal, fs, lpcCoeffs, order, gain)
    %
    %   Entrada:
    %       signal (vector): Señal original (puede estar modificada)
    %       fs (int): Frecuencia de muestreo (Hz)
    %       lpcCoeffs (matrix): Coeficientes LPC del análisis
    %       order (int): Orden del filtro LPC
    %       gain (vector): Ganancia por frame del análisis LPC
    %
    %   Salida:
    %       signalReconstructed (vector): Señal reconstruida
    %
    %   Descripción:
    %       Recompone la señal usando los coeficientes LPC y residual.
    
    frameDuration = 0.025;
    frameSamples = round(frameDuration * fs);
    numFrames = size(lpcCoeffs, 1);
    
    signalReconstructed = zeros(size(signal));
    
    for i = 1:numFrames
        frameStart = (i-1) * frameSamples + 1;
        frameEnd = min(frameStart + frameSamples - 1, length(signal));
        actualFrameSamples = frameEnd - frameStart + 1;
        
        frame = signal(frameStart:frameEnd);
        
        % Aplicar ventana
        window = hamming(actualFrameSamples);
        frame = frame .* window;
        
        % Calcular residual (error de predicción LPC)
        a = [1 -lpcCoeffs(i, 1:min(order, actualFrameSamples))];
        residual_frame = filter(a, 1, frame);
        
        % Reconstruir: filtrar residual con inverso de LPC y aplicar ganancia
        reconstructed = filter(1, a, residual_frame) * gain(i);
        
        % Aplicar ventana nuevamente
        reconstructed = reconstructed .* window;
        
        % Asignar al output
        signalReconstructed(frameStart:frameEnd) = reconstructed;
    end
    
end
