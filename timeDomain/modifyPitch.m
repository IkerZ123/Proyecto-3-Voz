function signalModified = modifyPitch(signal, fs, isVoiced, pitchFactor)
    % MODIFYPITCH Modificación de Entonación/Pitch
    %
    %   Sintaxis:
    %       signalModified = modifyPitch(signal, fs, isVoiced, pitchFactor)
    %
    %   Entrada:
    %       signal (vector): Señal de audio original
    %       fs (int): Frecuencia de muestreo (Hz)
    %       isVoiced (vector): Indicador de sonoridad por frame
    %       pitchFactor (float): Factor de modificación (>1 aumenta, <1 disminuye)
    %
    %   Salida:
    %       signalModified (vector): Señal con pitch modificado
    %
    %   Descripción:
    %       Modifica la entonación de la señal sin cambiar su duración.
    %       Usa interpolación y remuestreo en el dominio del tiempo.
    
    % TODO: Implementar modificación de pitch usando:
    % - Phase vocoder
    % - Sincronización de épocas
    % - PSOLA (Pitch Synchronous Overlap-Add)
    
    frameDuration = 0.025;
    frameSamples = round(frameDuration * fs);
    hopSamples = frameSamples / 2;
    
    signalModified = signal; % Placeholder
    
end
