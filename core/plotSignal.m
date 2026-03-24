function plotSignal(signal, fs, title_str)
    % PLOTSIGNAL Visualiza una señal de audio en el tiempo
    %
    %   Sintaxis:
    %       plotSignal(signal, fs, title_str)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       fs (int): Frecuencia de muestreo (Hz)
    %       title_str (string): Título de la gráfica
    %
    %   Descripción:
    %       Dibuja la señal de audio en el dominio del tiempo,
    %       con el eje X en segundos.
    
    figure;
    duration = length(signal) / fs;
    time = linspace(0, duration, length(signal));
    
    plot(time, signal);
    xlabel('Tiempo (s)');
    ylabel('Amplitud');
    title(title_str);
    grid on;
    
end
