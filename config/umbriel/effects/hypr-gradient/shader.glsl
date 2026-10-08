// Gradiente linear de duas cores sobre o anel da borda focada.
// ANGLE_DEG = 0 vai de cima para baixo; 45 vai do canto superior esquerdo
// ao inferior direito. Cores com alpha 0xEE, como no hyprland.lua.
const vec4 COLOR_START = vec4(0.796, 0.110, 0.553, 0.933); // #CB1C8DEE
const vec4 COLOR_END = vec4(0.275, 0.047, 0.408, 0.933);   // #460C68EE
const float ANGLE_DEG = 45.0;

vec4 border(vec2 uv) {
    float angle = radians(ANGLE_DEG);
    vec2 dir = vec2(sin(angle), cos(angle));
    // Projeção normalizada para que os cantos extremos fiquem em 0 e 1.
    float extent = 0.5 * (abs(dir.x) + abs(dir.y));
    float t = clamp(dot(uv - 0.5, dir) / (2.0 * extent) + 0.5, 0.0, 1.0);
    vec4 color = mix(COLOR_START, COLOR_END, t);
    // Alpha do anel nativo = cobertura (cantos arredondados, antialiasing).
    float coverage = umbriel_sample(uv).a;
    return vec4(color.rgb * color.a, color.a) * coverage;
}
