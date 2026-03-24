function pulse = extractPulse(residual)
    % EXTRACTPULSE Extrae el pulso de la señal residual
    %
    %   Sintaxis:
    %       pulse = extractPulse(residual)
    %
    %   Entrada:
    %       residual (matrix): Señal residual de LPC
    %
    %   Salida:
    %       pulse (vector): Pulso extraído
    %
    %   Descripción:
    %       Aísla el componente de pulso del residual LPC.
    
    % TODO: Implementar extracción de pulso
    % El pulso representa la excitación glotal
    
    pulse = residual;
    
end
