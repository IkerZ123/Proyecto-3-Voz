function pulseModified = modifyPulse(pulse, pulseModifier)
    % MODIFYPULSE Modifica la forma del pulso glotal
    %
    %   Sintaxis:
    %       pulseModified = modifyPulse(pulse, pulseModifier)
    %
    %   Entrada:
    %       pulse (vector o matrix): Pulso original (residual)
    %       pulseModifier (float o struct): Factor de modificación
    %
    %   Salida:
    %       pulseModified (vector o matrix): Pulso modificado
    %
    %   Descripción:
    %       Modifica características del pulso como amplitud, duración o forma.
    
    if isstruct(pulseModifier)
        % Modificación avanzada
        if isfield(pulseModifier, 'amplitude')
            pulseModified = pulse * pulseModifier.amplitude;
        end
        if isfield(pulseModifier, 'stretch')
            % Estirar/comprimir el pulso
            pulseModified = resample(pulseModified, round(size(pulse, 2) * pulseModifier.stretch), size(pulse, 2));
        end
    else
        % Modificación simple: amplitud
        pulseModified = pulse * pulseModifier;
    end
    
    % Limitar saturación
    pulseModified = max(min(pulseModified, 1), -1);
    
end
