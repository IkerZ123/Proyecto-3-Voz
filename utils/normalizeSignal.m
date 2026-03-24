function signalNorm = normalizeSignal(signal, targetPower)
    % NORMALIZESIGNAL Normaliza la señal a una potencia objetivo
    %
    %   Sintaxis:
    %       signalNorm = normalizeSignal(signal)
    %       signalNorm = normalizeSignal(signal, targetPower)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       targetPower (float, opcional): Potencia objetivo (default: 1)
    %
    %   Salida:
    %       signalNorm (vector): Señal normalizada
    %
    %   Descripción:
    %       Escala la señal para que tenga la potencia deseada.
    
    if nargin < 2
        targetPower = 1;
    end
    
    currentPower = mean(signal .^ 2);
    
    if currentPower > 0
        signalNorm = signal * sqrt(targetPower / currentPower);
    else
        signalNorm = signal;
    end
    
end
