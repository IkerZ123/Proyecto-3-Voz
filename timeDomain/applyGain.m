function signalAdjusted = applyGain(signal, gainDB)
    % APPLYGAIN Modificación de Amplitud
    %
    %   Sintaxis:
    %       signalAdjusted = applyGain(signal, gainDB)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       gainDB (float): Ganancia en decibelios
    %
    %   Salida:
    %       signalAdjusted (vector): Señal con ganancia aplicada
    %
    %   Descripción:
    %       Aplica una ganancia (amplificación o atenuación) lineal a la señal.
    
    linearGain = 10 ^ (gainDB / 20); % Convertir dB a lineal
    signalAdjusted = signal * linearGain;
    
    % Limitar saturación
    signalAdjusted = max(min(signalAdjusted, 1), -1);
    
end
