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
    
    frameDuration = 0.025;
    frameSamples = round(frameDuration * fs);
    numFrames = floor(length(signal) / frameSamples);
    
    signalModified = signal;
    
    for i = 1:numFrames
        frameStart = (i-1) * frameSamples + 1;
        frameEnd = min(frameStart + frameSamples - 1, length(signal));
        actualFrameSamples = frameEnd - frameStart + 1;
        
        frame = signal(frameStart:frameEnd);
        
        % Solo modificar si el frame es sonoro
        if isVoiced(i) && actualFrameSamples == frameSamples
            % Aplicar ventana
            window = hamming(actualFrameSamples);
            frame_windowed = frame .* window;
            
            % Transformada de Fourier
            frame_fft = fft(frame_windowed);
            freq_bins = 0:length(frame_fft)-1;
            
            % Desplazar espectro (pitch shift en el dominio de Fourier)
            new_bins = freq_bins / pitchFactor;
            
            % Interpolar espectro
            frame_fft_shifted = interp1(freq_bins, frame_fft, new_bins, 'linear', 0);
            
            % Si el factor amplía el espectro, rellenar con ceros
            if pitchFactor < 1
                frame_fft_shifted(ceil(end/pitchFactor):end) = 0;
            end
            
            % Transformada inversa
            frame_modified = real(ifft(frame_fft_shifted));
            
            % Remover ventana
            frame_modified = frame_modified .* window;
            
            % Normalizar
            max_val = max(abs(frame_modified));
            if max_val > 0
                frame_modified = frame_modified / max_val * max(abs(frame));
            end
            
            signalModified(frameStart:frameEnd) = frame_modified(1:actualFrameSamples);
        end
    end
    
    % Normalizar señal final
    max_val = max(abs(signalModified));
    if max_val > 1
        signalModified = signalModified / max_val;
    end
    
end
