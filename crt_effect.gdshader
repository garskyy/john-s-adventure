shader_type canvas_item;

// Захватываем изображение экрана под этим слоем
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Настройки эффектов (можно менять в инспекторе)
uniform float curvature : hint_range(0.0, 10.0) = 3.0; // Рыбий глаз (искривление)
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.4; // Затемнение по краям
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.3; // Яркость полос (ряби)
uniform float scanline_count : hint_range(50.0, 1000.0) = 240.0; // Количество полос
uniform float noise_intensity : hint_range(0.0, 0.2) = 0.03; // Статический шум

// Функция для искажения экрана (рыбий глаз)
vec2 curve_uv(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs(uv.yx) / vec2(curvature, curvature);
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

// Генератор простого шума для ряби
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233)) + TIME) * 43758.5453);
}

void fragment() {
    // 1. Применяем рыбий глаз
    vec2 uv = SCREEN_UV;
    if (curvature > 0.0) {
        uv = curve_uv(uv);
    }

    // Окрашиваем края за пределами экрана в черный цвет
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // Получаем цвет пикселя с экрана
        vec3 color = texture(screen_texture, uv).rgb;

        // 2. Добавляем полосы развертки (Scanlines)
        float scanline = sin(uv.y * scanline_count * 3.14159 * 2.0) * 0.5 + 0.5;
        color -= scanline * scanline_opacity * 0.5;

        // 3. Добавляем живую рябь (шум)
        float noise = (random(uv) - 0.5) * noise_intensity;
        color += noise;

        // 4. Добавляем затемнение по краям (виньетка)
        vec2 vig_uv = uv * (1.0 - uv.yx);
        float vig = vig_uv.x * vig_uv.y * 15.0;
        vig = pow(vig, vignette_intensity);
        color *= vig;

        COLOR = vec4(color, 1.0);
    }
}
