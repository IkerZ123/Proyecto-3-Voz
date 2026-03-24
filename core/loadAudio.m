function [signal, fs] = loadAudio(audioFile)
    % LOADAUDIO Carga un archivo de audio
    %
    %   Sintaxis:
    %       [signal, fs] = loadAudio(audioFile)
    %
    %   Entrada:
    %       audioFile (string): Ruta del archivo de audio (.wav)
    %
    %   Salida:
    %       signal (vector): Señal de audio
    %       fs (int): Frecuencia de muestreo (Hz)
    %
    %   Descripción:
    %       Carga un archivo de audio en formato WAV y lo convierte
    %       a mono si es necesario.
    
    [signal, fs] = audioread(audioFile);
    
    % Convertir a mono si es estéreo
    if size(signal, 2) > 1
        signal = mean(signal, 2);
    end
    
    % Convertir a vector columna
    signal = signal(:);
    
end
