function pulseModified = modifyPulse(pulse, pulseModifier)
    % MODIFYPULSE Modifica la forma del pulso glotal
    %
    %   Sintaxis:
    %       pulseModified = modifyPulse(pulse, pulseModifier)
    %
    %   Entrada:
    %       pulse (vector): Pulso original
    %       pulseModifier (float): Factor de modificación
    %
    %   Salida:
    %       pulseModified (vector): Pulso modificado
    %
    %   Descripción:
    %       Modifica características del pulso como amplitud o forma.
    
    % TODO: Implementar modificación del pulso
    % - Cambiar amplitud
    % - Cambiar forma (pendiente, duración)
    
    pulseModified = pulse * pulseModifier;
    
end
